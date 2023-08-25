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
    
    [self hideNavBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self showNavBar];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    
}

- (void)showNavBar {
    NSDictionary *dic = @{NSForegroundColorAttributeName: UIColor.grayColor, NSFontAttributeName: [UIFont boldSystemFontOfSize:18]};
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = UIColor.whiteColor;
        appearance.shadowColor = UIColor.whiteColor;
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.translucent = NO;
    }else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTitleTextAttributes:dic];
    }
}

- (void)hideNavBar {
    NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    if (@available(iOS 15.0, *)) {
        //navigation标题文字颜色
        UINavigationBarAppearance *barApp = [UINavigationBarAppearance new];
        barApp.backgroundColor = UIColor.clearColor;
        barApp.shadowColor = nil;
        barApp.backgroundEffect = nil;
        barApp.titleTextAttributes = dic;
        self.navigationController.navigationBar.scrollEdgeAppearance = nil;
        self.navigationController.navigationBar.standardAppearance = barApp;
        self.navigationController.navigationBar.translucent = YES;
    }else{
        //背景色
//        UIImage *image = [TCTools imageWithColor:UIColorBaseRGBA(0xffffff, 0)];
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        
        // 导航条title 字体 颜色
        [self.navigationController.navigationBar setTitleTextAttributes:dic];
    }
}

@end
