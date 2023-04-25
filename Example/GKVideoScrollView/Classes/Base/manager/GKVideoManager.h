//
//  GKVideoManager.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GKVideoScrollView/GKVideoScrollView.h>
#import "GKVideoCell.h"
#import "GKVideoLandscapeCell.h"
#import "GKVideoWorkListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoManager : NSObject

@property (nonatomic, strong) GKVideoScrollView *portraitScrollView;

@property (nonatomic, strong) GKVideoWorkListView *workListView;

@property (nonatomic, strong, nullable) GKVideoScrollView *landscapeScrollView;

@property (nonatomic, weak) GKVideoCell *currentCell;

@property (nonatomic, weak) GKVideoLandscapeCell *landscapeCell;

@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, strong) NSMutableArray *dataSource;

/// 初始化播放器
- (void)initPlayer;

- (void)initLandscapeView;

/// 准备cell
- (void)prepareCell:(GKVideoCell *)cell index:(NSInteger)index;

/// 预加载视频
- (void)preloadVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index;

/// 播放视频
- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index;

/// 停止播放
- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index;

- (void)back;
/// 进入全屏
- (void)enterFullScreen;

- (void)reloadData;

- (void)likeVideoWithModel:(GKVideoModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_END
