//
//  GKVideoModel.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoModel.h"

@implementation GKVideoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"video_id": @"id"};
}

@end
