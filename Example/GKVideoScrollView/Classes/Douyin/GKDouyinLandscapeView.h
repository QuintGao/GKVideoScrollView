//
//  GKDouyinLandscapeView.h
//  Example
//
//  Created by QuintGao on 2023/4/20.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoLandscapeView.h"
#import <SJVideoPlayer/SJVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDouyinLandscapeView : GKVideoLandscapeView<SJControlLayer>

- (void)autoHide;

@end

NS_ASSUME_NONNULL_END
