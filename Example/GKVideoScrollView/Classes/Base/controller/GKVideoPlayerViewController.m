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

@interface GKVideoPlayerViewController ()<GKVideoScrollViewDataSource, GKVideoScrollViewDelegate, GKVideoCellDelegate>

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
    self.navigationItem.title = @"ZFPlayer播放";
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupRefresh {
    self.page = 1;
    self.total = 10;
    self.pageSize = 5;
    
    __weak __typeof(self) weakSelf = self;
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.page = 1;
        [self requestData];
    }];
    
    self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof(weakSelf) self = weakSelf;
        self.page++;
        [self requestData];
    }];
}

- (void)requestData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 好看视频
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/web/video/feed?tab=recommend&act=pcFeed&pd=pc&num=%zd", self.pageSize];
    
    __weak __typeof(self) weakSelf = self;
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ([responseObject[@"errno"] integerValue] == 0) {
            NSArray *list = [GKVideoModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"response"][@"videos"]];
            if (self.page == 1) {
                [self.dataSources removeAllObjects];
            }
            [self.dataSources addObjectsFromArray:list];
            [self.scrollView.mj_header endRefreshing];
            [self.scrollView.mj_footer endRefreshing];
            if (self.page >= self.total) {
                [self.scrollView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.scrollView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.scrollView.mj_header endRefreshing];
        [self.scrollView.mj_footer endRefreshing];
        NSLog(@"%@", error);
    }];
}

#pragma mark - Delegates
#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.dataSources.count;
}

- (UIView *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKVideoCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"GKVideoCell" forIndexPath:indexPath];
    [cell loadData:self.dataSources[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - GKVideoScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentCell scrollViewBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.currentCell scrollViewDidEndDragging];
}

- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // cell隐藏，结束播放
    [self stopPlayWithCell:(GKVideoCell *)cell indexPath:indexPath];
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 滑动结束，播放视频
    [self playerVideoWithCell:(GKVideoCell *)cell indexPath:indexPath];
}

#pragma mark - FSPlayerViewCellDelegate
- (void)cellClickLikeBtn:(GKVideoCell *)cell {
    NSIndexPath *indexPath = [self.scrollView indexPathForCell:cell];
    GKVideoModel *model = self.dataSources[indexPath.row];
    model.isLike = !model.isLike;
    [self.scrollView reloadData];
}

- (void)cellClickFullscreenBtn:(GKVideoCell *)cell {
    [self enterFullScreen];
}

#pragma mark - Player
- (void)playerVideoWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    
}

- (void)stopPlayWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    
}

- (void)enterFullScreen {
    
}

- (void)likeVideoWithModel:(GKVideoModel *)model {
    NSIndexPath *indexPath = [self.scrollView indexPathForCell:self.currentCell];
    GKVideoModel *videoModel = self.dataSources[indexPath.row];
    videoModel.isLike = model ? model.isLike : YES;
    [self.scrollView reloadData];
}

#pragma mark - Lazy
- (GKVideoScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GKVideoScrollView alloc] init];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        [_scrollView registerClass:GKVideoCell.class forCellReuseIdentifier:@"GKVideoCell"];
    }
    return _scrollView;
}

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

@end
