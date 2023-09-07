//
//  GKSJPlayerManager.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoManager.h"
#import <SJVideoPlayer/SJVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSJPlayerManager : GKVideoManager

@property (nonatomic, strong, nullable) SJVideoPlayer *player;

@end

NS_ASSUME_NONNULL_END
