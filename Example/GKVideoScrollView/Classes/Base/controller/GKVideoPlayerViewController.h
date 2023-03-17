//
//  GKVideoPlayerViewController.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKVideoScrollView.h"
#import "GKVideoCell.h"
#import "GKVideoLandscapeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoPlayerViewController : UIViewController

@property (nonatomic, strong) GKVideoScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, weak) GKVideoCell *currentCell;

- (void)playerVideoWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)stopPlayWithCell:(GKVideoCell *)cell indexPath:(NSIndexPath *)indexPath;

- (void)enterFullScreen;

- (void)likeVideoWithModel:(nullable GKVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
