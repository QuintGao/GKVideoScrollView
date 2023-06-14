//
//  GKTestCell2.m
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestCell2.h"

@implementation GKTestCell2

- (void)loadData:(GKTestModel *)model {
    self.textLabel.text = [NSString stringWithFormat:@"%@---%zd", @"GKTestCell2", model.pos];
}

@end
