//
//  GKVideoPlayerStatusBar.m
//  Example
//
//  Created by QuintGao on 2023/3/14.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPlayerStatusBar.h"

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO)

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIView (GKFrame)

@property (nonatomic) CGFloat sb_x;
@property (nonatomic) CGFloat sb_y;
@property (nonatomic) CGFloat sb_width;
@property (nonatomic) CGFloat sb_height;

@property (nonatomic) CGFloat sb_top;
@property (nonatomic) CGFloat sb_bottom;
@property (nonatomic) CGFloat sb_left;
@property (nonatomic) CGFloat sb_right;

@property (nonatomic) CGFloat sb_centerX;
@property (nonatomic) CGFloat sb_centerY;

@property (nonatomic) CGPoint sb_origin;
@property (nonatomic) CGSize sb_size;

@end

@implementation UIView (GKFrame)

- (CGFloat)sb_x {
    return self.frame.origin.x;
}

- (void)setSb_x:(CGFloat)sb_x {
    CGRect frame = self.frame;
    frame.origin.x = sb_x;
    self.frame = frame;
}

- (CGFloat)sb_y {
    return self.frame.origin.y;
}

- (void)setSb_y:(CGFloat)sb_y {
    CGRect frame = self.frame;
    frame.origin.y = sb_y;
    self.frame = frame;
}

- (CGFloat)sb_width {
    return self.frame.size.width;
}

- (void)setSb_width:(CGFloat)sb_width {
    CGRect frame = self.frame;
    frame.size.width = sb_width;
    self.frame = frame;
}

- (CGFloat)sb_height {
    return self.frame.size.height;
}

- (void)setSb_height:(CGFloat)sb_height {
    CGRect frame = self.frame;
    frame.size.height = sb_height;
    self.frame = frame;
}

- (CGFloat)sb_top {
    return self.frame.origin.y;
}

- (void)setSb_top:(CGFloat)sb_top {
    CGRect frame = self.frame;
    frame.origin.y = sb_top;
    self.frame = frame;
}

- (CGFloat)sb_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setSb_bottom:(CGFloat)sb_bottom {
    CGRect frame = self.frame;
    frame.origin.y = sb_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)sb_left {
    return self.frame.origin.x;
}

- (void)setSb_left:(CGFloat)sb_left {
    CGRect frame = self.frame;
    frame.origin.x = sb_left;
    self.frame = frame;
}

- (CGFloat)sb_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setSb_right:(CGFloat)sb_right {
    CGRect frame = self.frame;
    frame.origin.x = sb_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)sb_centerX {
    return self.center.x;
}

- (void)setSb_centerX:(CGFloat)sb_centerX {
    CGPoint center = self.center;
    center.x = sb_centerX;
    self.center = center;
}

- (CGFloat)sb_centerY {
    return self.center.y;
}

- (void)setSb_centerY:(CGFloat)sb_centerY {
    CGPoint center = self.center;
    center.y = sb_centerY;
    self.center = center;
}

- (CGPoint)sb_origin {
    return self.frame.origin;
}

- (void)setSb_origin:(CGPoint)sb_origin {
    CGRect frame = self.frame;
    frame.origin = sb_origin;
    self.frame = frame;
}

- (CGSize)sb_size {
    return self.frame.size;
}

- (void)setSb_size:(CGSize)sb_size {
    CGRect frame = self.frame;
    frame.size = sb_size;
    self.frame = frame;
}

@end

@interface GKVideoPlayerTimerTarget : NSProxy

@property (nonatomic, weak) id target;

@end

@implementation GKVideoPlayerTimerTarget

