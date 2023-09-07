//
//  GKZFPortraitView.h
//  Example
//
//  Created by QuintGao on 2023/3/14.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPortraitView.h"
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKZFPortraitView : GKVideoPortraitView<ZFPlayerMediaControl>

@property (nonatomic, copy) void(^longBlock)(void);

@end

NS_ASSUME_NONNULL_END
