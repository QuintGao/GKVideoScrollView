//
//  GKVideoPlayerViewController.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoPlayerViewController : UIViewController

- (void)initUI;

@property (nonatomic, strong) GKVideoManager *manager;

- (void)likeVideoWithModel:(nullable GKVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
