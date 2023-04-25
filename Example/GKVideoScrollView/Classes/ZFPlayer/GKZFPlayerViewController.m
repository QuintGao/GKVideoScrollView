//
//  GKZFPlayerViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <SDWebImage/SDWebImage.h>
#import "GKZFPortraitView.h"
#import "GKZFLandscapeView.h"
#import "GKZFPlayerManager.h"

@interface GKZFPlayerViewController ()

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) GKZFPortraitView *portraitView;

@property (nonatomic, strong) GKZFLandscapeView *landscapeView;

@end

@implementation GKZFPlayerViewController

- (void)viewDidLoad {
    
    self.manager = [[GKZFPlayerManager alloc] init];
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"ZFPlayer播放";
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    
}

@end
