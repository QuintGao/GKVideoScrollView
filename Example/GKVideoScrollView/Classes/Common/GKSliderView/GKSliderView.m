//
//  GKSliderView.m
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 高坤. All rights reserved.
//

#import "GKSliderView.h"
#import "GKLineLoadingView.h"

/** 滑块的大小 */
#define kSliderBtnWH  19.0
/** 间距 */
#define kProgressMargin 2.0
/** 进度的宽度 */
#define kProgressW    self.frame.size.width - kProgressMargin * 2
/** 进度的高度 */
#define kProgressH    3.0

@interface GKSliderView()

/** 进度背景 */
@property (nonatomic, strong) UIImageView *bgProgressView;
/** 缓存进度 */
@property (nonatomic, strong) UIImageView *bufferProgressView;
/** 滑动进度 */
@property (nonatomic, strong) UIImageView *sliderProgressView;

/** 滑块 */
@property (nonatomic, strong) GKSliderButton *sliderBtn;

@property (nonatomic, assign) CGPoint lastPoint;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation GKSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.allowTapped = YES;
        
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.allowTapped = YES;
    
    [self addSubViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.sliderBtn.hidden) {
        self.bgProgressView.gk_width   = self.gk_width;
    }else {
        self.bgProgressView.gk_width   = self.gk_width - kProgressMargin * 2;
    }
    
    self.bgProgressView.gk_centerY     = self.gk_height * 0.5;
    self.bufferProgressView.gk_centerY = self.gk_height * 0.5;
    self.sliderProgressView.gk_centerY = self.gk_height * 0.5;
    self.sliderBtn.gk_centerY          = self.gk_height * 0.5;
}

/**
 添加子视图
 */
- (void)addSubViews {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.bgProgressView];
    [self addSubview:self.bufferProgressView];
    [self addSubview:self.sliderProgressView];
    [self addSubview:self.sliderBtn];
    
    // 初始化frame
    self.bgProgressView.frame     = CGRectMake(kProgressMargin, 0, 0, kProgressH);
    
    self.bufferProgressView.frame = self.bgProgressView.frame;
    
    self.sliderProgressView.frame = self.bgProgressView.frame;
    
    self.sliderBtn.frame          = CGRectMake(0, 0, kSliderBtnWH, kSliderBtnWH);
    
    // 添加点击手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tapGesture];
}

#pragma mark - Setter
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    
    self.bgProgressView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    
    self.sliderProgressView.backgroundColor = minimumTrackTintColor;
}

- (void)setBufferTrackTintColor:(UIColor *)bufferTrackTintColor {
    _bufferTrackTintColor = bufferTrackTintColor;
    
    self.bufferProgressView.backgroundColor = bufferTrackTintColor;
}

- (void)setMaximumTrackImage:(UIImage *)maximumTrackImage {
    _maximumTrackImage = maximumTrackImage;
    
    self.bgProgressView.image = maximumTrackImage;
    self.maximumTrackTintColor = [UIColor clearColor];
}

- (void)setMinimumTrackImage:(UIImage *)minimumTrackImage {
    _minimumTrackImage = minimumTrackImage;
    
    self.sliderProgressView.image = minimumTrackImage;
    
    self.minimumTrackTintColor = [UIColor clearColor];
}

- (void)setBufferTrackImage:(UIImage *)bufferTrackImage {
    _bufferTrackImage = bufferTrackImage;
    
    self.bufferProgressView.image = bufferTrackImage;
    
    self.bufferTrackTintColor = [UIColor clearColor];
}

- (void)setValue:(float)value {
    _value = value;

    CGFloat finishValue  = self.bgProgressView.gk_width * value;
    self.sliderProgressView.gk_width = finishValue;
    
    self.sliderBtn.gk_left = (self.gk_width - self.sliderBtn.gk_width) * value;
    
    self.lastPoint = self.sliderBtn.center;
}

- (void)setBufferValue:(float)bufferValue {
    _bufferValue = bufferValue;
    
    CGFloat finishValue = self.bgProgressView.gk_width * bufferValue;

    self.bufferProgressView.gk_width = finishValue;
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setBackgroundImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    [self.sliderBtn setImage:image forState:state];
    
    [self.sliderBtn sizeToFit];
}

- (void)showLoading {
    [self.sliderBtn showActivityAnim];
}

- (void)hideLoading {
    [self.sliderBtn hideActivityAnim];
}

- (void)showLineLoading {
    self.sliderProgressView.hidden = YES;
    [GKLineLoadingView showLoadingInView:self withLineHeight:self.gk_height];
}

- (void)hideLineLoading {
    self.sliderProgressView.hidden = NO;
    [GKLineLoadingView hideLoadingInView:self];
}

- (void)setAllowTapped:(BOOL)allowTapped {
    _allowTapped = allowTapped;
    
    if (!allowTapped) {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (void)setSliderHeight:(CGFloat)sliderHeight {
    _sliderHeight = sliderHeight;
    
    self.bgProgressView.gk_height     = sliderHeight;
    self.bufferProgressView.gk_height = sliderHeight;
    self.sliderProgressView.gk_height = sliderHeight;
}

- (void)setIsHideSliderBlock:(BOOL)isHideSliderBlock {
    _isHideSliderBlock = isHideSliderBlock;
    
    // 隐藏滑块，滑杆不可点击
    if (isHideSliderBlock) {
        self.sliderBtn.hidden = YES;
        
        self.bgProgressView.gk_left     = 0;
        self.bufferProgressView.gk_left = 0;
        self.sliderProgressView.gk_left = 0;
        
        self.allowTapped = NO;
    }
}

#pragma mark - User Action
- (void)sliderBtnTouchBegin:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(sliderTouchBegan:)]) {
        [self.delegate sliderTouchBegan:self.value];
    }
}

