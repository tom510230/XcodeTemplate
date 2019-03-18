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
#import "FileViewController.h"

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
    
    UIButton *button5 = [[UIButton alloc] initWithFrame:CGRectMake(10, 220, 300, 30)];
    [self.view addSubview:button5];
    [button5 setTitle:@"文件浏览器" forState:UIControlStateNormal];
    [button5 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button5.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button5 addTarget:self action:@selector(gotoFileBrowser) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button6 = [[UIButton alloc] initWithFrame:CGRectMake(10, 250, 300, 30)];
    [self.view addSubview:button6];
    [button6 setTitle:@"文件浏览器按时间排序" forState:UIControlStateNormal];
    [button6 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button6.titleLabel.textAlignment = NSTextAlignmentLeft;
    [button6 addTarget:self action:@selector(gotoFileBrowserByDate) forControlEvents:UIControlEventTouchUpInside];
    
    [self doMaths:@[@1,@1,@0,@1,@1,@1]];
    [self detectCapitalUse:@"FLAG"];
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
    vc.name = @"largefile";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoYYImageWithLarge
{
    YYImageViewController *vc = [[YYImageViewController alloc] init];
    vc.name = @"largefile";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoFileBrowserByDate
{
    FileViewController *vc = [[FileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoFileBrowser
{
    FileViewController *vc = [[FileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)doMaths:(NSArray *)nums
{
    if(nums.count < 1){
        return 0;
    }
    
    NSInteger currMax = 0;
    NSInteger result = 0;
    
    for(NSNumber *num in nums) {
        if([num integerValue] == 1) {
            currMax += 1;
        } else {
            currMax = 0;
        }
        if(result < currMax) {
            result = currMax;
        }
    }
    
    NSLog(@"doMaths = %@", @(result));
    return result;
}

- (BOOL)detectCapitalUse:(NSString *)word
{
    NSInteger capitalNum = 0;
    BOOL isFirstUpperCased = false;
    NSString *first = nil;
    
    for (int i = 0; i < word.length; i++) {
        unichar ch = [word characterAtIndex:i];
        NSString *cha = [NSString stringWithCharacters:&ch length:1];
        if(i == 0) {
            first = cha;
        }
        if([cha isUpperCased]) {
            capitalNum += 1;
        }
    }
    
    if(word.length > 0) {
        isFirstUpperCased = [first isUpperCased];
    }
    
    BOOL flag = (capitalNum == 0 || (capitalNum == 1 && isFirstUpperCased) || capitalNum == word.length);
    NSLog(@"detectCapitalUse = %@", @(flag));
    return flag;
}


@end

@implementation NSString(Upper)

- (BOOL)isUpperCased
{
    return [[self uppercaseString] isEqualToString:self];
}

@end
