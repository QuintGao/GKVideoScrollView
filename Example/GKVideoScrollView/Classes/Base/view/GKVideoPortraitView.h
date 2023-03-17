//
//  GKVideoPortraitView.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "GKDoubleLikeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoPortraitView : UIView<SJControlLayer>

// 播放按钮
@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) GKDoubleLikeView *likeView;

@property (nonatomic, copy) void(^likeBlock)(void);

@end

NS_ASSUME_NONNULL_END
