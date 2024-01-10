//
//  GKTestViewController.m
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestViewController.h"
#import <GKVideoScrollView/GKVideoScrollView.h>
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import "GKTestCell1.h"
#import "GKTestCell2.h"
#import "GKTestCell3.h"
#import "GKTestCell4.h"

@interface GKTestViewController ()<GKVideoScrollViewDataSource, GKVideoScrollViewDelegate>

@property (nonatomic, strong) GKVideoScrollView *scrollView;

@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UISegmentedControl *pageControl;

@property (nonatomic, strong) UIButton *randomBtn;
@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, strong) NSMutableArray *dataSources;

@end

@implementation GKTestViewController

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
    self.navigationItem.title = @"GKVideoScrollView测试";
    self.view.backgroundColor = UIColor.blackColor;
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.pageLabel];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.randomBtn];
    [self.view addSubview:self.nextBtn];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view).offset(20);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageLabel.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    [self.randomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(self.pageControl.mas_bottom).offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.pageControl.mas_bottom).offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
}

- (void)setupRefresh {
    self.page = 1;
    self.pageSize = 5;
    self.pageControl.selectedSegmentIndex = self.pageSize - 1;
    
    // 设置默认索引
    self.scrollView.defaultIndex = 3;
    
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
    // 模拟数据请求
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.page == 1) {
            [self.dataSources removeAllObjects];
        }
        
        for (NSInteger i = 0; i < self.pageSize; i++) {
            GKTestModel *model = [[GKTestModel alloc] init];
            if (self.page == 1) {
                model.pos = i;
            }else {
                model.pos = self.dataSources.count;
            }
            model.test_id = [NSString stringWithFormat:@"test_id_%zd", (model.pos + 1)];
            [self.dataSources addObject:model];
        }
        
        [self.scrollView.mj_header endRefreshing];
        [self.scrollView.mj_footer endRefreshing];
        if (self.page >= 5) {
            [self.scrollView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self.scrollView reloadData];
    });
}

#pragma mark - Action
- (void)pageControlAction:(UISegmentedControl *)control {
    self.pageSize = control.selectedSegmentIndex + 1;
}

- (void)randomAction {
//    NSInteger random = [self randomIndex];
    NSInteger random = self.dataSources.count - 1;
    [self.scrollView scrollToPageWithIndex:random];
}

- (void)nextAction {
    [self.scrollView scrollToNextPage];
}

- (NSInteger)randomIndex {
    if (self.dataSources.count <= 1) return 0;
    NSInteger random;
    do {
        random = arc4random() % self.dataSources.count;
    } while (random == self.scrollView.currentIndex);
    return random;
}

#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.dataSources.count;
}

- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKTestCell1 *cell = nil;
    if (indexPath.row % 4 == 0) {
        cell = [scrollView dequeueReusableCellWithIdentifier:@"GKTestCell1" forIndexPath:indexPath];
    }else if (indexPath.row % 4 == 1) {
        cell = [scrollView dequeueReusableCellWithIdentifier:@"GKTestCell2" forIndexPath:indexPath];
    }else if (indexPath.row % 4 == 2) {
        cell = [scrollView dequeueReusableCellWithIdentifier:@"GKTestCell3" forIndexPath:indexPath];
    }else if (indexPath.row % 4 == 3) {
        cell = [scrollView dequeueReusableCellWithIdentifier:@"GKTestCell4" forIndexPath:indexPath];
    }
    [cell loadData:self.dataSources[indexPath.row]];
    return cell;
}

#pragma mark - GKVideoScrollViewDelegate
- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"即将显示cell-----%zd---%@", indexPath.row, cell);
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"结束显示cell-----%zd---%@", indexPath.row, cell);
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"滑动结束显示-----%zd---%@", indexPath.row, cell);
    
//    // 模拟自动加载
//    if (self.dataSources.count - self.scrollView.currentIndex <= 5) {
//        self.page++;
//        [self requestData];
//    }
}

#pragma mark - Lazy
- (GKVideoScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GKVideoScrollView alloc] init];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        [_scrollView registerClass:GKTestCell1.class forCellReuseIdentifier:@"GKTestCell1"];
        [_scrollView registerClass:GKTestCell2.class forCellReuseIdentifier:@"GKTestCell2"];
        [_scrollView registerClass:GKTestCell3.class forCellReuseIdentifier:@"GKTestCell3"];
//        [_scrollView registerClass:GKTestCell4.class forCellReuseIdentifier:@"GKTestCell4"];
        [_scrollView registerNib:[UINib nibWithNibName:@"GKTestCell4" bundle:nil] forCellReuseIdentifier:@"GKTestCell4"];
    }
    return _scrollView;
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textColor = UIColor.whiteColor;
        _pageLabel.text = @"页码切换";
    }
    return _pageLabel;
}

- (UISegmentedControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UISegmentedControl alloc] initWithItems:@[@"1页", @"2页", @"3页", @"4页", @"5页"]];
        [_pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
        _pageControl.backgroundColor = UIColor.lightGrayColor;
    }
    return _pageControl;
}

- (UIButton *)randomBtn {
    if (!_randomBtn) {
        _randomBtn = [[UIButton alloc] init];
        _randomBtn.backgroundColor = UIColor.blackColor;
        [_randomBtn setTitle:@"随机切换" forState:UIControlStateNormal];
        [_randomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _randomBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _randomBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        _randomBtn.layer.borderWidth = 1;
        _randomBtn.layer.cornerRadius = 15;
        _randomBtn.layer.masksToBounds = YES;
        [_randomBtn addTarget:self action:@selector(randomAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _randomBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [[UIButton alloc] init];
        _nextBtn.backgroundColor = UIColor.blackColor;
        [_nextBtn setTitle:@"下一个" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _nextBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        _nextBtn.layer.borderWidth = 1;
        _nextBtn.layer.cornerRadius = 15;
        _nextBtn.layer.masksToBounds = YES;
        [_nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

@end
