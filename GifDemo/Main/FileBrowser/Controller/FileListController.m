//
//  FileListController.m
//  GifDemo
//
//  Created by tom on 2019/3/17.
//  Copyright © 2019年 faceu. All rights reserved.
//

#import "FileListController.h"

#define KCELL_IDENTIFIER @"file_cell"

@interface FileListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;

@end

@implementation FileListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)setDataSource:(NSArray<FileModel *> *)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self.tableView reloadData];
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KCELL_IDENTIFIER];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KCELL_IDENTIFIER];
    }
    FileModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.filename;
    cell.imageView.image = [UIImage imageNamed:model.icon];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = _dataSource[indexPath.row];
    if (model.submodels.count > 0) {
        // 下级目录
        FileListController *list = [[FileListController alloc] init];
        list.dataSource = model.submodels;
        [self.navigationController pushViewController:list animated:YES];
    } else {
        // 详情
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
