//
//  GKTestCell3.m
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestCell3.h"

@implementation GKTestCell3

- (void)loadData:(GKTestModel *)model {
    self.textLabel.text = [NSString stringWithFormat:@"%@---%zd", @"GKTestCell3", model.pos];
}

@end
