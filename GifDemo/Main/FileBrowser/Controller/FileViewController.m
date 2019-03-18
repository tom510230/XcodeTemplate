//
//  FileViewController.m
//  GifDemo
//
//  Created by tom on 2019/3/17.
//  Copyright © 2019年 faceu. All rights reserved.
//

#import "FileViewController.h"
#import "FileModel.h"
#import "FileListController.h"

#define KCELL_IDENTIFIER @"file_cell"

@interface FileViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FileViewController
{
    NSMutableArray<FileModel *>*_datasource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasource = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadFile];
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KCELL_IDENTIFIER];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)loadFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"bundle"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    
    NSArray<NSString *> *names = [manager contentsOfDirectoryAtPath:filePath error:&error];
    NSLog(@"【读取文件】：文件名 %@， 错误：%@", names, error);
    
    NSDictionary<NSFileAttributeKey, id> *attrs = [manager attributesOfItemAtPath:filePath error:&error];
    NSLog(@"【读取文件】：属性名 %@， 错误：%@", attrs, error);
    
    NSArray<NSURL *>*urls = [manager contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsPackageDescendants error:&error];
    
    __weak typeof(self) weakSelf = self;
    [urls enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileModel *model = [weakSelf modelAtURL:obj];
        [_datasource addObject:model];
    }];
}

- (FileModel *)modelAtURL:(NSURL *)url {
    FileModel *model = [FileModel new];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileName = [manager displayNameAtPath:url.absoluteString];
    model.filename = fileName;
    NSDictionary<NSFileAttributeKey, id> *attrs = [manager attributesOfItemAtPath:url.absoluteString error:nil];
    NSLog(@"【读取文件】：文件名 %@， 属性：%@", fileName, attrs);
    
    NSArray<NSURL *>*subs = [manager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:nil];
    if (subs.count > 0) {
        NSMutableArray<FileModel *>*models = [NSMutableArray arrayWithCapacity:subs.count];
        [subs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [models addObject:[self modelAtURL:obj]];
        }];
        model.submodels = models;
        model.icon = @"folder";
    } else {
        model.icon = @"file";
    }
    return model;
}

- (NSArray<NSString *>*)URLsAtURL:(NSURL *)url {
    return [[NSFileManager defaultManager] subpathsAtPath:url.absoluteString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCELL_IDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KCELL_IDENTIFIER];
    }
    FileModel *model = _datasource[indexPath.row];
    cell.textLabel.text = model.filename;
    cell.imageView.image = [UIImage imageNamed:model.icon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _datasource[indexPath.row];
    if (model.submodels.count > 0) {
        // 下级目录
        FileListController *list = [[FileListController alloc] init];
        list.dataSource = model.submodels;
        [self.navigationController pushViewController:list animated:YES];
    } else {
        // 详情
    }
}


@end
