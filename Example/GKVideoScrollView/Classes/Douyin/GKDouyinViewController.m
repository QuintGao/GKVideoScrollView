//
//  GKDouyinViewController.m
//  Example
//
//  Created by QuintGao on 2023/4/4.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDouyinViewController.h"
#import "GKDouyinManager.h"

@interface GKDouyinViewController ()

@end

@implementation GKDouyinViewController

- (void)viewDidLoad {
    self.manager = [[GKDouyinManager alloc] init];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"抖音";
}

@end
