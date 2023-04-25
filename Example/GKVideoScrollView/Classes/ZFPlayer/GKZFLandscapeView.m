//
//  GKZFLandscapeView.m
//  Example
//
//  Created by QuintGao on 2023/3/14.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFLandscapeView.h"

@interface GKZFLandscapeView()

@end

@implementation GKZFLandscapeView

- (void)backAction {
//    [self.player enterFullScreen:!self.player.isFullScreen animated:YES];
    if (self.rotationManager) {
        [self.rotationManager rotate];
    }else {
        [self.player enterFullScreen:!self.player.isFullScreen animated:YES];
    }
}

- (void)playAction {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
    }else {
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
}

#pragma mark - ZFPlayerMediaControl
@synthesize player = _player;

- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    
    self.playBtn.selected = player.currentPlayerManager.isPlaying;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (videoPlayer.isFullScreen) {
        [self showContainerView:NO];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
        [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
    }
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
    if (self.isContainerShow) {
        [self hideContainerView:YES];
    }else {
        [self showContainerView:YES];
        [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
    }
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
    
    UIGestureRecognizer *gesture = gestureControl.doubleTap;
    CGPoint point = [gesture locationInView:gesture.view];
    
    __weak __typeof(self) weakSelf = self;
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
    }];
    self.model.isLike = YES;
    self.likeBtn.selected = self.model.isLike;
    !self.likeBlock ?: self.likeBlock(self.model);
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer reachabilityChanged:(ZFReachabilityStatus)status {
    NSString *net = @"WIFI";
    switch (status) {
        case ZFReachabilityStatusReachableViaWiFi:
            net = @"WIFI";
            break;
        case ZFReachabilityStatusNotReachable:
            net = @"无网络";
            break;
        case ZFReachabilityStatusReachableVia2G:
            net = @"2G";
            break;
        case ZFReachabilityStatusReachableVia3G:
            net = @"3G";
            break;
        case ZFReachabilityStatusReachableVia4G:
            net = @"4G";
            break;
        case ZFReachabilityStatusReachableVia5G:
            net = @"5G";
            break;
        default:
            net = @"未知";
            break;
    }
    self.statusBar.network = net;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (self.isDragging) return;
    if (self.isSeeking) return;
    self.sliderView.value = self.player.progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%@  /  %@", [self convertTimeSecond:currentTime], [self convertTimeSecond:totalTime]];
}

- (void)draggingEnded {
    self.isSeeking = YES;
    NSTimeInterval time = self.player.currentPlayerManager.totalTime * self.sliderView.value;
    
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.isSeeking = NO;
    }];
}

@end
