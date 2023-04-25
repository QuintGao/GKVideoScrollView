//
//  GKKuaishouPortraitView.m
//  Example
//
//  Created by QuintGao on 2023/4/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKKuaishouPortraitView.h"

@interface GKKuaishouPortraitView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGFloat beginX;

@end

@implementation GKKuaishouPortraitView

@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//        self.panGesture.delegate = self;
//        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer == self.panGesture) {
//        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
//        CGPoint transition = [panGesture translationInView:panGesture.view];
//        if (transition.x < 0) {
//
//        }else if (transition.x > 0) {
//            if (self.shouldRight) return YES;
//            return NO;
//        }else {
//            return NO;
//        }
//    }
//    return YES;
//}

//- (void)handlePan:(UIPanGestureRecognizer *)gesture {
//    CGPoint translation = [gesture translationInView:gesture.view];
//    
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        self.beginX = translation.x;
//        !self.scrollBlock ?: self.scrollBlock(self.beginX, YES, NO);
//    }else if (gesture.state == UIGestureRecognizerStateChanged) {
//        CGFloat diff = translation.x - self.beginX;
//        !self.scrollBlock ?: self.scrollBlock(diff, NO, NO);
//    }else {
//        CGFloat diff = fabs(translation.x - self.beginX);
//        !self.scrollBlock ?: self.scrollBlock(diff, NO, YES);
//    }
//}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self performSelector:@selector(playPause) withObject:nil afterDelay:0.25];
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playPause) object:nil];
    UIGestureRecognizer *gesture = gestureControl.doubleTap;
    CGPoint point = [gesture locationInView:gesture.view];
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:nil];
    !self.likeBlock ?: self.likeBlock();
}

- (void)playPause {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        self.playBtn.hidden = NO;
    }else {
        [manager play];
        self.playBtn.hidden = YES;
    }
}

@end
