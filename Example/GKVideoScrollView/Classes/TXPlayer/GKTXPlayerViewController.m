//
//  GKTXPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2024/11/13.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKTXPlayerViewController.h"
#import "GKZFPlayerManager.h"
#import "GKTXPlayerManager.h"

@interface GKTXPlayerViewController ()

@end

@implementation GKTXPlayerViewController

- (void)viewDidLoad {
    GKTXPlayerManager *playManager = [[GKTXPlayerManager alloc] init];
    self.manager = [[GKZFPlayerManager alloc] initWithPlayManager:playManager];
    self.manager.viewController = self;
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"腾讯云视频播放";
}

@end
