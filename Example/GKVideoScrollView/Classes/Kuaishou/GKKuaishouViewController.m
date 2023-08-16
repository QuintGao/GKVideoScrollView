//
//  GKKuaishouViewController.m
//  Example
//
//  Created by QuintGao on 2023/4/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKKuaishouViewController.h"
#import "GKKuaishouManager.h"
#import "GKKuaishouDetailViewController.h"

@interface GKKuaishouViewController ()<UIGestureRecognizerDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, assign) CGFloat beginX;

@property (nonatomic, assign) CGFloat translationX;

@property (nonatomic, assign) BOOL isWorkListShow;

@end

@implementation GKKuaishouViewController

- (void)viewDidLoad {
    self.manager = [[GKKuaishouManager alloc] init];
    [super viewDidLoad];
    
    self.navigationItem.title = @"快手";
    [self.view addGestureRecognizer:self.panGesture];
    self.gk_pushDelegate = self;
}

- (void)initUI {
    [super initUI];
    
    [self.view addSubview:self.manager.workListView];
    self.manager.workListView.frame = CGRectMake(self.view.bounds.size.width, 80, 62, self.view.bounds.size.height - 160);
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    if (!self.isWorkListShow) return;
    GKKuaishouDetailViewController *vc = [[GKKuaishouDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GKGesturePopHandlerProtocol
- (BOOL)navigationShouldPopOnGesture {
    return !self.isWorkListShow;
}

- (BOOL)popGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"%@", gestureRecognizer);
    if (gestureRecognizer == self.panGesture) {
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint transition = [panGesture translationInView:panGesture.view];
        NSLog(@"%f", transition.x);
        if (transition.x < 0) {
            
        }else if (transition.x > 0) {
            if (self.isWorkListShow) {
                return YES;
            }
            return NO;
        }else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - handle pan

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.beginX = self.manager.workListView.frame.origin.x;
        self.translationX = translation.x;
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat diff = translation.x - self.translationX;
        [self handlePanChange:diff];
    }else {
        [self handlePanEnded];
    }
}

- (void)handlePanChange:(CGFloat)distance {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    CGFloat maxW = self.manager.workListView.frame.size.width;
    CGFloat maxH = self.manager.workListView.frame.size.height;
    
    CGFloat ratio = maxW / (height - maxH);
    CGFloat hDistance = distance / ratio;
    
    if (distance > 0) { // 右滑
        if (self.beginX >= width) return;
        CGFloat x = width - maxW + distance;
        if (x >= width) {
            x = width;
        }
        
        CGFloat scrollH = maxH + hDistance;
        if (scrollH >= height) {
            scrollH = height;
        }
        
        CGRect frame = self.manager.workListView.frame;
        frame.origin.x = x;
        self.manager.workListView.frame = frame;
        
        CGRect scrollFrame = self.manager.portraitScrollView.frame;
        scrollFrame.size.width = x;
        scrollFrame.size.height = scrollH;
        scrollFrame.origin.y = (height - scrollH) / 2;
        self.manager.portraitScrollView.frame = scrollFrame;
    }else { // 左滑
        if (self.beginX < width) return;
        CGFloat x = width + distance;
        if (x <= width - maxW) {
            x = width - maxW;
        }
        CGFloat scrollH = height + hDistance;
        if (scrollH <= maxH) {
            scrollH = maxH;
        }
        
        CGRect frame = self.manager.workListView.frame;
        frame.origin.x = x;
        self.manager.workListView.frame = frame;
        
        CGRect scrollFrame = self.manager.portraitScrollView.frame;
        scrollFrame.size.width = x;
        scrollFrame.size.height = scrollH;
        scrollFrame.origin.y = (height - scrollH) / 2;
        self.manager.portraitScrollView.frame = scrollFrame;
    }
}

- (void)handlePanEnded {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat maxW = self.manager.workListView.frame.size.width;
    
    CGFloat diff = width - self.manager.workListView.frame.origin.x;
    if (diff >= maxW / 2) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.manager.workListView.frame;
            frame.origin.x = width - maxW;
            self.manager.workListView.frame = frame;
            self.manager.portraitScrollView.frame = CGRectMake(0, (height - frame.size.height) / 2, frame.origin.x, frame.size.height);
            self.isWorkListShow = YES;
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.manager.workListView.frame;
            frame.origin.x = width;
            self.manager.workListView.frame = frame;
            self.manager.portraitScrollView.frame = CGRectMake(0, 0, width, height);
            self.isWorkListShow = NO;
        }];
    }
}

#pragma mark - Lazy
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end
