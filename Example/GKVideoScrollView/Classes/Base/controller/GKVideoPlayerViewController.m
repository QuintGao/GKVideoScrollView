//
//  GKVideoPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPlayerViewController.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/SDWebImage.h>
#import <GKVideoScrollView/GKVideoScrollView.h>

@interface GKVideoPlayerViewController ()

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger pageSize;

@end

@implementation GKVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.manager.portraitScrollView];
    [self.view addSubview:self.manager.workListView];
    
    self.manager.portraitScrollView.frame = self.view.bounds;
    self.manager.workListView.frame = CGRectMake(self.view.bounds.size.width, 80, 62, self.view.bounds.size.height - 160);
}

- (void)setupRefresh {
    self.page = 1;
    self.total = 10;
    self.pageSize = 5;
    
    __weak __typeof(self) weakSelf = self;
    self.manager.portraitScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.page = 1;
        [self requestData];
    }];
    
    self.manager.portraitScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.page++;
        [self requestData];
    }];
}

- (void)requestData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 好看视频
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/video/rec?tab=recommend&act=pcFeed&pd=pc&num=%zd", self.pageSize];
    
    __weak __typeof(self) weakSelf = self;
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ([responseObject[@"errno"] integerValue] == 0) {
            NSArray *list = [GKVideoModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"response"][@"videos"]];
            if (self.page == 1) {
                [self.manager.dataSource removeAllObjects];
            }
            [self.manager.dataSource addObjectsFromArray:list];
            [self.manager.portraitScrollView.mj_header endRefreshing];
            [self.manager.portraitScrollView.mj_footer endRefreshing];
            if (self.page >= self.total) {
                [self.manager.portraitScrollView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.manager reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.manager.portraitScrollView.mj_header endRefreshing];
        [self.manager.portraitScrollView.mj_footer endRefreshing];
        NSLog(@"%@", error);
    }];
}

- (void)likeVideoWithModel:(GKVideoModel *)model {
//    NSIndexPath *indexPath = [self.scrollView indexPathForCell:self.currentCell];
//    GKVideoModel *videoModel = self.dataSources[indexPath.row];
//    videoModel.isLike = model ? model.isLike : YES;
//    [self.scrollView reloadData];
}

@end
