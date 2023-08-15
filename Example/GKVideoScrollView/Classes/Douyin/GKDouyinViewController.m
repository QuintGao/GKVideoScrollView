//
//  GKDouyinViewController.m
//  Example
//
//  Created by QuintGao on 2023/4/4.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDouyinViewController.h"
#import "GKDouyinManager.h"
#import "GKDouyinDetailViewController.h"

@interface GKDouyinViewController ()<GKViewControllerPushDelegate>

@end

@implementation GKDouyinViewController

- (void)viewDidLoad {
    self.manager = [[GKDouyinManager alloc] init];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"抖音";
    self.gk_pushDelegate = self;
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDouyinDetailViewController *detailVC = [[GKDouyinDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
