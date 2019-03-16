//
//  YYImageViewController.m
//  GifDemo
//
//  Created by tom on 2019/1/22.
//  Copyright © 2019年 faceu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYImageViewController.h"
#import <YYImage/YYImage.h>

@interface YYImageViewController () {
    UILabel *_label;
}

@end

@implementation YYImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"YYImage展示";
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
    UIImage *image = [YYImage imageNamed:[NSString stringWithFormat:@"%@.gif", _name]];
    UIImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    [self.view addSubview:imageView];
}
    
- (void)log:(NSString *)string
{
    _label.text = string;
}
    
@end
