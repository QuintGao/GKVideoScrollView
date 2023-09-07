//
//  GKVideoManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoManager.h"
#import "GKVideoPortriatCell.h"
#import "GKVideoLandscapeCell.h"

@interface GKVideoManager()<GKVideoScrollViewDataSource, GKVideoScrollViewDelegate, GKVideoCellDelegate>

@end

@implementation GKVideoManager

- (instancetype)init {
    if (self = [super init]) {
        [self initPlayer];
    }
    return self;
}

- (void)initLandscapeView {
    self.landscapeScrollView = [[GKVideoScrollView alloc] init];
    self.landscapeScrollView.backgroundColor = UIColor.blackColor;
    self.landscapeScrollView.dataSource = self;
    self.landscapeScrollView.delegate = self;
    [self.landscapeScrollView registerClass:GKVideoLandscapeCell.class forCellReuseIdentifier:@"GKVideoLandscapeCell"];
}

#pragma mark - Public
- (void)initPlayer {
    // subclass implementation
}

- (void)destoryPlayer {
    // subclass implementation
}

- (void)prepareCell:(GKVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)preloadVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    // subclass implementation
}

- (void)enterFullScreen {
    // subclass implementation
}

- (void)back {
    // subclass implementation
}

- (void)reloadData {
    [self.portraitScrollView reloadData];
    [self.landscapeScrollView reloadData];
}

- (void)reloadDataWithIndex:(NSInteger)index {
    [self.portraitScrollView reloadDataWithIndex:index];
    [self.landscapeScrollView reloadDataWithIndex:index];
}

- (void)likeVideoWithModel:(GKVideoModel *)model {
    if (model == nil) {
        model = self.dataSource[self.portraitScrollView.currentIndex];
        model.isLike = YES;
    }
    [self.portraitScrollView reloadData];
    [self.landscapeScrollView reloadData];
}

- (void)removeCurrent {
//    [self.portraitScrollView removeCurrentPage];
//    [self.dataSource removeObjectAtIndex:self.portraitScrollView.currentIndex];
//    [self.portraitScrollView reloadData];
    [self.portraitScrollView removeCurrentPageAnimated:YES];
}

#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.dataSource.count;
}

- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = scrollView == self.portraitScrollView ? @"GKVideoPortriatCell" : @"GKVideoLandscapeCell";
    GKVideoCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell loadData:self.dataSource[indexPath.row]];
    cell.delegate = self;
    [self prepareCell:cell index:indexPath.row];
    return cell;
}

#pragma mark - GKVideoScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.currentCell scrollViewBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.currentCell scrollViewDidEndDragging];
}

// 即将显示
- (void)scrollView:(GKVideoScrollView *)scrollView willDisplayCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self preloadVideoWithCell:(GKVideoCell *)cell index:indexPath.row];
}

// 结束显示
- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self stopVideoWithCell:(GKVideoCell *)cell index:indexPath.row];
}

// 滑动结束显示
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (scrollView == self.portraitScrollView) {
        self.currentCell = (GKVideoCell *)cell;
        self.currentIndex = indexPath.row;
    }else if (scrollView == self.landscapeScrollView) {
        self.landscapeCell = (GKVideoLandscapeCell *)cell;
    }
    [self playVideoWithCell:(GKVideoCell *)cell index:indexPath.row];
}

- (void)scrollView:(GKVideoScrollView *)scrollView didRemoveCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= 0 && indexPath.row < self.dataSource.count) {
        [self.dataSource removeObjectAtIndex:indexPath.row];
    }
}

#pragma mark - GKVideoCellDelegate
- (void)cellClickBackBtn {
    [self back];
}

- (void)cellClickLikeBtn:(GKVideoCell *)cell {
    
}

- (void)cellClickFullscreenBtn:(GKVideoCell *)cell {
    [self enterFullScreen];
}

#pragma mark - Lazy
- (GKVideoScrollView *)portraitScrollView {
    if (!_portraitScrollView) {
        _portraitScrollView = [[GKVideoScrollView alloc] init];
        _portraitScrollView.dataSource = self;
        _portraitScrollView.delegate = self;
        [_portraitScrollView registerClass:GKVideoPortriatCell.class forCellReuseIdentifier:@"GKVideoPortriatCell"];
    }
    return _portraitScrollView;
}

- (GKVideoWorkListView *)workListView {
    if (!_workListView) {
        _workListView = [[GKVideoWorkListView alloc] init];
    }
    return _workListView;
}

//- (GKVideoScrollView *)landscapeScrollView {
//    if (!_landscapeScrollView) {
//        _landscapeScrollView = [[GKVideoScrollView alloc] init];
//        _landscapeScrollView.dataSource = self;
//        _landscapeScrollView.delegate = self;
//        [_landscapeScrollView registerClass:GKVideoLandscapeCell.class forCellReuseIdentifier:@"GKVideoLandscapeCell"];
//    }
//    return _landscapeScrollView;
//}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
