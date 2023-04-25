//
//  GKVideoCell.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoModel.h"
#import <GKSliderView/GKSliderView.h>
#import <GKVideoScrollView/GKVideoScrollView.h>

NS_ASSUME_NONNULL_BEGIN

@class GKVideoCell;

@protocol GKVideoCellDelegate <NSObject>

- (void)cellClickBackBtn;
- (void)cellClickLikeBtn:(GKVideoCell *)cell;
- (void)cellClickFullscreenBtn:(GKVideoCell *)cell;

@end

@interface GKVideoCell : GKVideoViewCell

@property (nonatomic, weak) id<GKVideoCellDelegate> delegate;

// 封面图
@property (nonatomic, strong) UIImageView *coverImgView;

- (void)initUI;

- (void)loadData:(GKVideoModel *)model;

- (void)resetView;

- (void)scrollViewBeginDragging;
- (void)scrollViewDidEndDragging;

- (void)showLoading;
- (void)hideLoading;

- (void)setProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
