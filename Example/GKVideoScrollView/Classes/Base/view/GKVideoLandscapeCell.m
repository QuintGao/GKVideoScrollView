//
//  GKVideoLandscapeCell.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoLandscapeCell.h"
#import "UIButton+GKEnlarge.h"
#import <SJVideoPlayer/SJVideoPlayerControlMaskView.h>
#import <Masonry/Masonry.h>

@interface GKVideoLandscapeCell()

@property (nonatomic, strong) SJVideoPlayerControlMaskView *topContainerView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GKVideoLandscapeCell

- (void)initUI {
    [super initUI];
    
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.backBtn];
    [self.topContainerView addSubview:self.titleLabel];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(25);
        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft).offset(12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn).offset(3);
        make.left.equalTo(self.backBtn.mas_right).offset(5);
        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight).offset(-30);
    }];
    
    self.topContainerView.hidden = YES;
    self.isShowTop = NO;
}

- (void)loadData:(GKVideoModel *)model {
    [super loadData:model];
    self.model = model;
    self.titleLabel.text = model.title;
}

- (void)backAction {
    if ([self.delegate respondsToSelector:@selector(cellClickBackBtn)]) {
        [self.delegate cellClickBackBtn];
    }
}

- (void)hideTopView {
    self.topContainerView.hidden = YES;
    self.isShowTop = NO;
}

- (void)showTopView {
    self.topContainerView.hidden = NO;
    self.isShowTop = YES;
}

- (void)resetView {
    [super resetView];
    [self showTopView];
}

- (void)autoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopView) object:nil];
    [self performSelector:@selector(hideTopView) withObject:nil afterDelay:3.0f];
}

#pragma mark - Lazy
- (SJVideoPlayerControlMaskView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    }
    return _topContainerView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
        [_backBtn setEnlargeEdge:10];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}
@end
