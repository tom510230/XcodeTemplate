//
//  PPInvitationButton.m
//  PPMerchant
//
//  Created by L on 15/10/22.
//  Copyright © 2015年 HaoMoney. All rights reserved.
//

#import "PPInvitationButton.h"

@implementation PPInvitationButton

+(instancetype)invitationCodeButton{
    
    PPInvitationButton *btn = (PPInvitationButton*)[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 33);
    //利用富文本属性设置button的样式
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"生成邀请码"];
    NSRange strRange = {0,[str length]};
    //设置下划线
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:strRange];
    [str addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:strRange];
    [btn setAttributedTitle:str forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    // 让按钮的内容往右边偏移10
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);

    return btn;
}

@end