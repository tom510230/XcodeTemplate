//
//  MMGifView.m
//  MicroMessenger
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GifItem;

@interface MMGifView : UIView {
    __weak GifItem* m_refData;
    UIImageView* m_imageView;
    CGSize m_size;
}
@property (nonatomic, weak) GifItem *m_refData; // assign not retain. data should dealloc without view.
@property (nonatomic, retain) IBOutlet UIImageView *m_imageView;
@property (nonatomic, assign) CGSize m_size;
@property (nonatomic, assign) CGSize originSize;
@end
