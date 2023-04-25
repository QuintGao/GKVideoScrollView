//
//  GKKuaishouPortraitView.h
//  Example
//
//  Created by QuintGao on 2023/4/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPortraitView.h"
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKKuaishouPortraitView : GKVideoPortraitView<ZFPlayerMediaControl>

@property (nonatomic, assign) BOOL shouldRight;

@property (nonatomic, copy) void(^leftScrollBlock)(CGFloat distance);
@property (nonatomic, copy) void(^rightScrollBlock)(CGFloat distance);
@property (nonatomic, copy) void(^scrollEndBlock)(CGFloat distance);

@property (nonatomic, copy) void(^scrollBlock)(CGFloat distance, BOOL isBegin, BOOL isEnd);

@end

NS_ASSUME_NONNULL_END
