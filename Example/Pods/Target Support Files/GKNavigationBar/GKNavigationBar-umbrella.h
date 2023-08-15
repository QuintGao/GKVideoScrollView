#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GKBaseAnimatedTransition.h"
#import "GKGestureHandleConfigure.h"
#import "GKGestureHandleDefine.h"
#import "GKNavigationInteractiveTransition.h"
#import "GKPopAnimatedTransition.h"
#import "GKPushAnimatedTransition.h"
#import "UINavigationController+GKGestureHandle.h"
#import "UIScrollView+GKGestureHandle.h"
#import "UIViewController+GKGestureHandle.h"

FOUNDATION_EXPORT double GKNavigationBarVersionNumber;
FOUNDATION_EXPORT const unsigned char GKNavigationBarVersionString[];

