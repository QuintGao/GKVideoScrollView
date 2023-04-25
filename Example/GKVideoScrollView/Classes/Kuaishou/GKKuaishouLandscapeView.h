//
//  GKKuaishouLandscapeView.h
//  Example
//
//  Created by QuintGao on 2023/4/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoLandscapeView.h"
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKKuaishouLandscapeView : GKVideoLandscapeView<ZFPlayerMediaControl>

- (void)autoHide;

@end

NS_ASSUME_NONNULL_END
