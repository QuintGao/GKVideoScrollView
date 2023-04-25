//
//  GKLandscapeNavigationController.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLandscapeNavigationController.h"

@implementation GKLandscapeNavigationController {
    __weak id<GKLandscapeNavigationControllerDelegate> _delegate;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegate:(id<GKLandscapeNavigationControllerDelegate>)delegate {
    if (self = [super initWithRootViewController:rootViewController]) {
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [super setNavigationBarHidden:YES animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {}
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count < 1) {
        [super pushViewController:viewController animated:animated];
    }else if ([_delegate respondsToSelector:@selector(pushViewController:animated:)]) {
        [_delegate pushViewController:viewController animated:animated];
    }
}

@end
