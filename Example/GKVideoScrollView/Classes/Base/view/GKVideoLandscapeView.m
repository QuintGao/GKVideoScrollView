//
//  GKVideoLandscapeView.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoLandscapeView.h"
#import <Masonry/Masonry.h>
#import <ZFPlayer/ZFPlayer.h>
#import "UIButton+GKEnlarge.h"

@interface GKVideoLandscapeView()<GKSliderViewDelegate>

// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;

// 内容
@property (nonatomic, strong) UILabel *contentLabel;

// 昵称
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation GKVideoLandscapeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.statusBar];
    [self.topContainerView addSubview:self.backBtn];
    [self.topContainerView addSubview:self.contentLabel];
    [self.topContainerView addSubview:self.nameLabel];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.playBtn];
    [self.bottomContainerView addSubview:self.timeLabel];
    [self.bottomContainerView addSubview:self.sliderView];
    [self.bottomContainerView addSubview:self.fullScreenBtn];
    [self.bottomContainerView addSubview:self.likeBtn];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.statusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerView.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusBar.mas_bottom).offset(5);
        make.left.equalTo(self.statusBar).offset(2);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn).offset(3);
        make.left.equalTo(self.backBtn.mas_right).offset(5);
        make.right.equalTo(self.statusBar.mas_right).offset(-20);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderView);
        make.bottom.equalTo(self.bottomContainerView).offset(-10);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sliderView.mas_right);
        make.centerY.equalTo(self.playBtn);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.right.equalTo(self.fullScreenBtn.mas_left).offset(-20);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.bottom.equalTo(self.playBtn.mas_top).offset(-10);
        make.height.mas_equalTo(10);
    }];
}

- (void)loadData:(GKVideoModel *)model {
    self.model = model;
    self.contentLabel.text = model.title;
    self.nameLabel.text = model.source_name;
    self.likeBtn.selected = model.isLike;
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

- (void)showContainerView:(BOOL)animated {
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
    }];
    
    [self.bottomContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
    }];
    
    NSTimeInterval duration = animated ? 0.15 : 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isContainerShow = YES;
    }];
}

- (void)hideContainerView {
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(-80);
    }];
    
    [self.bottomContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(80);
    }];
    
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isContainerShow = NO;
    }];
}

#pragma mark - action
- (void)backAction {
    
}

- (void)playAction {
    
}

- (void)likeAction {
    self.model.isLike = !self.model.isLike;
    self.likeBtn.selected = self.model.isLike;
    !self.likeBtn ?: self.likeBlock(self.model);
}

- (void)fullscreenAction {
    [self backAction];
}

#pragma mark - GKSliderViewDelegate
- (void)sliderView:(GKSliderView *)sliderView touchBegan:(float)value {
    self.isDragging = YES;
}

- (void)sliderView:(GKSliderView *)sliderView touchEnded:(float)value {
    self.isDragging = NO;
    [self draggingEnded];
}

- (void)draggingEnded {
    
}

#pragma mark - Lazy
- (SJVideoPlayerControlMaskView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    }
    return _topContainerView;
}

- (SJVideoPlayerControlMaskView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_bottom];
    }
    return _bottomContainerView;
}

- (GKVideoPlayerStatusBar *)statusBar {
    if (!_statusBar) {
        _statusBar = [[GKVideoPlayerStatusBar alloc] init];
    }
    return _statusBar;
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

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont boldSystemFontOfSize:15];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.whiteColor;
    }
    return _nameLabel;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setEnlargeEdge:10];
//        _playBtn.hidden = YES;
    }
    return _playBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = UIColor.whiteColor;
    }
    return _timeLabel;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_normal"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_selected"] forState:UIControlStateSelected];
        [_likeBtn addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
        [_likeBtn setEnlargeEdge:10];
    }
    return _likeBtn;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc] init];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ss_icon_shrinkscreen"] forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullscreenAction) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenBtn setEnlargeEdge:10];
    }
    return _fullScreenBtn;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_slider"] forState:UIControlStateNormal];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_slider"] forState:UIControlStateHighlighted];
        _sliderView.maximumTrackTintColor = UIColor.grayColor;
        _sliderView.minimumTrackTintColor = UIColor.whiteColor;
        _sliderView.sliderHeight = 2;
        _sliderView.delegate = self;
        _sliderView.isSliderAllowTapped = NO;
    }
    return _sliderView;
}

- (GKDoubleLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKDoubleLikeView alloc] init];
    }
    return _likeView;
}

@end
