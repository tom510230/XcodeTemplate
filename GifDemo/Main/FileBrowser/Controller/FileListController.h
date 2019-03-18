//
//  FileListController.h
//  GifDemo
//
//  Created by tom on 2019/3/17.
//  Copyright © 2019年 faceu. All rights reserved.
//

#ifndef FileListController_h
#define FileListController_h

#import <UIKit/UIKit.h>
#import "FileModel.h"

@interface FileListController : UIViewController

@property (nonatomic, strong) NSArray<FileModel *>*dataSource;

@end

#endif /* FileListController_h */
