//
//  GKSJPlayerManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKSJPlayerManager.h"
#import "GKSJPortraitView.h"
#import "GKSJLandscapeView.h"
#import <SDWebImage/SDWebImage.h>

static SJControlLayerIdentifier GKControlLayerPortraitIdentifier = 101;
static SJControlLayerIdentifier GKControlLayerLandscapeIdentifier = 102;

@interface GKSJPlayerManager()

@property (nonatomic, weak) GKSJPortraitView *portraitView;

@property (nonatomic, weak) GKSJLandscapeView *landscapeView;

@end

@implementation GKSJPlayerManager

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d -- [%@ %s]", (int)__LINE__, NSStringFromClass(self.class), sel_getName(_cmd));
#endif
}

- (void)initPlayer {
    SJVideoPlayer *player = [SJVideoPlayer player];
    self.player = player;
    
    player.view.backgroundColor = UIColor.blackColor;
    player.presentView.backgroundColor = UIColor.blackColor;
    player.controlLayerAppearManager.disabled = YES;
    player.presentView.placeholderImageViewContentMode = UIViewContentModeScaleAspectFit;
    player.videoGravity = AVLayerVideoGravityResizeAspect;
    player.autoplayWhenSetNewAsset = NO;
    player.rotationManager.disabledAutorotation = YES;
    player.pausedInBackground = YES;
    player.resumePlaybackWhenScrollAppeared = NO;
    player.resumePlaybackWhenAppDidEnterForeground = NO;
    player.automaticallyHidesPlaceholderImageView = YES;
    player.gestureController.supportedGestureTypes = SJPlayerGestureTypeMask_SingleTap | SJPlayerGestureTypeMask_DoubleTap;
    
    [player.switcher addControlLayerForIdentifier:GKControlLayerPortraitIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        return [[GKSJPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }];
    
    [player.switcher addControlLayerForIdentifier:GKControlLayerLandscapeIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        return [[GKSJLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }];
    
    // 默认显示竖屏
    [player.switcher switchControlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    
    __weak __typeof(self) weakSelf = self;
    
    self.portraitView = (GKSJPortraitView *)[player.switcher controlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    self.portraitView.likeBlock = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self likeVideoWithModel:nil];
    };
    
    self.landscapeView = (GKSJLandscapeView *)[player.switcher controlLayerForIdentifier:GKControlLayerLandscapeIdentifier];
    self.landscapeView.likeBlock = ^(GKVideoModel *model) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self likeVideoWithModel:model];
    };
    
    // 播放结束回调
    player.playbackObserver.playbackDidFinishExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.player replay];
    };
    
    // 加载状态改变回调
    player.playbackObserver.timeControlStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (player.timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay) {
            [self.currentCell showLoading];
        }else {
            [self.currentCell hideLoading];
        }
    };
    
//    // 播放失败回调
//    player.playbackObserver.assetStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
//        __strong __typeof(weakSelf) self = weakSelf;
//        if (player.assetStatus == SJAssetStatusFailed) {
////            self.portraitView.playBtn.hidden = NO;
//        }
//    };
    
    // 播放进度回调
    player.playbackObserver.currentTimeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        CGFloat progress = player.duration == 0 ? 0 : player.currentTime / player.duration;
        [self.currentCell setProgress:progress];
    };
    
    // 方向改变回调
    player.rotationObserver.onRotatingChanged = ^(id<SJRotationManager>  _Nonnull mgr, BOOL isRotating) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (isRotating) {
            if (mgr.isFullscreen) {
                [self.landscapeView.statusBar startTimer];
                [self.player.switcher switchControlLayerForIdentifier:GKControlLayerLandscapeIdentifier];
            }else {
                [self.landscapeView.statusBar destoryTimer];
                [self.player.switcher switchControlLayerForIdentifier:GKControlLayerPortraitIdentifier];
            }
        }else {
            if (mgr.isFullscreen) {
                self.portraitView.hidden = YES;
                self.landscapeView.hidden = NO;
            }else {
                self.landscapeView.hidden = YES;
                self.portraitView.hidden = NO;
            }
        }
    };
}

- (void)destoryPlayer {
    [self.player stop];
    self.player = nil;
}

#pragma mark - Player
- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    
    // 记录cell
    [self.landscapeView loadData:model];
    
    // 设置播放视图
    if (self.player.view.superview != cell.coverImgView) {
        self.player.view.frame = cell.coverImgView.bounds;
        [cell.coverImgView addSubview:self.player.view];
    }
    
    // 播放内容一致，不做处理
    if ([self.player.URLAsset.mediaURL.absoluteString isEqualToString:model.play_url]) return;
    
    // 设置封面图片
    [self.player.presentView.placeholderImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    self.player.presentView.hidden = NO;
    
    // 设置播放地址
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:model.play_url]];
    self.player.URLAsset = asset;
    [self.player play];
    self.portraitView.playBtn.hidden = YES;
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    if (![self.player.URLAsset.mediaURL.absoluteString isEqualToString:model.play_url]) return;
    
    [self.player stop];
    self.player.presentView.hidden = YES;
    [cell resetView];
}

- (void)enterFullScreen {
    [self.player rotate:SJOrientation_LandscapeLeft animated:YES];
}

@end
