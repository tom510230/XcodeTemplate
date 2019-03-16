//
//  BaseData.m
//  PP理财
//
//  Created by 刘超 on 14-10-15.
//  Copyright (c) 2014年 海浪. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
-(id)init
{
    self = [super init];
    if (self) {
        [self setData];
    }
    return self;
}

-(void)setData
{

}

#pragma mark - 共有方法，返回数据
-(NSMutableDictionary *)returnDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (self.ostype != nil) {
        [dic setObject:self.ostype forKey:@"ostype"];
    }
    if (self.channel != nil) {
        [dic setObject:self.channel forKey:@"channel"];
    }
    if (self.deviceID != nil) {
        [dic setObject:self.deviceID forKey:@"deviceID"];
    }
    if (self.mac != nil) {
        [dic setObject:self.mac forKey:@"mac"];
    }
    if (self.phoneType != nil) {
        [dic setObject:self.phoneType forKey:@"phoneType"];
    }
    if (self.phoneResolution != nil) {
        [dic setObject:self.phoneResolution forKey:@"phoneResolution"];
    }
    if (self.version != nil) {
        [dic setObject:self.version forKey:@"version"];
    }
    if (self.latitudeLongitude != nil) {
        [dic setObject:self.latitudeLongitude forKey:@"latitudeLongitude"];
    }
    if (self.systemVersion != nil) {
        [dic setObject:self.systemVersion forKey:@"systemVersion"];
    }
    if (self.startdate != 0) {
        [dic setObject:[NSNumber numberWithLongLong:self.startdate] forKey:@"startdate"];
    }
    if (self.accessToken != nil) {
        [dic setObject:self.accessToken forKey:@"accessToken"];
    }
    
    return dic;
}

-(NSData *)returnData
{
    return [NSJSONSerialization dataWithJSONObject:[self returnDictionary] options:0 error:nil];
}

-(NSString *)returnString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self returnDictionary] options:0 error:nil];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
