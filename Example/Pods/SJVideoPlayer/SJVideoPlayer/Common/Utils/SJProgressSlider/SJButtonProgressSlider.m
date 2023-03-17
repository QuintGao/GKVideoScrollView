//
//  SJButtonProgressSlider.m
//
//  Created by 畅三江 on 2017/11/20.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJButtonProgressSlider.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif


@interface SJButtonProgressSlider ()
@end

@implementation SJButtonProgressSlider

@synthesize leftBtn = _leftBtn;
@synthesize rightBtn = _rightBtn;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _buttonSetupView];
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if ( self ) {
        [self _buttonSetupView];
    }
    return self;
}

- (void)setLeftText:(NSString *)leftText {
    [_leftBtn setTitle:leftText forState:UIControlStateNormal];
}

- (void)setRightText:(NSString *)rightText {
    [_rightBtn setTitle:rightText forState:UIControlStateNormal];
}

- (void)setTitleColor:(UIColor *)titleLabelColor {
    [_leftBtn setTitleColor:titleLabelColor forState:UIControlStateNormal];
    [_rightBtn setTitleColor:titleLabelColor forState:UIControlStateNormal];
}

- (void)setFont:(UIFont *)font {
    _leftBtn.titleLabel.font = font;
    _rightBtn.titleLabel.font = font;
}

- (void)_buttonSetupView {
    [self.leftContainerView addSubview:self.leftBtn];
    [self.rightContainerView addSubview:self.rightBtn];
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_leftBtn.superview);
    }];
    
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self->_rightBtn.superview);
    }];
}

- (UIButton *)leftBtn {
    if ( _leftBtn ) return _leftBtn;
    _leftBtn = [self _createButton];
    return _leftBtn;
}

- (UIButton *)rightBtn {
    if ( _rightBtn ) return _rightBtn;
    _rightBtn = [self _createButton];
    return _rightBtn;
}

- (UIButton *)_createButton {
    UIButton *btn = [UIButton new];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn sizeToFit];
    return btn;
}

@end
