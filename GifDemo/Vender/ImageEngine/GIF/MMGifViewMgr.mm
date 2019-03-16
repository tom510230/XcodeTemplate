//
//  MMGifViewMgr.m
//  MicroMessenger
//
//  Created by jakerong on 11-11-2.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "MMGifViewMgr.h"
#import "MxImage.h"
#import "MxGifImage.h"
#import "MxAlgorithm.h"

// GIF最小更新间隔
#define GIF_UPDATE_INVTERVAL 0.06
// 每次更新最多更新GIF图片数
#define GIF_MAX_UPDATE_COUNT_PER_ROUNDTRIP 3
// 最大空转次数,超过则关闭timer
#define GIF_MAX_EMPTY_ROUNDTRIP_COUNT 30


////////////////////////////////////////////////////////////////////////////////////////////////


#ifdef MMDebug
#define GIFLOG MMDebug
#else
#define GIFLOG QZLOG_DEBUG
#endif








#pragma mark - GifItem

@interface GifItem : NSObject {
    __weak MMGifView* view;
    MxGifImage* image;
    NSData* data;
    int lastID;
    unsigned long lastTick;
    NSString* cachePath;
    int filter;
    bool updated;
    NSMutableArray* imgCache;
}

@property (nonatomic, weak) MMGifView *view; // dont retain the view! or it will never dealloc.
@property (nonatomic, assign) MxGifImage *image;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, assign) int lastID;
@property (nonatomic, assign) unsigned long lastTick;
@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) int filter;
@property (nonatomic, assign) bool updated;
@property (nonatomic, retain) NSMutableArray *imgCache;
- (void)addToImgCache:(id)imgCacheObject;

@end

@implementation GifItem
@synthesize view;
@synthesize image;
@synthesize data;
@synthesize lastID;
@synthesize lastTick;
@synthesize cachePath;
@synthesize filter;
@synthesize updated;
@synthesize imgCache;

- (void)addToImgCache:(id)imgCacheObject
{
    if (imgCache==nil) {
        self.imgCache = [NSMutableArray array];
    }
    [[self imgCache] safeAddObject:imgCacheObject];
}



- (id)init {
    self = [super init];
    if (self) {
        image = NULL;
        lastID = -1;
        lastTick = 0;
        filter = GIF_FILTER_NONE;
        updated = false;
    }
    return self;
}

- (void)dealloc {
    MX_SAFE_DELETE(image);
    self.data = nil;    
    self.cachePath = nil;
    self.imgCache = nil;
    [super dealloc];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark - MMGifViewMgr

@implementation MMGifViewMgr
@synthesize m_gifs;
@synthesize m_timer;
@synthesize m_updateQueue;

static MMGifViewMgr *sharedInstance = nil; 


-(void)RegisterSysNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

-(void)UnRegisterSysNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        m_emptyRoundTripCount = 0;
        [self RegisterSysNotifications];
    }
    return self;
}

+ (void)initialize
{
    if (sharedInstance == nil)
        sharedInstance = [[[self class] alloc] init];
}

