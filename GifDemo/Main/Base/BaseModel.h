//
//  BaseData.h
//  PP理财
//
//  Created by 刘超 on 14-10-15.
//  Copyright (c) 2014年 海浪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
@property (strong ,nonatomic) NSString *ostype;
@property (strong ,nonatomic) NSString *channel;
@property (strong ,nonatomic) NSString *deviceID;
@property (strong ,nonatomic) NSString *mac;
@property (strong ,nonatomic) NSString *phoneType;
@property (strong ,nonatomic) NSString *phoneResolution;
@property (strong ,nonatomic) NSString *version;
@property (strong ,nonatomic) NSString *latitudeLongitude;
@property (strong ,nonatomic) NSString *systemVersion;
@property (assign ,nonatomic) long long startdate;
@property (strong ,nonatomic) NSString *accessToken;

//返回字典
-(NSMutableDictionary *)returnDictionary;
//返回属性的data型数据
-(NSData *)returnData;
//返回属性的NSString型数据
-(NSString *)returnString;
@end
