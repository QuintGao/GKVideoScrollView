//
//  GKTableViewController.m
//  Example
//
//  Created by QuintGao on 2023/8/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTableViewController.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "GKRotationManager.h"
#import <SJBaseVideoPlayer/SJRotationManager.h>

@interface GKTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) GKRotationManager *manager;

@property (nonatomic, strong) SJRotationManager *sjManager;

@end

@implementation GKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.title = @"UITableView";
//    
//    [self.view addSubview:self.tableView];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//    
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self requestData];
//    }];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.manager = GKRotationManager.rotationManager;
    self.manager.allowOrientationRotation = YES;
    
//    self.sjManager = SJRotationManager.rotationManager;
    
    UIView *containerView = [[UIView alloc] init];
    containerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 9 / 16);
    containerView.center = self.view.center;
    [self.view addSubview:containerView];
    self.manager.containerView = containerView;
    self.sjManager.superview = containerView;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = containerView.bounds;
    [containerView addSubview:contentView];
    contentView.backgroundColor = UIColor.redColor;
    self.manager.contentView = contentView;
    self.sjManager.target = contentView;
    
    UIButton *rotateBtn = [[UIButton alloc] init];
    [rotateBtn setTitle:@"GKRotationManager" forState:UIControlStateNormal];
    rotateBtn.frame = CGRectMake(40, 40, 120, 80);
    rotateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [contentView addSubview:rotateBtn];
    rotateBtn.backgroundColor = UIColor.grayColor;
    [rotateBtn addTarget:self action:@selector(rotateAction:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *sjRotateBtn = [[UIButton alloc] init];
//    [sjRotateBtn setTitle:@"SJRotationManager" forState:UIControlStateNormal];
//    sjRotateBtn.frame = CGRectMake(200, 40, 120, 80);
//    sjRotateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//    [contentView addSubview:sjRotateBtn];
//    sjRotateBtn.backgroundColor = UIColor.grayColor;
//    [sjRotateBtn addTarget:self action:@selector(rotateAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)rotateAction:(UIButton *)btn {
    if ([btn.currentTitle isEqualToString:@"GKRotationManager"]) {
        [self.manager rotate];
    }else {
        [self.sjManager rotate];
    }
}

- (void)requestData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.count = 10;
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cell);
    }];
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行", indexPath.row + 1];
    cell.contentView.backgroundColor = UIColor.grayColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"即将显示cell----%zd", indexPath.row + 1);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"结束显示cell-----%zd", indexPath.row + 1);
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = self.view.bounds.size.height;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.pagingEnabled = YES;
    }
    return _tableView;
}

@end