+ (id)sharedMMGifViewMgr
{
    //Already set by +initialize.
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone
{
    //Usually already set by +initialize.
    if (sharedInstance) {
        //The caller expects to receive a new object, so implicitly retain it
        //to balance out the eventual release message.
        return [sharedInstance retain];
    } else {
        //When not already set, +initialize is our caller.
        //It's creating the shared instance, let this go through.
        return [super allocWithZone:zone];
    }
}

- (void)dealloc { 
    [self UnRegisterSysNotifications];
    if (m_timer) {
        [m_timer invalidate];
    }
    self.m_timer = nil;
    self.m_updateQueue = nil;
    self.m_gifs = nil;
    
    [super dealloc];
}

// update queue
- (NSUInteger)countOfUpdateQueue 
{
    return [[self m_updateQueue] count];
}
- (void)addToUpdateQueue:(id)m_updateQueueObject
{
    if (m_updateQueue==nil) {
        self.m_updateQueue = [NSMutableArray array];
    }
    if ([m_updateQueue containsObject:m_updateQueueObject]) {
        return;
    }
    [[self m_updateQueue] safeAddObject:m_updateQueueObject];
    if ([self countOfUpdateQueue]>0) {
        [self startUpdateGifViews];
    }
}
- (void)removeFromUpdateQueue:(id)m_updateQueueObject
{
    [[self m_updateQueue] safeRemoveObject:m_updateQueueObject];
}

// all gif items
- (void)addGifItem:(id)gif
{
    if (m_gifs==nil) {
        self.m_gifs = [NSMutableArray array];
    }
    [[self m_gifs] safeAddObject:gif];
}
- (void)removeGifItem:(id)gif
{
    [[self m_gifs] safeRemoveObject:gif];
}
- (NSUInteger)countOfGifItem
{
    return [[self m_gifs] count];
}

-(unsigned long) getTickCount
{
    unsigned long long time = CFAbsoluteTimeGetCurrent()*1000;
    time = time << 32;
    time = time >> 32;
    return time;
}

-(UIImage*) imageForGifItem:(GifItem*)item
{
    MxImage* img = item.image->image();
    BOOL releaseImage = NO;
    
    UIImage* image = nil;
    
    // remove background
    if (item.filter&GIF_FILTER_REMOVE_BACKGROUND) {
        MxImage* tmp = mxCreateImage(img->width, img->height, img->nChannels);
        mxCopy(img, tmp);
        remove_image_background(tmp);
        img = tmp;
        releaseImage = YES;
    }
    
    // scale
    if(item.filter&GIF_FILTER_SET_SCALE_2){
        image = UIImageFromMxImageEx(img, 2.0);
    }else{
        image = UIImageFromMxImage(img);
    }
    
    if (releaseImage) {
        mxReleaseImage(img);
    }
    
    return image;
}

-(void)updateAllGifItem
{
    m_tickCount = [self getTickCount];
    NSInteger count = [self countOfUpdateQueue];
    
    NSMutableArray *updatedItems = [NSMutableArray array];

    for (NSInteger i = 0; i < count; i++) {
        GifItem* item = [m_updateQueue safeObjectAtIndex:i];
        
        if (item.updated) {
            [updatedItems safeAddObject:item];
            continue;
        }
        
        if ([updatedItems count]>=GIF_MAX_UPDATE_COUNT_PER_ROUNDTRIP) {
            break;
        }
        
        item.image->flashFrame(m_tickCount);
        int flameID = item.image->frameID();
        if (flameID!=item.lastID) {
            
            if (flameID < item.lastID && (item.filter&GIF_FILTER_LOOP_ONCE)) {
                [self removeGifItem:item];
                item.view.m_refData = nil;
                continue;
            }
            
            item.lastID = flameID;
            
            UIImage* image = nil;
            
            if ( (item.filter&GIF_FILTER_CACHE_FRAMES) && item.imgCache && flameID < [item.imgCache count]) {
                image = [item.imgCache safeObjectAtIndex:flameID];
            }
            
            if (image==nil) {
                image = [self imageForGifItem:item];
                if (item.filter&GIF_FILTER_CACHE_FRAMES) {
                    [item addToImgCache: image];
                }
            }
            
            item.view.m_imageView.image = image;
            
            [item.view setNeedsLayout];
            item.updated = true;
            
            [updatedItems safeAddObject:item];
        }
    }
    
    if ([self countOfUpdateQueue]==0) {
        m_emptyRoundTripCount++;
        if (m_emptyRoundTripCount>GIF_MAX_EMPTY_ROUNDTRIP_COUNT) {
            [self stopUpdateGifViews];
        }
    }else{
        m_emptyRoundTripCount = 0;
    }
    
    for (GifItem* item in updatedItems) {
        [self removeFromUpdateQueue:item];
    }
    
#ifdef DEBUG
//    if ([updatedItems count]>0) {
//        static int aa = 0;
//        GIFLOG(@"%d total = %d,queueCount=%d updateCount=%d",aa++,[self countOfGifItem],count,[updatedItems count]);
//    }
#endif
    
}

-(void) startUpdateGifViews
{
    if (m_timer==nil) {
        self.m_timer = [NSTimer scheduledTimerWithTimeInterval:GIF_UPDATE_INVTERVAL target:self selector:@selector(updateAllGifItem) userInfo:nil repeats:YES];
        NSLog(@"startUpdateGifViews >>>>>>>>");
    }
}

-(void) stopUpdateGifViews
{
    [m_timer invalidate];
    self.m_timer = nil;
    NSLog(@"stopUpdateGifViews <<<<<<<<<<");
}

-(MMGifView*) createGifViewFromData:(NSData*)data withFilter:(int)filter
{
    return [self createGifViewFromData:data withFilter:filter maxSize:[UIScreen mainScreen].bounds.size];
}

-(MMGifView*) createGifViewFromData:(NSData*)data withFilter:(int)filter maxSize:(CGSize)size {
    GifItem* item = [[GifItem alloc] init];
    MMGifView* view = [[MMGifView alloc] init];
    MxGifImage* gif = new MxGifImage();
    item.data = data;
    item.image = gif;
    item.view = view;
    item.filter = filter;
    
    if(!gif->loadFromBufferNoCopy((uchar*)[data bytes], [data length]))
    {
        [item release];
        [view release];
        return nil;
    }
    
    if (item.filter&GIF_FILTER_LAST_FRAME) {
        gif->seedToEnd();
    }
    
    UIImage* image = [self imageForGifItem:item];
    
    if (item.filter&GIF_FILTER_CACHE_FRAMES){
        [item addToImgCache: image];
    }
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageView];
    view.m_imageView = imageView;
    [imageView release];
    
    if (item.filter&GIF_FILTER_SET_SCALE_2) {
        view.m_size = CGSizeMake(gif->width()/2.0, gif->height()/2.0);
    }else{
        view.m_size = CGSizeMake(gif->width(), gif->height());
    }
    
    CGFloat scaleX = view.m_size.width / size.width;
    CGFloat scaleY = view.m_size.height / size.height;
    if (scaleX > scaleY) {
        if (scaleX > 1) {
            view.m_size = CGSizeMake(view.m_size.width / scaleX, view.m_size.height / scaleX);
        }
    } else if (scaleX < scaleY) {
        if (scaleY > 1) {
            view.m_size = CGSizeMake(view.m_size.width / scaleY, view.m_size.height / scaleY);
        }
    }
    
    
    CGRect frame = view.frame;
    frame.size = view.m_size;
    view.frame = frame;
    view.userInteractionEnabled = NO;
    view.clearsContextBeforeDrawing = NO;
    view.backgroundColor = [UIColor clearColor];
    
    if (!gif->isSingleFrameImage() && !(item.filter&GIF_FILTER_FIRST_FRAME) && !(item.filter&GIF_FILTER_LAST_FRAME)) {
        item.view.m_refData = item;
        [self addGifItem:item];
        [self startUpdateGifViews];
    }
    
    [item release];
    
    return [view autorelease];
}

