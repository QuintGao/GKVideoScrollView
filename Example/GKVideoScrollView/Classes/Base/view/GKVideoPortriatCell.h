//
//  GKVideoPortriatCell.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoCell.h"
#import <GKSliderView/GKSliderView.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoPortriatCell : GKVideoCell

// 进度条
@property (nonatomic, strong) GKSliderView *sliderView;

@end

NS_ASSUME_NONNULL_END
