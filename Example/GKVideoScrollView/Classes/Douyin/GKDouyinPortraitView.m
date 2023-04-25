//
//  GKDouyinPortraitView.m
//  Example
//
//  Created by QuintGao on 2023/4/20.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDouyinPortraitView.h"

@interface GKDouyinPortraitView()

@property (nonatomic, weak) SJVideoPlayer *player;

@end

@implementation GKDouyinPortraitView

#pragma mark - SJControlLayer
@synthesize restarted = _restarted;

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    self.player = videoPlayer;
    
    __weak __typeof(self) weakSelf = self;
    self.player.gestureController.singleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.player.isPaused) {
            [self.player play];
            self.playBtn.hidden = YES;
        }else {
            [self.player pauseForUser];
            self.playBtn.hidden = NO;
        }
    };
    
    self.player.gestureController.doubleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.likeView createAnimationWithPoint:location view:self.player.presentView completion:nil];
        !self.likeBlock ?: self.likeBlock();
    };
}

- (void)restartControlLayer {
    _restarted = YES;
}

- (void)exitControlLayer {
    _restarted = NO;
}

@end
