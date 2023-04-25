//
//  GKVideoPortriatCell.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPortriatCell.h"
#import <Masonry/Masonry.h>

@interface GKVideoPortriatCell()

@property (nonatomic, strong) UIView *bottomView;

// 昵称
@property (nonatomic, strong) UILabel *nameLabel;

// 内容
@property (nonatomic, strong) UILabel *contentLabel;

// 喜欢按钮
@property (nonatomic, strong) UIButton *likeBtn;

// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;

@end

@implementation GKVideoPortriatCell

- (void)initUI {
    [super initUI];
    
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.contentLabel];
    [self.bottomView addSubview:self.sliderView];
    [self.bottomView addSubview:self.likeBtn];
    [self.bottomView addSubview:self.fullScreenBtn];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(160);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.bottom.equalTo(self.contentLabel.mas_top).offset(-10);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.sliderView.mas_top).offset(-10);
        make.left.equalTo(self).offset(20);
        make.right.lessThanOrEqualTo(self).offset(-60);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self).offset(-60);
        make.height.mas_equalTo(1);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.fullScreenBtn.mas_top).offset(-20);
        make.centerX.equalTo(self.fullScreenBtn);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.bottom.equalTo(self.sliderView.mas_top).offset(-10);
        make.width.height.mas_equalTo(40);
    }];
}

- (void)loadData:(GKVideoModel *)model {
    [super loadData:model];
    
    self.nameLabel.text = model.source_name;
    self.contentLabel.text = model.title;
    self.likeBtn.selected = model.isLike;
}

- (void)resetView {
    self.sliderView.value = 0;
}

- (void)scrollViewBeginDragging {
    self.bottomView.alpha = 0.4;
}

- (void)scrollViewDidEndDragging {
    self.bottomView.alpha = 1.0;
}

- (void)showLoading {
    [self.sliderView showLineLoading];
}

- (void)hideLoading {
    [self.sliderView hideLineLoading];
}

- (void)setProgress:(float)progress {
    self.sliderView.value = progress;
}

- (void)clickLikeBtn {
    if ([self.delegate respondsToSelector:@selector(cellClickLikeBtn:)]) {
        [self.delegate cellClickLikeBtn:self];
    }
}

- (void)clickFullScreenBtn {
    if ([self.delegate respondsToSelector:@selector(cellClickFullscreenBtn:)]) {
        [self.delegate cellClickFullscreenBtn:self];
    }
}

#pragma mark - Lazy
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = UIColor.whiteColor;
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        _sliderView.isHideSliderBlock = YES;
        _sliderView.sliderHeight = 1;
        _sliderView.maximumTrackTintColor = UIColor.clearColor;
        _sliderView.minimumTrackTintColor = UIColor.whiteColor;
    }
    return _sliderView;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_normal"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_selected"] forState:UIControlStateSelected];
        [_likeBtn addTarget:self action:@selector(clickLikeBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc] init];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ss_icon_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(clickFullScreenBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

@end
