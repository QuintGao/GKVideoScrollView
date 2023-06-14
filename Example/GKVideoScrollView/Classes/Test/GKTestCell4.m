//
//  GKTestCell4.m
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestCell4.h"

@implementation GKTestCell4

- (void)loadData:(GKTestModel *)model {
    self.textLabel.text = [NSString stringWithFormat:@"%@---%zd", @"GKTestCell4", model.pos];
}

@end
