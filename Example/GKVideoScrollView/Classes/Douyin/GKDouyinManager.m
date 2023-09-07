//
//  GKDouyinManager.m
//  Example
//
//  Created by QuintGao on 2023/4/4.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDouyinManager.h"
#import "GKDouyinPortraitView.h"
#import "GKDouyinLandscapeView.h"
#import <SDWebImage/SDWebImage.h>
#import "GKRotationManager.h"
#import "GKVideoLandscapeCell.h"

static SJControlLayerIdentifier GKControlLayerPortraitIdentifier = 101;
static SJControlLayerIdentifier GKControlLayerLandscapeIdentifier = 102;

@interface GKDouyinManager()

@property (nonatomic, weak) GKDouyinPortraitView *portraitView;

@property (nonatomic, weak) GKDouyinLandscapeView *landscapeView;

@property (nonatomic, strong) GKRotationManager *rotationManager;

@end

@implementation GKDouyinManager

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
        return [[GKDouyinPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }];
    
    [player.switcher addControlLayerForIdentifier:GKControlLayerLandscapeIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        return [[GKDouyinLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }];
    
    self.portraitView = (GKDouyinPortraitView *)[player.switcher controlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    self.landscapeView = (GKDouyinLandscapeView *)[player.switcher controlLayerForIdentifier:GKControlLayerLandscapeIdentifier];
    
    // 默认显示竖屏
    [player.switcher switchControlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    
    __weak __typeof(self) weakSelf = self;
    self.portraitView.likeBlock = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self likeVideoWithModel:nil];
    };
    
    self.landscapeView.likeBlock = ^(GKVideoModel *model) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self likeVideoWithModel:model];
    };
    
    self.landscapeView.singleTapBlock = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.landscapeCell.isShowTop) {
            [self.landscapeCell hideTopView];
            [self.landscapeView hideContainerView:NO];
        }else {
            [self.landscapeView autoHide];
        }
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
    
    // 播放失败回调
    player.playbackObserver.assetStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
//        __strong __typeof(weakSelf) self = weakSelf;
        if (player.assetStatus == SJAssetStatusFailed) {
//            self.portraitView.playBtn.hidden = NO;
        }
    };
    
    // 播放进度回调
    player.playbackObserver.currentTimeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        CGFloat progress = player.duration == 0 ? 0 : player.currentTime / player.duration;
        [self.currentCell setProgress:progress];
    };
    
    self.rotationManager = [GKRotationManager rotationManager];
    self.rotationManager.contentView = self.player.view;
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
            [self.player.switcher switchControlLayerForIdentifier:GKControlLayerLandscapeIdentifier];
            [(GKVideoLandscapeCell *)self.landscapeCell hideTopView];
        }else {
            self.portraitView.hidden = NO;
            self.landscapeView.hidden = YES;
            [self.player.switcher switchControlLayerForIdentifier:GKControlLayerPortraitIdentifier];
        }
    };
}

- (void)destoryPlayer {
    [self.player stop];
    self.player = nil;
}

- (void)prepareCell:(GKVideoCell *)cell index:(NSInteger)index {
    if ([cell isKindOfClass:GKVideoLandscapeCell.class]) {
        GKVideoLandscapeCell *videoCell = (GKVideoLandscapeCell *)cell;
        [videoCell showTopView];
    }
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    
    [self.landscapeView loadData:model];
    
    if ([cell isKindOfClass:NSClassFromString(@"GKVideoPortriatCell")]) {
        // 记录cell
        self.rotationManager.containerView = cell.coverImgView;
        if (self.rotationManager.isFullscreen) return;
    }else {
        if ([cell isKindOfClass:GKVideoLandscapeCell.class]) {
            [(GKVideoLandscapeCell *)cell autoHide];
        }
        
        [self.portraitScrollView scrollToPageWithIndex:index];
    }
    
    // 设置播放内容视图
    if (self.player.view.superview != cell.coverImgView) {
        self.player.view.frame = cell.coverImgView.bounds;
        [cell.coverImgView addSubview:self.player.view];
    }
    
    // 设置视频封面图
    [self.player.presentView.placeholderImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    self.player.presentView.hidden = NO;
    
    // 播放内容一致，不做处理
    NSString *playUrl = self.player.URLAsset.mediaURL.absoluteString;
    if (playUrl.length > 0 && [playUrl isEqualToString:model.play_url]) return;
    
    // 设置播放地址
    SJVideoPlayerURLAsset *asset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:model.play_url]];
    self.player.URLAsset = asset;
    [self.player play];
    self.portraitView.playBtn.hidden = YES;
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    
    // 判断播放内容是否一致
    NSString *playUrl = self.player.URLAsset.mediaURL.absoluteString;
    if (playUrl.length > 0 && ![playUrl isEqualToString:model.play_url]) return;
    
    [self.player stop];
    self.player.presentView.hidden = YES;
    [cell resetView];
    [self.landscapeView hideContainerView:NO];
}

- (void)enterFullScreen {
    [self.rotationManager rotate];
}

- (void)back {
    [self.rotationManager rotate];
}

@end
