//
//  GKZFPlayerManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerManager.h"
#import "GKZFPortraitView.h"
#import "GKZFLandscapeView.h"
#import <SDWebImage/SDWebImage.h>

@interface GKZFPlayerManager()

@property (nonatomic, strong) GKZFPortraitView *portraitView;

@property (nonatomic, strong) GKZFLandscapeView *landscapeView;

@end

@implementation GKZFPlayerManager

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d -- [%@ %s]", (int)__LINE__, NSStringFromClass(self.class), sel_getName(_cmd));
#endif
}

- (void)initPlayer {
    // 初始化播放器
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = YES; // 自动播放
    
    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
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
    
    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.player.controlView.hidden = YES;
        if (player.isFullScreen) {
            [self.landscapeView.statusBar startTimer];
        }else {
            [self.landscapeView.statusBar destoryTimer];
        }
    };
    
    // 方向已经改变
    player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (isFullScreen) {
            self.landscapeView.hidden = NO;
            self.player.controlView = self.landscapeView;
        }else {
            self.portraitView.hidden = NO;
            self.player.controlView = self.portraitView;
        }
    };
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    NSLog(@"播放----%zd", index);
    GKVideoModel *model = self.dataSource[index];
    
    [self.landscapeView loadData:model];
    
    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }
    
    // 设置视频封面图
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    manager.view.coverImageView.image = nil;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    // 播放内容一致，不做处理
    NSString *playUrl = manager.assetURL.absoluteString;
    if (playUrl.length > 0 && [playUrl isEqualToString:model.play_url]) return;
    
    self.player.assetURL = [NSURL URLWithString:model.play_url];
    self.portraitView.playBtn.hidden = YES;
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    NSLog(@"停止---%zd", index);
    GKVideoModel *model = self.dataSource[index];
    
    // 判断播放内容是否一致
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    
    NSString *playUrl = manager.assetURL.absoluteString;
    if (playUrl.length > 0 && ![playUrl isEqualToString:model.play_url]) return;
    
    [self.player stop];
    [cell resetView];
}

- (void)enterFullScreen {
    [self.player enterFullScreen:YES animated:YES];
}

#pragma mark - Lazy
- (GKZFPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKZFPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _portraitView.likeBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:nil];
        };
    }
    return _portraitView;
}

- (GKZFLandscapeView *)landscapeView {
    if (!_landscapeView) {
        _landscapeView = [[GKZFLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _landscapeView.likeBlock = ^(GKVideoModel *model) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:model];
        };
    }
    return _landscapeView;
}

@end
