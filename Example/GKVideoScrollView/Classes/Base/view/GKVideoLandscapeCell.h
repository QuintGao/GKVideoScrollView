//
//  GKVideoLandscapeCell.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoCell.h"
#import "GKVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoLandscapeCell : GKVideoCell

@property (nonatomic, strong) GKVideoModel *model;

@property (nonatomic, assign) BOOL isShowTop;

- (void)hideTopView;
- (void)showTopView;

- (void)autoHide;

@end

NS_ASSUME_NONNULL_END
