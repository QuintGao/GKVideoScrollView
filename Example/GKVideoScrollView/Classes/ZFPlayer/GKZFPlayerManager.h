//
//  GKZFPlayerManager.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoManager.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKZFPlayerManager : GKVideoManager

- (instancetype)initWithPlayManager:(id<ZFPlayerMediaPlayback>)playManager;

@property (nonatomic, strong, nullable) ZFPlayerController *player;

@end

NS_ASSUME_NONNULL_END
