//
//  FileModel.h
//  GifDemo
//
//  Created by tom on 2019/3/17.
//  Copyright © 2019年 faceu. All rights reserved.
//

#ifndef FileModel_h
#define FileModel_h

#import <Foundation/Foundation.h>

@interface FileModel : NSObject

@property (nonatomic, strong) NSMutableArray<FileModel *> *submodels;

@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) NSString *icon;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, assign) NSTimeInterval createTs;

@end

#endif /* FileModel_h */
