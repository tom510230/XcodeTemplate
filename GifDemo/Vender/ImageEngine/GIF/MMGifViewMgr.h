//
//  MMGifViewMgr.h
//  MicroMessenger
//
//  Created by jakerong on 11-11-2.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMGifView.h"

@class GifItem;

enum { 
    GIF_FILTER_NONE              = 0,    // 默认
    GIF_FILTER_REMOVE_BACKGROUND = 1,    // 去除背景
    GIF_FILTER_SET_SCALE_2       = 1<<1, // 高清，大小为原图的1/4
    GIF_FILTER_CACHE_FRAMES      = 1<<2, // 缓存每一帧,不再重新解释
    GIF_FILTER_LOOP_ONCE         = 1<<3, // 只播一次
    GIF_FILTER_FIRST_FRAME       = 1<<4, // 只显示第一帧，强制静态
    GIF_FILTER_LAST_FRAME        = 1<<5, // 只显示最后一帧，强制静态
};

@interface MMGifViewMgr : NSObject {
    NSMutableArray* m_gifs;
    NSTimer* m_timer;
    unsigned long m_tickCount;
    NSMutableArray* m_updateQueue;
    unsigned long m_emptyRoundTripCount;
}
@property (nonatomic, retain) NSMutableArray *m_gifs;
@property (nonatomic, retain) NSTimer *m_timer;
@property (nonatomic, retain) NSMutableArray *m_updateQueue;

+ (id)sharedMMGifViewMgr;

-(void) startUpdateGifViews;
-(void) stopUpdateGifViews;

-(MMGifView*) createGifViewFromData:(NSData*)data withFilter:(int)filter;
-(MMGifView*) createGifViewFromData:(NSData*)data withFilter:(int)filter maxSize:(CGSize)size;
-(MMGifView*) createGifViewFromData:(NSData*)data;
-(MMGifView*) createGifViewFromData:(NSData*)data maxSize:(CGSize)size;
-(MMGifView*) createGifViewFromFile:(NSString*)path;

-(void) unregisterGifViewForUpdate:(MMGifView*)view;

-(void) refreshGifViewUpdater:(MMGifView*)view;


#define GIF_MGR [MMGifViewMgr sharedMMGifViewMgr]


@end
