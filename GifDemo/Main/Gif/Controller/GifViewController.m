//
//  GifViewController.m
//  GifDemo
//
//  Created by tom on 2019/1/22.
//  Copyright © 2019年 faceu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GifViewController.h"
#import "MMGifViewMgr.h"

@interface GifViewController () {
    MMGifView *_previewGifView;
    UILabel *_label;
}

@end

@implementation GifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Gif展示";
    // Do any additional setup after loading the view, typically from a nib.
    [self setup];
}

- (void)setup
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(10, UIScreen.mainScreen.bounds.size.height - 60, UIScreen.mainScreen.bounds.size.width - 10, 30)];
    [self.view addSubview:_label];
    _label.textColor = UIColor.blackColor;
    
    [self show];
}
    
- (void)show
{
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:_name ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    _previewGifView = [[MMGifViewMgr sharedMMGifViewMgr] createGifViewFromData:data];
    _previewGifView.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    if (_previewGifView) {
        [self.view addSubview:_previewGifView];
    } else {
        [self log:@"gif文件预览失败"];
    }
}
    
- (void)log:(NSString *)string
{
    _label.text = string;
}
    
@end
