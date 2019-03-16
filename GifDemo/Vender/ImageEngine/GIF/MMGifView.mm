//
//  MMGifView.m
//  MicroMessenger
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "MMGifView.h"
#import "GifCore.h"
#import "MMGifViewMgr.h"

@implementation MMGifView
@synthesize m_refData;
@synthesize m_imageView;
@synthesize m_size;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    m_imageView.frame = self.bounds;
    if (m_refData) {
        [GIF_MGR refreshGifViewUpdater:self];
    }
}


- (void)dealloc
{
    self.m_imageView = nil;
    
    if (m_refData) {
        [GIF_MGR unregisterGifViewForUpdate:self];
    }
    
    [super dealloc];
}

#pragma mark - Gif Decode


@end