+ (instancetype)proxyWithTarget:(id)target {
    GKVideoPlayerTimerTarget *proxy = [GKVideoPlayerTimerTarget alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = nil;
    if ([self.target respondsToSelector:sel]) {
        signature = [self.target methodSignatureForSelector:sel];
    }else {
        /// 动态造一个 void object selector arg 函数签名
        /// 目的是返回有效signature，不要因为找不到而crash
        signature = [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
}

@end

@interface GKVideoPlayerStatusBar()
/// 时间
@property (nonatomic, strong) UILabel *dateLabel;
/// 电池
@property (nonatomic, strong) UIView *batteryView;
/// 充电标识
@property (nonatomic, strong) UIImageView *batteryImageView;
/// 充电层
@property (nonatomic, strong) CAShapeLayer *batteryLayer;
/// 电池边框
@property (nonatomic, strong) CAShapeLayer *batteryBoundLayer;
/// 电池正极
@property (nonatomic, strong) CAShapeLayer *batteryPositiveLayer;
/// 电量百分比
@property (nonatomic, strong) UILabel *batteryLabel;

/// 网络状态
@property (nonatomic, strong) UILabel *networkLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
 
@end

@implementation GKVideoPlayerStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.dateLabel sizeToFit];
    [self.networkLabel sizeToFit];
    [self.batteryLabel sizeToFit];
    
    self.dateLabel.sb_size = CGSizeMake(self.dateLabel.sb_width, 16);
    self.batteryView.frame = CGRectMake(self.bounds.size.width - 35, 0, 22, 10);
    self.batteryLabel.frame = CGRectMake(self.batteryView.sb_x - 42, 0, self.batteryLabel.sb_width, 16);
    self.networkLabel.frame = CGRectMake(self.batteryLabel.sb_x - 40, 0, self.networkLabel.sb_width + 13, 14);
    
    self.dateLabel.center = self.center;
    self.batteryView.sb_centerY = self.sb_centerY;
    self.batteryLabel.sb_right = self.batteryView.sb_x - 5;
    self.batteryLabel.sb_centerY = self.batteryView.sb_centerY;
    self.networkLabel.sb_left = 10;
    self.networkLabel.sb_centerY = self.batteryView.sb_centerY;
}

- (void)dealloc {
    [self destoryTimer];
}

- (void)setup {
    self.refreshTime = 3.0f;
    /// 时间
    [self addSubview:self.dateLabel];
    [self addSubview:self.batteryView];
    /// 电池
    [self.batteryView.layer addSublayer:self.batteryBoundLayer];
    /// 正极
    [self.batteryView.layer addSublayer:self.batteryPositiveLayer];
    /// 是否在充电
    [self.batteryView.layer addSublayer:self.batteryLayer];
    [self.batteryView addSubview:self.batteryImageView];
    [self addSubview:self.batteryLabel];
    [self addSubview:self.networkLabel];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChangeNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];
}

- (void)batteryLevelDidChangeNotification:(NSNotification *)noti {
    [self updateUI];
}

- (void)batteryStateDidChangeNotification:(NSNotification *)noti {
    [self updateUI];
}

- (void)localeDidChangeNotification:(NSNotification *)noti {
    [self.dateFormatter setLocale:NSLocale.currentLocale];
    [self updateUI];
}

- (void)setNetwork:(NSString *)network {
    _network = network;
    
    self.networkLabel.text = network;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)startTimer {
    if (self.timer) return;
    self.timer = [NSTimer timerWithTimeInterval:self.refreshTime target:[GKVideoPlayerTimerTarget proxyWithTarget:self] selector:@selector(updateUI) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}

- (void)destoryTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - update UI
- (void)updateUI {
    [self updateDate];
    [self updateBattery];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateDate {
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:[self.dateFormatter stringFromDate:[NSDate date]]];
    NSRange amRange = [dateString rangeOfString:[self.dateFormatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[self.dateFormatter PMSymbol]];
    if (amRange.location != NSNotFound) {
        [dateString deleteCharactersInRange:amRange];
    }else if (pmRange.location != NSNotFound) {
        [dateString deleteCharactersInRange:pmRange];
    }
    self.dateLabel.text = dateString;
}

- (void)updateBattery {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    /// -1是模拟器
    if (batteryLevel < 0) { batteryLevel = 1.0; }
    CGRect rect = CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3);
    UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2];
    
    UIColor *batteryColor;
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
        self.batteryImageView.hidden = NO;
    } else {
        self.batteryImageView.hidden = YES;
    }
    if (@available(iOS 9.0, *)) {
        if ([NSProcessInfo processInfo].lowPowerModeEnabled) { /// 低电量模式
            batteryColor = UIColorFromHex(0xF9CF0E);
        } else {
            if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
                batteryColor = UIColorFromHex(0x37CB46);
            } else if (batteryLevel <= 0.2) { /// 电量低
                batteryColor = UIColorFromHex(0xF02C2D);
            } else { /// 电量正常 白色
                batteryColor = [UIColor whiteColor];
            }
        }
    } else {
        if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) { /// 在充电
            batteryColor = UIColorFromHex(0x37CB46);
        } else if (batteryLevel <= 0.2) { /// 电量低
            batteryColor = UIColorFromHex(0xF02C2D);
        } else { /// 电量正常 白色
            batteryColor = [UIColor whiteColor];
        }
    }
    
    self.batteryLayer.strokeColor = [UIColor clearColor].CGColor;
    self.batteryLayer.path = batteryPath.CGPath;
    self.batteryLayer.fillColor = batteryColor.CGColor;
    self.batteryLabel.text = [NSString stringWithFormat:@"%.0f%%", batteryLevel*100];
}

