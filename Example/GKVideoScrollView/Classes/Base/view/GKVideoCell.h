//
//  GKVideoCell.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoModel.h"
#import "GKSliderView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKVideoCell;

@protocol GKVideoCellDelegate <NSObject>

- (void)cellClickLikeBtn:(GKVideoCell *)cell;
- (void)cellClickFullscreenBtn:(GKVideoCell *)cell;

@end

@interface GKVideoCell : UIView

@property (nonatomic, weak) id<GKVideoCellDelegate> delegate;

// 封面图
@property (nonatomic, strong) UIImageView *coverImgView;

// 进度条
@property (nonatomic, strong) GKSliderView *sliderView;

- (void)loadData:(GKVideoModel *)model;

- (void)resetView;

- (void)scrollViewBeginDragging;
- (void)scrollViewDidEndDragging;

@end

NS_ASSUME_NONNULL_END
