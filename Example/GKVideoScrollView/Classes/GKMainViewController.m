//
//  GKMainViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKMainViewController.h"
#import <Masonry/Masonry.h>
#import "GKZFPlayerViewController.h"
#import "GKSJPlayerViewController.h"
#import "GKRotationViewController.h"
#import "GKDouyinViewController.h"
#import "GKKuaishouViewController.h"
#import "GKTestViewController.h"
#import "GKTableViewController.h"

@interface GKMainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSources;

@end

@implementation GKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void)initUI {
    
    self.navigationController.gk_openScrollLeftPush = YES;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.navigationItem.title = @"GKVideoScrollView";
    
    self.dataSources = @[@"ZFPlayer播放",
                         @"SJVideoPlayer播放",
                         @"列表旋转",
                         @"抖音",
                         @"快手",
                         @"测试"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = self.navigationController.navigationBar.standardAppearance;
        [appearance configureWithTransparentBackground];
        appearance.backgroundColor = UIColor.clearColor;
        appearance.backgroundImage = nil;
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.redColor};
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSources[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    if (indexPath.row == 0) {
        vc = [[GKZFPlayerViewController alloc] init];
    }else if (indexPath.row == 1) {
        vc = [[GKSJPlayerViewController alloc] init];
    }else if (indexPath.row == 2) {
        vc = [[GKRotationViewController alloc] init];
    }else if (indexPath.row == 3) {
        vc = [[GKDouyinViewController alloc] init];
    }else if (indexPath.row == 4) {
        vc = [[GKKuaishouViewController alloc] init];
    }else if (indexPath.row == 5) {
        vc = [[GKTestViewController alloc] init];
    }else if (indexPath.row == 6) {
        vc = [[GKTableViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
