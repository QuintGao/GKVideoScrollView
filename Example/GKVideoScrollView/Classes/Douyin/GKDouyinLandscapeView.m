//
//  GKDouyinLandscapeView.m
//  Example
//
//  Created by QuintGao on 2023/4/20.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDouyinLandscapeView.h"

@interface GKDouyinLandscapeView()

@property (nonatomic, weak) SJVideoPlayer *player;

@end

@implementation GKDouyinLandscapeView

- (void)clickFullScreenBtn {
    [self backAction];
}

- (void)backAction {
    if (self.rotationManager) {
        [self.rotationManager rotate];
    }else {
        [self.player rotate:SJOrientation_Portrait animated:YES];
    }
}

- (void)playAction {
    if (self.player.isPaused) {
        [self.player play];
    }else {
        [self.player pauseForUser];
    }
    self.playBtn.selected = self.player.isPlaying;
}

#pragma mark - SJControlLayer
@synthesize restarted = _restarted;

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self.player = videoPlayer;
    self.playBtn.selected = self.player.isPlaying;
    
    __weak __typeof(self) weakSelf = self;
    self.player.gestureController.singleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
//        __strong __typeof(weakSelf) self = weakSelf;
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
//        if (self.isContainerShow) {
//            [self hideContainerView:YES];
//        }else {
//            [self showContainerView:YES];
//            [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
//        }
        !self.singleTapBlock ?: self.singleTapBlock();
    };
    
    self.player.gestureController.doubleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong __typeof(weakSelf) self = weakSelf;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
        
        [self.likeView createAnimationWithPoint:location view:self.player.presentView completion:^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
        }];;
        self.model.isLike = YES;
        self.likeBtn.selected = self.model.isLike;
        !self.likeBlock ?: self.likeBlock(self.model);
    };
}

- (void)restartControlLayer {
    _restarted = YES;
}

- (void)exitControlLayer {
    _restarted = NO;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    self.hidden = YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    
}

- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    BOOL(^_locationInTheView)(UIView *) = ^BOOL(UIView *container) {
        return CGRectContainsPoint(container.frame, location);
    };
    
    if (_locationInTheView(self.topContainerView)) {
        return NO;
    }else if (_locationInTheView(self.bottomContainerView)) {
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    NSString *net = @"WIFI";
    switch (status) {
        case SJNetworkStatus_NotReachable:
            net = @"无网络";
            break;
        case SJNetworkStatus_ReachableViaWWAN:
            net = @"蜂窝网络";
            break;
        case SJNetworkStatus_ReachableViaWiFi:
            net = @"WIFI";
            break;
        default:
            net = @"未知";
            break;
    }
    self.statusBar.network = net;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTimeDidChange:(NSTimeInterval)currentTime {
    if (self.isDragging) return;
    if (self.isSeeking) return;
    CGFloat progress = videoPlayer.duration == 0 ? 0 : currentTime / videoPlayer.duration;
    self.sliderView.value = progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%@  /  %@", [self convertTimeSecond:currentTime], [self convertTimeSecond:videoPlayer.duration]];
}

- (void)draggingEnded {
    self.isSeeking = YES;
    NSTimeInterval time = self.player.duration * self.sliderView.value;
    
    __weak __typeof(self) weakSelf = self;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.isSeeking = NO;
    }];
}

- (void)autoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView:) object:@(YES)];
    if (self.isContainerShow) {
        [self hideContainerView:YES];
    }else {
        [self showContainerView:YES];
        [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
    }
}

@end
