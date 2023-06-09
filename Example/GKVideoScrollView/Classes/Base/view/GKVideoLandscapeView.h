//
//  GKVideoLandscapeView.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJVideoPlayerControlMaskView.h>
#import <GKSliderView/GKSliderView.h>
#import "GKVideoPlayerStatusBar.h"
#import "GKVideoModel.h"
#import "GKDoubleLikeView.h"
#import "GKRotationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoLandscapeView : UIView

@property (nonatomic, strong) SJVideoPlayerControlMaskView *topContainerView;

@property (nonatomic, strong) SJVideoPlayerControlMaskView *bottomContainerView;

@property (nonatomic, strong) GKVideoPlayerStatusBar *statusBar;

@property (nonatomic, strong) GKSliderView *sliderView;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL isSeeking;

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UIButton *fullScreenBtn;

@property (nonatomic, weak) GKVideoModel *model;

@property (nonatomic, strong) GKDoubleLikeView *likeView;

@property (nonatomic, weak) GKRotationManager *rotationManager;

@property (nonatomic, copy) void(^likeBlock)(GKVideoModel *);

@property (nonatomic, copy) void(^singleTapBlock)(void);

- (void)backAction;
- (void)playAction;

- (void)loadData:(GKVideoModel *)model;

- (NSString *)convertTimeSecond:(NSInteger)timeSecond;

@property (nonatomic, assign) BOOL isContainerShow;
- (void)showContainerView:(BOOL)animated;
- (void)hideContainerView:(BOOL)animated;

- (void)draggingEnded;

@end

NS_ASSUME_NONNULL_END
