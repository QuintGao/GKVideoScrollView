//
//  GKTimerControl.m
//  Example
//
//  Created by QuintGao on 2023/4/3.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTimerControl.h"

@interface GKTimerControl()
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic) short point;
@end

@implementation GKTimerControl

- (instancetype)init {
    if (self = [super init]) {
        self.interval = 3;
    }
    return self;
}

- (void)setInterval:(NSTimeInterval)interval {
    _interval = interval;
    _point = interval;
}

- (void)resume {
    [self interval];
    _timer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.interval]];
}

- (void)timeAction {
    if ((--self.point) <= 0) {
        [self interrupt];
        !self.exeBlock ?: self.exeBlock(self);
    }
}

- (void)interrupt {
    [_timer invalidate];
    _timer = nil;
    _point = _interval;
}

@end
