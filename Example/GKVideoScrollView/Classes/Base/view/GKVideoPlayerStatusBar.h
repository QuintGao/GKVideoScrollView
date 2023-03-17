//
//  GKVideoPlayerStatusBar.h
//  Example
//
//  Created by QuintGao on 2023/3/14.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoPlayerStatusBar : UIView

@property (nonatomic, assign) NSTimeInterval refreshTime;

@property (nonatomic, copy) NSString *network;

- (void)startTimer;

- (void)destoryTimer;

@end

NS_ASSUME_NONNULL_END
