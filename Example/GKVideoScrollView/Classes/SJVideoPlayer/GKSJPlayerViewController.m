//
//  GKSJPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKSJPlayerViewController.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "GKVideoPortraitView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "GKSJPortraitView.h"
#import "GKSJLandscapeView.h"

static SJControlLayerIdentifier GKControlLayerPortraitIdentifier = 101;
static SJControlLayerIdentifier GKControlLayerLandscapeIdentifier = 102;

@interface GKSJPlayerViewController ()

@property (nonatomic, strong) SJVideoPlayer *player;

@property (nonatomic, weak) GKSJPortraitView *portraitView;

@property (nonatomic, weak) GKSJLandscapeView *landscapeView;

@end

@implementation GKSJPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"SJVideoPlayer播放";
    [self initPlayer];
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
        return [[GKSJPortraitView alloc] initWithFrame:self.view.bounds];
    }];
    
    [player.switcher addControlLayerForIdentifier:GKControlLayerLandscapeIdentifier lazyLoading:^id<SJControlLayer> _Nonnull(SJControlLayerIdentifier identifier) {
        return [[GKSJLandscapeView alloc] initWithFrame:self.view.bounds];
    }];
    
    // 默认显示竖屏
    [player.switcher switchControlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    
    self.portraitView = (GKSJPortraitView *)[player.switcher controlLayerForIdentifier:GKControlLayerPortraitIdentifier];
    self.landscapeView = (GKSJLandscapeView *)[player.switcher controlLayerForIdentifier:GKControlLayerLandscapeIdentifier];
    
    __weak __typeof(self) weakSelf = self;
    
    self.portraitView.likeBlock = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self likeVideoWithModel:nil];
    };
    
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
            [self.currentCell.sliderView showLineLoading];
        }else {
            [self.currentCell.sliderView hideLineLoading];
        }
    };
    
    // 播放失败回调
    player.playbackObserver.assetStatusDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (player.assetStatus == SJAssetStatusFailed) {
            self.portraitView.playBtn.hidden = NO;
        }
    };
    
    // 播放进度回调
    player.playbackObserver.currentTimeDidChangeExeBlock = ^(__kindof SJBaseVideoPlayer * _Nonnull player) {
        __strong __typeof(weakSelf) self = weakSelf;
        CGFloat progress = player.duration == 0 ? 0 : player.currentTime / player.duration;
        self.currentCell.sliderView.value = progress;
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

#pragma mark - Player
- (void)playerVideoWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    GKVideoModel *model = self.dataSources[indexPath.row];
    
    // 记录cell
    self.currentCell = cell;
    [self.landscapeView loadData:model];
    
    // 设置播放视图
    if (self.player.view.superview != cell.coverImgView) {
        [cell.coverImgView addSubview:self.player.view];
        
        [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.coverImgView);
        }];
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
}

- (void)stopPlayWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath {
    GKVideoModel *model = self.dataSources[indexPath.row];
    if (![self.player.URLAsset.mediaURL.absoluteString isEqualToString:model.play_url]) return;
    
    [self.player stop];
    self.player.presentView.hidden = YES;
    [cell resetView];
}

- (void)enterFullScreen {
    [self.player rotate:SJOrientation_LandscapeLeft animated:YES];
}

@end
