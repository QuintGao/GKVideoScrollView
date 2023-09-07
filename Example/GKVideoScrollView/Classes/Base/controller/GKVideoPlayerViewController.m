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

@property (nonatomic, assign) BOOL isInsertFront;
 
@end

@implementation GKVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
}

- (void)dealloc {
    [self.manager destoryPlayer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.manager.portraitScrollView.frame = self.view.bounds;
}

- (void)initUI {
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.manager.portraitScrollView];
    
    self.manager.portraitScrollView.frame = self.view.bounds;
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
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.page++;
        [self requestData];
    }];
    footer.automaticallyRefresh = NO;
    self.manager.portraitScrollView.mj_footer = footer;
}

- (void)requestNewData {
    self.page = 1;
    [self requestData];
}

- (void)requestNewDataInsertFront {
    self.isInsertFront = YES;
    [self requestData];
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
            if (self.isInsertFront) {
                self.isInsertFront = NO;
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, list.count)];
                [self.manager.dataSource insertObjects:list atIndexes:indexSet];
                
                [self.manager.portraitScrollView.mj_header endRefreshing];
                [self.manager.portraitScrollView.mj_footer endRefreshing];
                if (self.page >= self.total) {
                    [self.manager.portraitScrollView.mj_footer endRefreshingWithNoMoreData];
                }
                
                NSInteger index = list.count + self.manager.currentIndex;
                [self.manager reloadDataWithIndex:index];
            }else {
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
