//
//  GKTimerControl.h
//  Example
//
//  Created by QuintGao on 2023/4/3.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKTimerControl : NSObject

/// default is 3
@property (nonatomic) NSTimeInterval interval;

@property (nonatomic, copy, nullable) void(^exeBlock)(GKTimerControl *control);

- (void)resume;

- (void)interrupt;

@end

NS_ASSUME_NONNULL_END
