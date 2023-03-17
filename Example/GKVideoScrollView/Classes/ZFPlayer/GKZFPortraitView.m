//
//  GKZFPortraitView.m
//  Example
//
//  Created by QuintGao on 2023/3/14.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPortraitView.h"

@interface GKZFPortraitView()

@end

@implementation GKZFPortraitView

@synthesize player = _player;

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        self.playBtn.hidden = NO;
    }else {
        [manager play];
        self.playBtn.hidden = YES;
    }
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    UIGestureRecognizer *gesture = gestureControl.doubleTap;
    CGPoint point = [gesture locationInView:gesture.view];
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:nil];
    !self.likeBlock ?: self.likeBlock();
}

@end
