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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStylePlain target:self action:@selector(jump)];
}

- (void)jump {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = UIColor.redColor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    
}

@end
