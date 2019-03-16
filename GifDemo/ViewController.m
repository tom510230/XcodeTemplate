//
//  ViewController.m
//  GifDemo
//
//  Created by tom on 2019/1/22.
//  Copyright © 2019年 faceu. All rights reserved.
//

#import "ViewController.h"
#import "GifViewController.h"
#import "YYImageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    // Do any additional setup after loading the view, typically from a nib.
    [self setup];
}

- (void)setup
{
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 100, 300, 30)];
    [self.view addSubview:button];
    [button setTitle:@"Gif演示" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button addTarget:self action:@selector(gotoGifView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 130, 300, 30)];
    [self.view addSubview:button2];
    [button2 setTitle:@"YYImage演示" forState:UIControlStateNormal];
    [button2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button2.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button2 addTarget:self action:@selector(gotoYYImage) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 160, 300, 30)];
    [self.view addSubview:button3];
    [button3 setTitle:@"Gif演示大文件" forState:UIControlStateNormal];
    [button3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button3.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button3 addTarget:self action:@selector(gotoGifViewWithLarge) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button4 = [[UIButton alloc] initWithFrame:CGRectMake(10, 190, 300, 30)];
    [self.view addSubview:button4];
    [button4 setTitle:@"YYImage演示大文件" forState:UIControlStateNormal];
    [button4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button4.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button4 addTarget:self action:@selector(gotoYYImageWithLarge) forControlEvents:UIControlEventTouchUpInside];
}
    
- (void)gotoGifView
{
    GifViewController *vc = [[GifViewController alloc] init];
    vc.name = @"demo";
    [self.navigationController pushViewController:vc animated:YES];
}
    
- (void)gotoYYImage
{
    YYImageViewController *vc = [[YYImageViewController alloc] init];
    vc.name = @"demo";
    [self.navigationController pushViewController:vc animated:YES];
}
    
- (void)gotoGifViewWithLarge
{
    GifViewController *vc = [[GifViewController alloc] init];
    vc.name = @"large";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoYYImageWithLarge
{
    YYImageViewController *vc = [[YYImageViewController alloc] init];
    vc.name = @"large";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