- (void)sliderBtnTouchEnded:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(sliderTouchEnded:)]) {
        [self.delegate sliderTouchEnded:self.value];
    }
}

- (void)sliderBtnDragMoving:(UIButton *)btn event:(UIEvent *)event {
    
    // 点击的位置
    CGPoint point = [event.allTouches.anyObject locationInView:self];
    
    // 获取进度值 由于btn是从 0-(self.width - btn.width)
    float value = (point.x - btn.gk_width * 0.5) / (self.gk_width - btn.gk_width);
    
    // value的值需在0-1之间
    value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value;
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [self.delegate sliderValueChanged:value];
    }
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    // 获取进度
    float value = (point.x - self.bgProgressView.gk_left) * 1.0 / self.bgProgressView.gk_width;
    value = value >= 1.0 ? 1.0 : value <= 0 ? 0 : value;
    
    [self setValue:value];
    
    if ([self.delegate respondsToSelector:@selector(sliderTapped:)]) {
        [self.delegate sliderTapped:value];
    }
}

#pragma mark - 懒加载
- (UIView *)bgProgressView {
    if (!_bgProgressView) {
        _bgProgressView = [UIImageView new];
        _bgProgressView.backgroundColor = [UIColor grayColor];
        _bgProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bgProgressView.clipsToBounds = YES;
    }
    return _bgProgressView;
}

- (UIView *)bufferProgressView {
    if (!_bufferProgressView) {
        _bufferProgressView = [UIImageView new];
        _bufferProgressView.backgroundColor = [UIColor whiteColor];
        _bufferProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _bufferProgressView.clipsToBounds = YES;
    }
    return _bufferProgressView;
}

- (UIView *)sliderProgressView {
    if (!_sliderProgressView) {
        _sliderProgressView = [UIImageView new];
        _sliderProgressView.backgroundColor = [UIColor redColor];
        _sliderProgressView.contentMode = UIViewContentModeScaleAspectFill;
        _sliderProgressView.clipsToBounds = YES;
    }
    return _sliderProgressView;
}

- (GKSliderButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [GKSliderButton new];
//        _sliderBtn.backgroundColor = [UIColor whiteColor];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchBegin:) forControlEvents:UIControlEventTouchDown];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchCancel];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_sliderBtn addTarget:self action:@selector(sliderBtnDragMoving:event:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _sliderBtn;
}

@end

@interface GKSliderButton()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation GKSliderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.hidesWhenStopped       = NO;
        self.indicatorView.userInteractionEnabled = NO;
        self.indicatorView.frame     = CGRectMake(0, 0, 20, 20);
        self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.indicatorView.hidden    = YES;
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.indicatorView.center = CGPointMake(self.gk_width / 2, self.gk_height/ 2);
    self.indicatorView.transform = CGAffineTransformMakeScale(0.6, 0.6);
}

- (void)showActivityAnim {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)hideActivityAnim {
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
}

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    
    // 扩大点击区域
    bounds = CGRectInset(bounds, -20, -20);
    
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}

@end


@implementation UIView (GKFrame)

- (void)setGk_left:(CGFloat)gk_left{
    CGRect f = self.frame;
    f.origin.x = gk_left;
    self.frame = f;
}

- (CGFloat)gk_left {
    return self.frame.origin.x;
}

- (void)setGk_top:(CGFloat)gk_top {
    CGRect f = self.frame;
    f.origin.y = gk_top;
    self.frame = f;
}

- (CGFloat)gk_top {
    return self.frame.origin.y;
}

- (void)setGk_right:(CGFloat)gk_right {
    CGRect f = self.frame;
    f.origin.x = gk_right - f.size.width;
    self.frame = f;
}

- (CGFloat)gk_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setGk_bottom:(CGFloat)gk_bottom {
    CGRect f = self.frame;
    f.origin.y = gk_bottom - f.size.height;
    self.frame = f;
}

- (CGFloat)gk_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setGk_width:(CGFloat)gk_width {
    CGRect f = self.frame;
    f.size.width = gk_width;
    self.frame = f;
}

- (CGFloat)gk_width {
    return self.frame.size.width;
}

- (void)setGk_height:(CGFloat)gk_height {
    CGRect f = self.frame;
    f.size.height = gk_height;
    self.frame = f;
}

- (CGFloat)gk_height {
    return self.frame.size.height;
}

- (void)setGk_centerX:(CGFloat)gk_centerX {
    CGPoint c = self.center;
    c.x = gk_centerX;
    self.center = c;
}

- (CGFloat)gk_centerX {
    return self.center.x;
}

- (void)setGk_centerY:(CGFloat)gk_centerY {
    CGPoint c = self.center;
    c.y = gk_centerY;
    self.center = c;
}

- (CGFloat)gk_centerY {
    return self.center.y;
}

@end