#pragma mark - getter
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.bounds = CGRectMake(0, 0, 100, 16);
        _dateLabel.textColor = UIColor.whiteColor;
        _dateLabel.font = [UIFont systemFontOfSize:12];
    }
    return _dateLabel;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:NSLocale.currentLocale];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

- (UIView *)batteryView {
    if (!_batteryView) {
        _batteryView = [[UIView alloc] init];
    }
    return _batteryView;
}

- (UIImageView *)batteryImageView {
    if (!_batteryImageView) {
        _batteryImageView = [[UIImageView alloc] init];
        _batteryImageView.bounds = CGRectMake(0, 0, 8, 12);
        _batteryImageView.center = CGPointMake(10, 5);
        _batteryImageView.image = [UIImage imageNamed:@"icon_battery_lightning"];
    }
    return _batteryImageView;
}

- (CAShapeLayer *)batteryLayer {
    if (!_batteryLayer) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
        UIBezierPath *batteryPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1.5, 1.5, (20-3)*batteryLevel, 10-3) cornerRadius:2];
        _batteryLayer = [CAShapeLayer layer];
        _batteryLayer.lineWidth = 1;
        _batteryLayer.strokeColor = [UIColor clearColor].CGColor;
        _batteryLayer.path = batteryPath.CGPath;
        _batteryLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _batteryLayer;
}

- (CAShapeLayer *)batteryBoundLayer {
    if (!_batteryBoundLayer) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 20, 10) cornerRadius:2.5];
        _batteryBoundLayer = [CAShapeLayer layer];
        _batteryBoundLayer.lineWidth = 1;
        _batteryBoundLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
        _batteryBoundLayer.path = bezierPath.CGPath;
        _batteryBoundLayer.fillColor = nil;
    }
    return _batteryBoundLayer;
}

- (CAShapeLayer *)batteryPositiveLayer {
    if (!_batteryPositiveLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(22, 3, 1, 3) byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight) cornerRadii:CGSizeMake(2, 2)];
        _batteryPositiveLayer = [CAShapeLayer layer];
        _batteryPositiveLayer.lineWidth = 0.5;
        _batteryPositiveLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
        _batteryPositiveLayer.path = path.CGPath;
        _batteryPositiveLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor;
    }
    return _batteryPositiveLayer;
}

- (UILabel *)batteryLabel {
    if (!_batteryLabel) {
        _batteryLabel = [[UILabel alloc] init];
        _batteryLabel.textColor = [UIColor whiteColor];
        _batteryLabel.font = [UIFont systemFontOfSize:11];
        _batteryLabel.textAlignment = NSTextAlignmentRight;
    }
    return _batteryLabel;
}

- (UILabel *)networkLabel {
    if (!_networkLabel) {
        _networkLabel = [[UILabel alloc] init];
        _networkLabel.layer.cornerRadius = 7;
        _networkLabel.layer.borderWidth = 1;
        _networkLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _networkLabel.textColor = [UIColor whiteColor];
        _networkLabel.font = [UIFont systemFontOfSize:9];
        _networkLabel.textAlignment = NSTextAlignmentCenter;
        _networkLabel.text = @"WIFI";
    }
    return _networkLabel;
}

@end
