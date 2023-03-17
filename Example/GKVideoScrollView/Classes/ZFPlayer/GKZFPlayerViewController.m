//
//  GKZFPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <SDWebImage/SDWebImage.h>
#import "GKZFPortraitView.h"
#import "GKZFLandscapeView.h"

@interface GKZFPlayerViewController ()

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) GKZFPortraitView *portraitView;

@property (nonatomic, strong) GKZFLandscapeView *landscapeView;

@end

@implementation GKZFPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ZFPlayer播放";
    [self initPlayer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    [self.player stop];
}

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
        // 重播
        __strong __typeof(weakSelf) self = weakSelf;
        [self.player.currentPlayerManager replay];
    };
    
    // 加载状态改变回调
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            [self.currentCell.sliderView showLineLoading];
        }else {
            [self.currentCell.sliderView hideLineLoading];
        }
    };
    
    // 播放状态改变
    player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (playState == ZFPlayerPlayStatePaused) {
            self.portraitView.playBtn.hidden = NO;
        }else {
            self.portraitView.playBtn.hidden = YES;
        }
    };
    
    // 播放失败回调
    player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.portraitView.playBtn.hidden = NO;
    };
    
    // 播放进度回调
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.currentCell.sliderView.value = self.player.progress;
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

#pragma mark - Player
- (void)playerVideoWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    GKVideoModel *model = self.dataSources[indexPath.row];
    
    // 记录cell
    self.currentCell = cell;
    [self.landscapeView loadData:model];
    
    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }
    
    // 播放内容一致，不做处理
    if ([self.player.assetURL.absoluteString isEqualToString:model.play_url]) return;
    
    // 设置视频封面图片
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    // 设置播放地址
    self.player.assetURL = [NSURL URLWithString:model.play_url];
}

- (void)stopPlayWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    GKVideoModel *model = self.dataSources[indexPath.row];
    if (![self.player.assetURL.absoluteString isEqualToString:model.play_url]) return;
    
    [self.player stop];
    [cell resetView];
}

- (void)enterFullScreen {
    [self.player enterFullScreen:YES animated:YES];
}

#pragma mark - Lazy
- (GKZFPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKZFPortraitView alloc] init];
        
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
        _landscapeView = [[GKZFLandscapeView alloc] initWithFrame:self.view.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _landscapeView.likeBlock = ^(GKVideoModel *model) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:model];
        };
    }
    return _landscapeView;
}

@end
