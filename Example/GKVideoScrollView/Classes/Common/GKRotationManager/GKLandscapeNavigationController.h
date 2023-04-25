//
//  GKLandscapeNavigationController.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKLandscapeNavigationControllerDelegate;

@interface GKLandscapeNavigationController : UINavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(nullable id<GKLandscapeNavigationControllerDelegate>)delegate;
@end

@protocol GKLandscapeNavigationControllerDelegate <NSObject>

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
