//
//  GKAppDelegate.m
//  GKVideoScrollView
//
//  Created by QuintGao on 02/21/2023.
//  Copyright (c) 2023 QuintGao. All rights reserved.
//

#import "GKAppDelegate.h"
#import <ZFPlayer/ZFLandscapeRotationManager.h>
#import <SJBaseVideoPlayer/SJRotationFullscreenWindow.h>
#import <SJBaseVideoPlayer/SJRotationManagerInternal.h>
#import "GKRotationManager.h"
#import "GKLandscapeWindow.h"

@implementation GKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([window isKindOfClass:SJRotationFullscreenWindow.class]) {
        SJRotationManager *manager = ((SJRotationFullscreenWindow *)window).rotationManager;
        if (manager) {
            return [manager supportedInterfaceOrientationsForWindow:window];
        }
    }
    
    GKInterfaceOrientationMask gk_orientationMask = [GKRotationManager supportedInterfaceOrientationsForWindow:window];
    if (gk_orientationMask != GKInterfaceOrientationMaskUnknow) {
        return (UIInterfaceOrientationMask)gk_orientationMask;
    }
    
    ZFInterfaceOrientationMask orientationMask = [ZFLandscapeRotationManager supportedInterfaceOrientationsForWindow:window];
    if (orientationMask != ZFInterfaceOrientationMaskUnknow) {
        return (UIInterfaceOrientationMask)orientationMask;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end

//@implementation UIViewController (RotationConfiguration)
/////
///// 控制器是否可以旋转
/////
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
/////
///// 控制器旋转支持的方向
/////
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}
//@end
//
//
//@implementation UITabBarController (RotationConfiguration)
//- (UIViewController *)sj_topViewController {
//    if ( self.selectedIndex == NSNotFound )
//        return self.viewControllers.firstObject;
//    return self.selectedViewController;
//}
//
//- (BOOL)shouldAutorotate {
//    return [[self sj_topViewController] shouldAutorotate];
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return [[self sj_topViewController] supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [[self sj_topViewController] preferredInterfaceOrientationForPresentation];
//}
//@end
//
//@implementation UINavigationController (RotationConfiguration)
//- (BOOL)shouldAutorotate {
//    return self.topViewController.shouldAutorotate;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return self.topViewController.supportedInterfaceOrientations;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return self.topViewController.preferredInterfaceOrientationForPresentation;
//}
//
//- (nullable UIViewController *)childViewControllerForStatusBarStyle {
//    return self.topViewController;
//}
//
//- (nullable UIViewController *)childViewControllerForStatusBarHidden {
//    return self.topViewController;
//}
//@end
