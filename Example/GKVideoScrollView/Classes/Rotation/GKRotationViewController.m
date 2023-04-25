//
//  GKRotationViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/30.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKRotationViewController.h"
#import "GKTestManager.h"

@interface GKRotationViewController ()

@end

@implementation GKRotationViewController

- (void)viewDidLoad {
    self.manager = [[GKTestManager alloc] init];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"旋转";
}

@end
