//
//  GKVideoScrollView.h
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/2/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GKVideoScrollView, GKVideoControlView;

@protocol GKVideoScrollViewDataSource <NSObject>

// 内容总数
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView;

// 设置cell
- (UIView *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol GKVideoScrollViewDelegate <NSObject, UIScrollViewDelegate>

@optional

// cell即将显示时调用，可用于请求播放信息
- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// cell结束显示时调用，可用于结束播放
- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// 结束滑动时显示的cell，可在这里开始播放
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GKVideoScrollView : UIScrollView

// 数据源
@property (nonatomic, weak) id<GKVideoScrollViewDataSource> dataSource;

// 代理
@property (nonatomic, weak) id<GKVideoScrollViewDelegate> delegate;

// 默认索引
@property (nonatomic, assign) NSInteger defaultIndex;

// 当前索引
@property (nonatomic, assign, readonly) NSInteger currentIndex;

// 可视cells
@property (nonatomic, readonly) NSArray <__kindof UIView *> *visibleCells;

// 获取行数
- (NSInteger)numberOfRows;

// 获取cell对应的indexPath
- (nullable NSIndexPath *)indexPathForCell:(UIView *)cell;

// 获取indexPath对应的cell
- (nullable __kindof UIView *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 注册cell
- (void)registerClass:(nonnull Class)cellClass forCellReuseIdentifier:(nonnull NSString *)identifier;

// 获取可复用的cell
- (__kindof UIView *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(nonnull NSIndexPath *)indexPath;

// 刷新数据
- (void)reloadData;

// 切换到指定索引页面，无动画
- (void)scrollToPageWithIndex:(NSInteger)index;

// 切换到下个页面，有动画
- (void)scrollToNextPage;

@end

NS_ASSUME_NONNULL_END
