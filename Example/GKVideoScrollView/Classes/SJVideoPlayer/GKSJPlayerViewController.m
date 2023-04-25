//
//  GKSJPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKSJPlayerViewController.h"
#import <SJVideoPlayer/SJVideoPlayer.h>
#import "GKVideoPortraitView.h"
#import <Masonry/Masonry.h>
#import "GKSJPlayerManager.h"

@interface GKSJPlayerViewController ()

@property (nonatomic, strong) SJVideoPlayer *player;

@end

@implementation GKSJPlayerViewController

- (void)viewDidLoad {
    
    self.manager = [[GKSJPlayerManager alloc] init];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"SJVideoPlayer播放";
}

@end