-(MMGifView*) createGifViewFromData:(NSData*)data
{
    return [self createGifViewFromData:data withFilter:GIF_FILTER_NONE];
}

-(MMGifView*) createGifViewFromData:(NSData*)data maxSize:(CGSize)size {
    return [self createGifViewFromData:data withFilter:[[UIScreen mainScreen] scale] == 1 ? GIF_FILTER_NONE : GIF_FILTER_SET_SCALE_2 maxSize:size];
}

-(MMGifView*) createGifViewFromFile:(NSString*)path
{
    NSData* data = [NSData dataWithContentsOfFile:path];
    MMGifView* view = [self createGifViewFromData:data];
    return view;
}

-(GifItem*) findGifItemByView:(MMGifView*)view
{
    GifItem* item = nil;
    for (GifItem* gifitem in m_gifs){
        if (gifitem.view == view) {
            item = gifitem;
            break;
        }
    }
    return item;
}

-(void) unregisterGifViewForUpdate:(MMGifView*)view
{    
    [self removeFromUpdateQueue:view.m_refData];
    [self removeGifItem:view.m_refData];
    if ([self countOfGifItem]==0) {
        [self stopUpdateGifViews];
    }
}

-(void) refreshGifViewUpdater:(MMGifView*)view
{
    [self addToUpdateQueue:view.m_refData];
    view.m_refData.updated = false;
}


////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - System Notification

-(void)onApplicationWillTerminate:(NSNotification*)notification
{
    [self stopUpdateGifViews];
}

-(void)onApplicationWillResignActive:(NSNotification*)notification
{
    [self stopUpdateGifViews];
}

-(void)onApplicationDidBecomeActive:(NSNotification*)notification
{
    [self startUpdateGifViews];
}

-(void)onApplicationDidReceiveMemoryWarning:(NSNotification*)notification
{
    
}

@end
