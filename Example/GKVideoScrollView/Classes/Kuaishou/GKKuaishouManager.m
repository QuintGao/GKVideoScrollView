//
//  GKKuaishouManager.m
//  Example
//
//  Created by QuintGao on 2023/4/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKKuaishouManager.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <SDWebImage/SDWebImage.h>
#import "GKKuaishouPortraitView.h"
#import "GKKuaishouLandscapeView.h"
#import "GKRotationManager.h"

@interface GKKuaishouManager()

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) GKKuaishouPortraitView *portraitView;

@property (nonatomic, strong) GKKuaishouLandscapeView *landscapeView;

@property (nonatomic, strong) GKRotationManager *rotationManager;

@property (nonatomic, assign) CGFloat beginX;

@end

@implementation GKKuaishouManager

- (void)initPlayer {
    // 初始化播放器
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = YES; // 自动播放
    
    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
    player.disableGestureTypes =  ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO;
    self.player = player;
    
    // 设置竖屏controlView
    self.player.controlView = self.portraitView;
    
    __weak __typeof(self) weakSelf = self;
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        __strong __typeof(weakSelf) self = weakSelf;
        // 重播
        [self.player.currentPlayerManager replay];
    };
    
    // 加载状态改变回调
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            [self.currentCell showLoading];
        }else {
            [self.currentCell hideLoading];
        }
    };
    
    // 播放进度回调
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.currentCell setProgress:self.player.progress];
    };
    
    // 旋转控制
    self.rotationManager = [GKRotationManager rotationManager];
    self.rotationManager.contentView = self.player.currentPlayerManager.view;
    self.landscapeView.rotationManager = self.rotationManager;
    
    self.rotationManager.orientationWillChange = ^(BOOL isFullscreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (isFullscreen) {
            [self.landscapeView.statusBar startTimer];
        }else {
            [self.landscapeView.statusBar destoryTimer];
            self.landscapeView.hidden = YES;
            if (self.landscapeScrollView) {
                UIView *superview = self.landscapeScrollView.superview;
                [superview addSubview:self.rotationManager.contentView];
                [self.landscapeScrollView removeFromSuperview];
                self.landscapeScrollView = nil;
                self.landscapeCell = nil;
            }
        }
    };
    
    self.rotationManager.orientationDidChanged = ^(BOOL isFullscreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (isFullscreen) {
            self.portraitView.hidden = YES;
            self.landscapeView.hidden = NO;
            [self.landscapeView hideContainerView:NO];
            if (!self.landscapeScrollView) {
                [self initLandscapeView];
                UIView *superview = self.rotationManager.contentView.superview;
                self.landscapeScrollView.frame = superview.bounds;
                [superview addSubview:self.landscapeScrollView];
                self.landscapeScrollView.defaultIndex = self.portraitScrollView.currentIndex;
                [self.landscapeScrollView reloadData];
            }
            self.player.controlView = self.landscapeView;
            [(GKVideoLandscapeCell *)self.landscapeCell hideTopView];
        }else {
            self.portraitView.hidden = NO;
            self.landscapeView.hidden = YES;
            self.player.controlView = self.portraitView;
            if (self.player.containerView != self.currentCell.coverImgView) {
                self.player.containerView = self.currentCell.coverImgView;
            }
        }
    };
}

- (void)prepareCell:(GKVideoCell *)cell index:(NSInteger)index {
    if ([cell isKindOfClass:GKVideoLandscapeCell.class]) {
        [(GKVideoLandscapeCell *)cell showTopView];
    }
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    [self.landscapeView loadData:model];

    if ([cell isKindOfClass:NSClassFromString(@"GKVideoPortriatCell")]) {
        self.rotationManager.containerView = cell.coverImgView;
        if (self.rotationManager.isFullscreen) return;
    }else {
        if ([cell isKindOfClass:GKVideoLandscapeCell.class]) {
            [(GKVideoLandscapeCell *)cell autoHide];
        }
        [self.portraitScrollView scrollToPageWithIndex:index];
    }

    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }

    // 设置视频封面图
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];

    // 播放内容一致，不做处理
    NSString *playUrl = self.player.assetURL.absoluteString;
    if (playUrl.length > 0 && [playUrl isEqualToString:model.play_url]) return;

    self.player.assetURL = [NSURL URLWithString:model.play_url];
    self.portraitView.playBtn.hidden = YES;
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    
    // 判断播放内容是否一致
    NSString *playUrl = self.player.assetURL.absoluteString;
    if (playUrl.length > 0 && ![playUrl isEqualToString:model.play_url]) return;
    
    [self.player stop];
    [cell resetView];
}

- (void)enterFullScreen {
    [self.rotationManager rotate];
}

- (void)back {
    [self.rotationManager rotate];
}

- (void)handleScroll:(CGFloat)distance isBegin:(BOOL)isBegin isEnd:(BOOL)isEnd {
    CGFloat width = self.workListView.superview.frame.size.width;
    CGFloat maxW = self.workListView.frame.size.width;
    if (isBegin) {
        self.beginX = self.workListView.frame.origin.x;
    }else if (isEnd) {
        CGFloat diff = width - self.workListView.frame.origin.x;
        if (diff >= maxW / 2) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.workListView.frame;
                frame.origin.x = width - maxW;
                self.workListView.frame = frame;
            } completion:^(BOOL finished) {
                self.portraitView.shouldRight = YES;
            }];
        }else {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.workListView.frame;
                frame.origin.x = width;
                self.workListView.frame = frame;
            } completion:^(BOOL finished) {
                self.portraitView.shouldRight = NO;
            }];
        }
    }else {
        if (distance > 0) { // 右滑
            if (self.beginX >= width) return;
            CGFloat x = width - maxW + distance;
            if (x >= width) {
                x = width;
            }
            CGRect frame = self.workListView.frame;
            frame.origin.x = x;
            self.workListView.frame = frame;
        }else { // 左滑
            if (self.beginX < width) return;
            CGFloat x = width + distance;
            if (x <= width - maxW) {
                x = width - maxW;
            }
            CGRect frame = self.workListView.frame;
            frame.origin.x = x;
            self.workListView.frame = frame;
        }
    }
}

#pragma mark - lazy
- (GKKuaishouPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKKuaishouPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _portraitView.likeBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:nil];
        };
        
        _portraitView.scrollBlock = ^(CGFloat distance, BOOL isBegin, BOOL isEnd) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self handleScroll:distance isBegin:isBegin isEnd:isEnd];
        };
    }
    return _portraitView;
}

- (GKKuaishouLandscapeView *)landscapeView {
    if (!_landscapeView) {
        _landscapeView = [[GKKuaishouLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _landscapeView.likeBlock = ^(GKVideoModel *model) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:model];
        };
        
        _landscapeView.singleTapBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            if (self.landscapeCell.isShowTop) {
                [self.landscapeCell hideTopView];
                [self.landscapeView hideContainerView:NO];
            }else {
                [self.landscapeView autoHide];
            }
        };
    }
    return _landscapeView;
}

@end
