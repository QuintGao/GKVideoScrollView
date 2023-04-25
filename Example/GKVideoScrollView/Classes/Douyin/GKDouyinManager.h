//
//  GKDouyinManager.h
//  Example
//
//  Created by QuintGao on 2023/4/4.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoManager.h"
#import <SJVideoPlayer/SJVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDouyinManager : GKVideoManager

@property (nonatomic, strong) SJVideoPlayer *player;

@end

NS_ASSUME_NONNULL_END
