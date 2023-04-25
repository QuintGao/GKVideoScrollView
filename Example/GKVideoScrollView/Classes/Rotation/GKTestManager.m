//
//  GKTestManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestManager.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "GKRotationManager.h"

@interface GKTestManager()

@property (nonatomic, strong) GKRotationManager *rotationManager;

@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) UIImageView *coverView;

@end

@implementation GKTestManager

- (void)initPlayer {
    self.rotationManager = [GKRotationManager rotationManager];
    self.rotationManager.allowOrientationRotation = YES;
    
    self.rotationManager.contentView = self.playView;
    
    __weak __typeof(self) weakSelf = self;
    self.rotationManager.orientationWillChange = ^(BOOL isFullscreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self willRotation:isFullscreen];
    };
    
    self.rotationManager.orientationDidChanged = ^(BOOL isFullscreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self didRotation:isFullscreen];
    };
}

- (void)willRotation:(BOOL)isFullScreen {
    NSLog(@"即将旋转----%@", isFullScreen ? @"全屏" : @"竖屏");
    if (!isFullScreen) {
        if (self.landscapeScrollView) {
            UIView *superview = self.landscapeScrollView.superview;
            [superview addSubview:self.rotationManager.contentView];
            [self.landscapeScrollView removeFromSuperview];
            self.landscapeScrollView = nil;
        }
    }
}

- (void)didRotation:(BOOL)isFullScreen {
    NSLog(@"结束旋转----%@", isFullScreen ? @"全屏" : @"竖屏");
    if (isFullScreen) {
        self.isFullScreen = YES;
        if (!self.landscapeScrollView) {
            [self initLandscapeView];
            UIView *superview = self.rotationManager.contentView.superview;
            self.landscapeScrollView.frame = superview.bounds;
            [superview addSubview:self.landscapeScrollView];

            self.landscapeScrollView.defaultIndex = self.portraitScrollView.currentIndex;
            [self.landscapeScrollView reloadData];
        }
    }else {
        self.isFullScreen = NO;
    }
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    GKVideoModel *model = self.dataSource[index];
    
    if ([cell isKindOfClass:NSClassFromString(@"GKVideoPortriatCell")]) {
        self.rotationManager.containerView = cell.coverImgView;
        if (self.isFullScreen) return;
    }else {
        [self.portraitScrollView scrollToPageWithIndex:index];
    }
    
    self.currentCell = cell;
    
    [self.coverView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.playView.superview != cell.coverImgView) {
            self.playView.frame = cell.coverImgView.bounds;
            [cell.coverImgView addSubview:self.playView];
        }
    });
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    self.coverView.image = nil;
}

- (void)enterFullScreen {
    [self.rotationManager rotate];
//    [self.rotationManager rotateToOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
}

- (UIView *)playView {
    if (!_playView) {
        _playView = [[UIView alloc] init];
        
        self.coverView = [[UIImageView alloc] init];
        self.coverView.contentMode = UIViewContentModeScaleAspectFit;
        self.coverView.userInteractionEnabled = YES;
//        [self.coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterFullScreen)]];
        [_playView addSubview:self.coverView];
        
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self->_playView);
        }];
    }
    return _playView;
}

@end
