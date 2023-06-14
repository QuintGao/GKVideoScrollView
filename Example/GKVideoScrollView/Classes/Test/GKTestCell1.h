//
//  GKTestCell1.h
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <GKVideoScrollView/GKVideoScrollView.h>
#import "GKTestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKTestCell1 : GKVideoViewCell

@property (nonatomic, strong) UILabel *textLabel;

- (void)loadData:(GKTestModel *)model;

@end

NS_ASSUME_NONNULL_END
