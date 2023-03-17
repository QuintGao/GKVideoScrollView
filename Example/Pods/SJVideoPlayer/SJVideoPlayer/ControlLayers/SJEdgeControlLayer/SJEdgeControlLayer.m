//
//  SJEdgeControlLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/24.
//  Copyright © 2018 畅三江. All rights reserved.
//

#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

#if __has_include(<SJBaseVideoPlayer/SJBaseVideoPlayer.h>)
#import <SJBaseVideoPlayer/SJBaseVideoPlayer.h>
#import <SJBaseVideoPlayer/SJTimerControl.h>
#else
#import "SJBaseVideoPlayer.h"
#import "SJTimerControl.h"
#endif

#import "SJEdgeControlLayer.h"
#import "SJVideoPlayerURLAsset+SJControlAdd.h"
#import "SJDraggingProgressPopupView.h"
#import "UIView+SJAnimationAdded.h"
#import "SJVideoPlayerConfigurations.h"
#import "SJProgressSlider.h"
#import "SJLoadingView.h"
#import "SJDraggingObservation.h"
#import "SJScrollingTextMarqueeView.h"
#import "SJFullscreenModeStatusBar.h"
#import "SJSpeedupPlaybackPopupView.h"
#import "SJEdgeControlButtonItemInternal.h"
#import <objc/message.h>

#pragma mark - Top

@interface SJEdgeControlLayer ()<SJProgressSliderDelegate>
@property (nonatomic, weak, nullable) SJBaseVideoPlayer *videoPlayer;

@property (nonatomic, strong, readonly) SJTimerControl *lockStateTappedTimerControl;
@property (nonatomic, strong, readonly) SJProgressSlider *bottomProgressIndicator;

// 固定左上角的返回按钮. 设置`fixesBackItem`后显示
@property (nonatomic, strong, readonly) UIButton *fixedBackButton;
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *backItem;

@property (nonatomic, strong, nullable) id<SJReachabilityObserver> reachabilityObserver;
@property (nonatomic, strong, readonly) SJTimerControl *dateTimerControl API_AVAILABLE(ios(11.0)); // refresh date for custom status bar
@property (nonatomic, strong, readonly) SJEdgeControlButtonItem *pictureInPictureItem API_AVAILABLE(ios(14.0));

@property (nonatomic) BOOL automaticallyFitOnScreen;
@end

@implementation SJEdgeControlLayer
@synthesize restarted = _restarted;
@synthesize draggingProgressPopupView = _draggingProgressPopupView;
@synthesize draggingObserver = _draggingObserver;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _bottomProgressIndicatorHeight = 1;
    _automaticallyPerformRotationOrFitOnScreen = YES;
    [self _setupView];
    self.autoAdjustTopSpacing = YES;
    self.hiddenBottomProgressIndicator = YES;
    if (@available(iOS 14.0, *)) {
        self.automaticallyShowsPictureInPictureItem = YES;
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

///
/// 切换器(player.switcher)重启该控制层
///
- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
    [self _showOrHiddenLoadingView];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

///
/// 控制层退场
///
- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
    
    sj_view_makeDisappear(_topContainerView, YES);
    sj_view_makeDisappear(_leftContainerView, YES);
    sj_view_makeDisappear(_bottomContainerView, YES);
    sj_view_makeDisappear(_rightContainerView, YES);
    sj_view_makeDisappear(_draggingProgressPopupView, YES);
    sj_view_makeDisappear(_centerContainerView, YES);
}

#pragma mark - item actions

- (void)_fixedBackButtonWasTapped {
    [self.backItem performActions];
}

- (void)_backItemWasTapped {
    if ( [self.delegate respondsToSelector:@selector(backItemWasTappedForControlLayer:)] ) {
        [self.delegate backItemWasTappedForControlLayer:self];
    }
}

- (void)_lockItemWasTapped {
    self.videoPlayer.lockedScreen = !self.videoPlayer.isLockedScreen;
}

- (void)_playItemWasTapped {
    _videoPlayer.isPaused ? [self.videoPlayer play] : [self.videoPlayer pauseForUser];
}

- (void)_fullItemWasTapped {
    if ( _videoPlayer.onlyFitOnScreen || _automaticallyFitOnScreen ) {
        [_videoPlayer setFitOnScreen:!_videoPlayer.isFitOnScreen];
        return;
    }
    
    if ( _needsFitOnScreenFirst && !_videoPlayer.isFitOnScreen ) {
        [_videoPlayer setFitOnScreen:YES];
        return;
    }
    
    [_videoPlayer rotate];
}

- (void)_replayItemWasTapped {
    [_videoPlayer replay];
}

- (void)pictureInPictureItemWasTapped API_AVAILABLE(ios(14.0)) {
    switch (_videoPlayer.playbackController.pictureInPictureStatus) {
        case SJPictureInPictureStatusStarting:
        case SJPictureInPictureStatusRunning:
            [_videoPlayer.playbackController stopPictureInPicture];
            break;
        case SJPictureInPictureStatusUnknown:
        case SJPictureInPictureStatusStopping:
        case SJPictureInPictureStatusStopped:
            [_videoPlayer.playbackController startPictureInPicture];
            break;
    }
}

#pragma mark - slider delegate methods

- (void)sliderWillBeginDragging:(SJProgressSlider *)slider {
    if ( _videoPlayer.assetStatus != SJAssetStatusReadyToPlay ) {
        [slider cancelDragging];
        return;
    }
    else if ( _videoPlayer.canSeekToTime && !_videoPlayer.canSeekToTime(_videoPlayer) ) {
        [slider cancelDragging];
        return;
    }
    
    [self _willBeginDragging];
}

- (void)slider:(SJProgressSlider *)slider valueDidChange:(CGFloat)value {
    if ( slider.isDragging ) [self _didMove:value];
}

- (void)sliderDidEndDragging:(SJProgressSlider *)slider {
    [self _endDragging];
}

#pragma mark - player delegate methods

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    _videoPlayer = videoPlayer;
    sj_view_makeDisappear(_topContainerView, NO);
    sj_view_makeDisappear(_leftContainerView, NO);
    sj_view_makeDisappear(_bottomContainerView, NO);
    sj_view_makeDisappear(_rightContainerView, NO);
    sj_view_makeDisappear(_centerContainerView, NO);
    
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomDurationItemIfNeeded];
    
    _reachabilityObserver = [videoPlayer.reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkSpeedDidChangeExeBlock = ^(id<SJReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateNetworkSpeedStrForLoadingView];
    };
}

///
/// 当播放器尝试自动隐藏控制层之前 将会调用这个方法
///
- (BOOL)controlLayerOfVideoPlayerCanAutomaticallyDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    if ( progressItem != nil && !progressItem.isHidden ) {
        SJProgressSlider *slider = progressItem.customView;
        return !slider.isDragging;
    }
    return YES;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isLockedScreen )
        return;
    
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( videoPlayer.isLockedScreen )
        return;
    
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer prepareToPlay:(SJVideoPlayerURLAsset *)asset {
    _automaticallyFitOnScreen = NO;
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
}

- (void)videoPlayerPlaybackStatusDidChange:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _reloadAdaptersIfNeeded];
    [self _showOrHiddenLoadingView];
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0)) {
    [self _updateContentForPictureInPictureItem];
    [self.topAdapter reload];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer currentTimeDidChange:(NSTimeInterval)currentTime {
    [self _updateContentForBottomCurrentTimeItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
    [self _updateCurrentTimeForDraggingProgressPopupViewIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer durationDidChange:(NSTimeInterval)duration {
    [self _reloadSizeForBottomTimeLabel];
    [self _updateContentForBottomDurationItemIfNeeded];
    [self _updateContentForBottomProgressIndicatorIfNeeded];
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playableDurationDidChange:(NSTimeInterval)duration {
    [self _updateContentForBottomProgressSliderItemIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer playbackTypeDidChange:(SJPlaybackType)playbackType {
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *separatorItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Separator];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
    SJEdgeControlButtonItem *liveItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
    switch ( playbackType ) {
        case SJPlaybackTypeLIVE: {
            currentTimeItem.innerHidden = YES;
            separatorItem.innerHidden = YES;
            durationTimeItem.innerHidden = YES;
            progressItem.innerHidden = YES;
            liveItem.innerHidden = NO;
        }
            break;
        case SJPlaybackTypeUnknown:
        case SJPlaybackTypeVOD:
        case SJPlaybackTypeFILE: {
            currentTimeItem.innerHidden = NO;
            separatorItem.innerHidden = NO;
            durationTimeItem.innerHidden = NO;
            progressItem.innerHidden = NO;
            liveItem.innerHidden = YES;
        }
            break;
    }
    [self.bottomAdapter reload];
    [self _showOrRemoveBottomProgressIndicator];
}

- (BOOL)canTriggerRotationOfVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( _needsFitOnScreenFirst || _automaticallyFitOnScreen )
        return videoPlayer.isFitOnScreen;
    
    if ( _automaticallyFitOnScreen ) {
        if ( videoPlayer.isFitOnScreen ) return videoPlayer.allowsRotationInFitOnScreen;
        return NO;
    }
    
    return YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willRotateView:(BOOL)isFull {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer didEndRotation:(BOOL)isFull {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer willFitOnScreen:(BOOL)isFitOnScreen {
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
}

/// 是否可以触发播放器的手势
- (BOOL)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer gestureRecognizerShouldTrigger:(SJPlayerGestureType)type location:(CGPoint)location {
    SJEdgeControlButtonItemAdapter *adapter = nil;
    BOOL(^_locationInTheView)(UIView *) = ^BOOL(UIView *container) {
        return CGRectContainsPoint(container.frame, location) && !sj_view_isDisappeared(container);
    };
    
    if ( _locationInTheView(_topContainerView) ) {
        adapter = _topAdapter;
    }
    else if ( _locationInTheView(_bottomContainerView) ) {
        adapter = _bottomAdapter;
    }
    else if ( _locationInTheView(_leftContainerView) ) {
        adapter = _leftAdapter;
    }
    else if ( _locationInTheView(_rightContainerView) ) {
        adapter = _rightAdapter;
    }
    else if ( _locationInTheView(_centerContainerView) ) {
        adapter = _centerAdapter;
    }
    if ( !adapter ) return YES;
    
    CGPoint point = [self.controlView convertPoint:location toView:adapter.view];
    if ( !CGRectContainsPoint(adapter.view.frame, point) ) return YES;
    
    SJEdgeControlButtonItem *_Nullable item = [adapter itemAtPoint:point];
    return item != nil ? (item.actions.count == 0)  : YES;
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan:
            [self _willBeginDragging];
            break;
        case SJPanGestureRecognizerStateChanged:
            [self _didMove:progressTime];
            break;
        case SJPanGestureRecognizerStateEnded:
            [self _endDragging];
            break;
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer longPressGestureStateDidChange:(SJLongPressGestureRecognizerState)state {
    if ( [(id)self.speedupPlaybackPopupView respondsToSelector:@selector(layoutInRect:gestureState:playbackRate:)] ) {
        if ( state == SJLongPressGestureRecognizerStateBegan ) {
            if ( self.speedupPlaybackPopupView.superview != self ) {
                [self insertSubview:self.speedupPlaybackPopupView atIndex:0];
            }
        }
        [self.speedupPlaybackPopupView layoutInRect:self.frame gestureState:state playbackRate:videoPlayer.rate];
    }
    else {
        switch ( state ) {
            case SJLongPressGestureRecognizerStateChanged: break;
            case SJLongPressGestureRecognizerStateBegan: {
                if ( self.speedupPlaybackPopupView.superview != self ) {
                    [self insertSubview:self.speedupPlaybackPopupView atIndex:0];
                    [self.speedupPlaybackPopupView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.center.equalTo(self.topAdapter);
                    }];
                }
                self.speedupPlaybackPopupView.rate = videoPlayer.rateWhenLongPressGestureTriggered;
                [self.speedupPlaybackPopupView show];
            }
                break;
            case SJLongPressGestureRecognizerStateEnded: {
                [self.speedupPlaybackPopupView hidden];
            }
                break;
        }
    }
}

- (void)videoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer presentationSizeDidChange:(CGSize)size {
    if ( _automaticallyPerformRotationOrFitOnScreen && !videoPlayer.isFullscreen && !videoPlayer.isFitOnScreen ) {
        _automaticallyFitOnScreen = size.width < size.height;
    }
}

/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseVideoPlayer *)videoPlayer {
    if ( sj_view_isDisappeared(_leftContainerView) ) {
        sj_view_makeAppear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl resume];
    }
    else {
        sj_view_makeDisappear(_leftContainerView, YES);
        [self.lockStateTappedTimerControl interrupt];
    }
}

- (void)lockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForFixedBackButtonIfNeeded];
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self _updateAppearStateForContainerViews];
    [self _reloadAdaptersIfNeeded];
    [self.lockStateTappedTimerControl resume];
}

- (void)unlockedVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    [self _updateAppearStateForBottomProgressIndicatorIfNeeded];
    [self.lockStateTappedTimerControl interrupt];
    [videoPlayer controlLayerNeedAppear];
}

- (void)videoPlayer:(SJBaseVideoPlayer *)videoPlayer reachabilityChanged:(SJNetworkStatus)status {
    if (@available(iOS 11.0, *)) {
        [self _reloadCustomStatusBarIfNeeded];
    }
    if ( _disabledPromptingWhenNetworkStatusChanges ) return;
    if ( [self.videoPlayer.assetURL isFileURL] ) return; // return when is local video.
    
    switch ( status ) {
        case SJNetworkStatus_NotReachable: {
            [_videoPlayer.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJVideoPlayerConfigurations.shared.localizedStrings.unstableNetworkPrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWWAN: {
            [_videoPlayer.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(SJVideoPlayerConfigurations.shared.localizedStrings.cellularNetworkPrompt);
                make.textColor(UIColor.whiteColor);
            }] duration:3];
        }
            break;
        case SJNetworkStatus_ReachableViaWiFi: {}
            break;
    }
}

#pragma mark -

- (NSString *)stringForSeconds:(NSInteger)secs {
    return _videoPlayer ? [_videoPlayer stringForSeconds:secs] : @"";
}

#pragma mark -

- (void)setHiddenBackButtonWhenOrientationIsPortrait:(BOOL)hiddenBackButtonWhenOrientationIsPortrait {
    if ( _hiddenBackButtonWhenOrientationIsPortrait != hiddenBackButtonWhenOrientationIsPortrait ) {
        _hiddenBackButtonWhenOrientationIsPortrait = hiddenBackButtonWhenOrientationIsPortrait;
        [self _updateAppearStateForFixedBackButtonIfNeeded];
        [self _reloadTopAdapterIfNeeded];
    }
}

- (void)setFixesBackItem:(BOOL)fixesBackItem {
    if ( fixesBackItem == _fixesBackItem )
        return;
    _fixesBackItem = fixesBackItem;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( self->_fixesBackItem ) {
            [self.controlView addSubview:self.fixedBackButton];
            [self->_fixedBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.equalTo(self.topAdapter.view);
                make.width.equalTo(self.topAdapter.view.mas_height);
            }];
            
            [self _updateAppearStateForFixedBackButtonIfNeeded];
            [self _reloadTopAdapterIfNeeded];
        }
        else {
            if ( self->_fixedBackButton ) {
                [self->_fixedBackButton removeFromSuperview];
                self->_fixedBackButton = nil;
                
                // back item
                [self _reloadTopAdapterIfNeeded];
            }
        }
    });
}

- (void)setHiddenBottomProgressIndicator:(BOOL)hiddenBottomProgressIndicator {
    if ( hiddenBottomProgressIndicator != _hiddenBottomProgressIndicator ) {
        _hiddenBottomProgressIndicator = hiddenBottomProgressIndicator;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _showOrRemoveBottomProgressIndicator];
        });
    }
}

- (void)setBottomProgressIndicatorHeight:(CGFloat)bottomProgressIndicatorHeight {
    if ( bottomProgressIndicatorHeight != _bottomProgressIndicatorHeight ) {
        
        _bottomProgressIndicatorHeight = bottomProgressIndicatorHeight;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _updateLayoutForBottomProgressIndicator];
        });
    }
}

- (void)setLoadingView:(nullable UIView<SJLoadingView> *)loadingView {
    if ( loadingView != _loadingView ) {
        [_loadingView removeFromSuperview];
        _loadingView = loadingView;
        if ( loadingView != nil ) {
            [self.controlView addSubview:loadingView];
            [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }
    }
}

- (void)setDraggingProgressPopupView:(nullable __kindof UIView<SJDraggingProgressPopupView> *)draggingProgressPopupView {
    _draggingProgressPopupView = draggingProgressPopupView;
    [self _updateForDraggingProgressPopupView];
}

- (void)setTitleView:(nullable __kindof UIView<SJScrollingTextMarqueeView> *)titleView {
    _titleView = titleView;
    [self _reloadTopAdapterIfNeeded];
}

- (void)setCustomStatusBar:(UIView<SJFullscreenModeStatusBar> *)customStatusBar NS_AVAILABLE_IOS(11.0) {
    if ( customStatusBar != _customStatusBar ) {
        [_customStatusBar removeFromSuperview];
        _customStatusBar = customStatusBar;
        [self _reloadCustomStatusBarIfNeeded];
    }
}

- (void)setShouldShowsCustomStatusBar:(BOOL (^)(SJEdgeControlLayer * _Nonnull))shouldShowsCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    _shouldShowsCustomStatusBar = shouldShowsCustomStatusBar;
    [self _updateAppearStateForCustomStatusBar];
}

- (void)setSpeedupPlaybackPopupView:(UIView<SJSpeedupPlaybackPopupView> *)speedupPlaybackPopupView {
    if ( _speedupPlaybackPopupView != speedupPlaybackPopupView ) {
        [_speedupPlaybackPopupView removeFromSuperview];
        _speedupPlaybackPopupView = speedupPlaybackPopupView;
    }
}

- (void)setAutomaticallyShowsPictureInPictureItem:(BOOL)automaticallyShowsPictureInPictureItem {
    if ( automaticallyShowsPictureInPictureItem != _automaticallyShowsPictureInPictureItem ) {
        _automaticallyShowsPictureInPictureItem = automaticallyShowsPictureInPictureItem;
        [self _reloadTopAdapterIfNeeded];
    }
}

#pragma mark - setup view

- (void)_setupView {
    [self _addItemsToTopAdapter];
    [self _addItemsToLeftAdapter];
    [self _addItemsToBottomAdapter];
    [self _addItemsToRightAdapter];
    [self _addItemsToCenterAdapter];
    
    self.topContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Top;
    self.leftContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Left;
    self.bottomContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Bottom;
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    self.centerContainerView.sjv_disappearDirection = SJViewDisappearAnimation_None;
    
    sj_view_initializes(@[self.topContainerView, self.leftContainerView,
                          self.bottomContainerView, self.rightContainerView]);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_resetControlLayerAppearIntervalForItemIfNeeded:) name:SJEdgeControlButtonItemPerformedActionNotification object:nil];
    
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(configurationsDidUpdate:) name:SJVideoPlayerConfigurationsDidUpdateNotification object:nil];
}

@synthesize fixedBackButton = _fixedBackButton;
- (UIButton *)fixedBackButton {
    if ( _fixedBackButton ) return _fixedBackButton;
    _fixedBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fixedBackButton setImage:SJVideoPlayerConfigurations.shared.resources.backImage forState:UIControlStateNormal];
    [_fixedBackButton addTarget:self action:@selector(_fixedBackButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
    return _fixedBackButton;
}

@synthesize bottomProgressIndicator = _bottomProgressIndicator;
- (SJProgressSlider *)bottomProgressIndicator {
    if ( _bottomProgressIndicator ) return _bottomProgressIndicator;
    _bottomProgressIndicator = [SJProgressSlider new];
    _bottomProgressIndicator.pan.enabled = NO;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    _bottomProgressIndicator.round = NO;
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    UIColor *traceColor = sources.bottomIndicatorTraceColor ?: sources.progressTraceColor;
    UIColor *trackColor = sources.bottomIndicatorTrackColor ?: sources.progressTrackColor;
    _bottomProgressIndicator.traceImageView.backgroundColor = traceColor;
    _bottomProgressIndicator.trackImageView.backgroundColor = trackColor;
    _bottomProgressIndicator.frame = CGRectMake(0, self.bounds.size.height - _bottomProgressIndicatorHeight, self.bounds.size.width, _bottomProgressIndicatorHeight);
    _bottomProgressIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return _bottomProgressIndicator;
}

@synthesize loadingView = _loadingView;
- (UIView<SJLoadingView> *)loadingView {
    if ( _loadingView == nil ) {
        [self setLoadingView:[SJLoadingView.alloc initWithFrame:CGRectZero]];
    }
    return _loadingView;
}

- (__kindof UIView<SJDraggingProgressPopupView> *)draggingProgressPopupView {
    if ( _draggingProgressPopupView == nil ) {
        [self setDraggingProgressPopupView:[SJDraggingProgressPopupView.alloc initWithFrame:CGRectZero]];
    }
    return _draggingProgressPopupView;
}

- (id<SJDraggingObservation>)draggingObserver {
    if ( _draggingObserver == nil ) {
        _draggingObserver = [SJDraggingObservation new];
    }
    return _draggingObserver;
}

@synthesize lockStateTappedTimerControl = _lockStateTappedTimerControl;
- (SJTimerControl *)lockStateTappedTimerControl {
    if ( _lockStateTappedTimerControl ) return _lockStateTappedTimerControl;
    _lockStateTappedTimerControl = [[SJTimerControl alloc] init];
    __weak typeof(self) _self = self;
    _lockStateTappedTimerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        sj_view_makeDisappear(self.leftContainerView, YES);
        [control interrupt];
    };
    return _lockStateTappedTimerControl;
}

@synthesize titleView = _titleView;
- (UIView<SJScrollingTextMarqueeView> *)titleView {
    if ( _titleView == nil ) {
        [self setTitleView:[SJScrollingTextMarqueeView.alloc initWithFrame:CGRectZero]];
    }
    return _titleView;
}

@synthesize speedupPlaybackPopupView = _speedupPlaybackPopupView;
- (UIView<SJSpeedupPlaybackPopupView> *)speedupPlaybackPopupView {
    if ( _speedupPlaybackPopupView == nil ) {
        _speedupPlaybackPopupView = [SJSpeedupPlaybackPopupView.alloc initWithFrame:CGRectZero];
    }
    return _speedupPlaybackPopupView;
}

@synthesize pictureInPictureItem = _pictureInPictureItem;
- (SJEdgeControlButtonItem *)pictureInPictureItem API_AVAILABLE(ios(14.0)) {
    if ( _pictureInPictureItem == nil ) {
        _pictureInPictureItem = [SJEdgeControlButtonItem.alloc initWithTag:SJEdgeControlLayerTopItem_PictureInPicture];
        [_pictureInPictureItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(pictureInPictureItemWasTapped)]];
    }
    return _pictureInPictureItem;
}

@synthesize customStatusBar = _customStatusBar;
- (UIView<SJFullscreenModeStatusBar> *)customStatusBar {
    if ( _customStatusBar == nil ) {
        [self setCustomStatusBar:[SJFullscreenModeStatusBar.alloc initWithFrame:CGRectZero]];
    }
    return _customStatusBar;
}

@synthesize shouldShowsCustomStatusBar = _shouldShowsCustomStatusBar;
- (BOOL (^)(SJEdgeControlLayer * _Nonnull))shouldShowsCustomStatusBar {
    if ( _shouldShowsCustomStatusBar == nil ) {
        BOOL is_iPhoneXSeries = _screen.is_iPhoneXSeries;
        [self setShouldShowsCustomStatusBar:^BOOL(SJEdgeControlLayer * _Nonnull controlLayer) {
            if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ) return NO;
            
            if ( controlLayer.videoPlayer.isFitOnScreen ) return NO;
            if ( controlLayer.videoPlayer.rotationManager.isRotating ) return NO;
            
            BOOL isFullscreen = controlLayer.videoPlayer.isFullscreen;
            if ( isFullscreen == NO ) {
                CGRect bounds = UIScreen.mainScreen.bounds;
                if ( bounds.size.width > bounds.size.height )
                    isFullscreen = CGRectEqualToRect(controlLayer.bounds, bounds);
            }
            
            BOOL shouldShow = NO;
            if ( isFullscreen ) {
                ///
                /// 13 以后, 全屏后显示自定义状态栏
                ///
                if ( @available(iOS 13.0, *) ) {
                    shouldShow = YES;
                }
                ///
                /// 11 仅 iPhone X 显示自定义状态栏
                ///
                else if ( @available(iOS 11.0, *) ) {
                    shouldShow = is_iPhoneXSeries;
                }
            }
            return shouldShow;
        }];
    }
    return _shouldShowsCustomStatusBar;
}

@synthesize dateTimerControl = _dateTimerControl;
- (SJTimerControl *)dateTimerControl {
    if ( _dateTimerControl == nil ) {
        _dateTimerControl = SJTimerControl.alloc.init;
        _dateTimerControl.interval = 1;
        __weak typeof(self) _self = self;
        _dateTimerControl.exeBlock = ^(SJTimerControl * _Nonnull control) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            self.customStatusBar.isHidden ? [control interrupt] : [self _reloadCustomStatusBarIfNeeded];
        };
    }
    return _dateTimerControl;
}

- (void)_addItemsToTopAdapter {
    SJEdgeControlButtonItem *backItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerTopItem_Back];
    backItem.resetsAppearIntervalWhenPerformingItemAction = NO;
    [backItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_backItemWasTapped)]];
    [self.topAdapter addItem:backItem];
    _backItem = backItem;

    SJEdgeControlButtonItem *titleItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49xFill tag:SJEdgeControlLayerTopItem_Title];
    [self.topAdapter addItem:titleItem];
    
    [self.topAdapter reload];
}

- (void)_addItemsToLeftAdapter {
    SJEdgeControlButtonItem *lockItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerLeftItem_Lock];
    [lockItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_lockItemWasTapped)]];
    [self.leftAdapter addItem:lockItem];
    
    [self.leftAdapter reload];
}

- (void)_addItemsToBottomAdapter {
    // 播放按钮
    SJEdgeControlButtonItem *playItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_Play];
    [playItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_playItemWasTapped)]];
    [self.bottomAdapter addItem:playItem];
    
    SJEdgeControlButtonItem *liveItem = [[SJEdgeControlButtonItem alloc] initWithTag:SJEdgeControlLayerBottomItem_LIVEText];
    liveItem.innerHidden = YES;
    [self.bottomAdapter addItem:liveItem];
    
    // 当前时间
    SJEdgeControlButtonItem *currentTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_CurrentTime];
    [self.bottomAdapter addItem:currentTimeItem];
    
    // 时间分隔符
    SJEdgeControlButtonItem *separatorItem = [[SJEdgeControlButtonItem alloc] initWithTitle:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(@"/ ").font([UIFont systemFontOfSize:11]).textColor([UIColor whiteColor]).alignment(NSTextAlignmentCenter);
    }] target:nil action:NULL tag:SJEdgeControlLayerBottomItem_Separator];
    [self.bottomAdapter addItem:separatorItem];
    
    // 全部时长
    SJEdgeControlButtonItem *durationTimeItem = [SJEdgeControlButtonItem placeholderWithSize:8 tag:SJEdgeControlLayerBottomItem_DurationTime];
    [self.bottomAdapter addItem:durationTimeItem];
    
    // 播放进度条
    SJProgressSlider *slider = [SJProgressSlider new];
    slider.trackHeight = 3;
    slider.delegate = self;
    slider.tap.enabled = YES;
    slider.showsBufferProgress = YES;
    __weak typeof(self) _self = self;
    slider.tappedExeBlock = ^(SJProgressSlider * _Nonnull slider, CGFloat location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( self.videoPlayer.canSeekToTime && self.videoPlayer.canSeekToTime(self.videoPlayer) == NO ) {
            return;
        }
        
        if ( self.videoPlayer.assetStatus != SJAssetStatusReadyToPlay ) {
            return;
        }
    
        [self.videoPlayer seekToTime:location completionHandler:nil];
    };
    SJEdgeControlButtonItem *progressItem = [[SJEdgeControlButtonItem alloc] initWithCustomView:slider tag:SJEdgeControlLayerBottomItem_Progress];
    progressItem.insets = SJEdgeInsetsMake(8, 8);
    progressItem.fill = YES;
    [self.bottomAdapter addItem:progressItem];

    // 全屏按钮
    SJEdgeControlButtonItem *fullItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJEdgeControlLayerBottomItem_Full];
    fullItem.resetsAppearIntervalWhenPerformingItemAction = NO;
    [fullItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_fullItemWasTapped)]];
    [self.bottomAdapter addItem:fullItem];

    [self.bottomAdapter reload];
}

- (void)_addItemsToRightAdapter {
    
}

- (void)_addItemsToCenterAdapter {
    UILabel *replayLabel = [UILabel new];
    replayLabel.numberOfLines = 0;
    SJEdgeControlButtonItem *replayItem = [SJEdgeControlButtonItem frameLayoutWithCustomView:replayLabel tag:SJEdgeControlLayerCenterItem_Replay];
    [replayItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_replayItemWasTapped)]];
    [self.centerAdapter addItem:replayItem];
    [self.centerAdapter reload];
}


#pragma mark - appear state

- (void)_updateAppearStateForContainerViews {
    [self _updateAppearStateForTopContainerView];
    [self _updateAppearStateForLeftContainerView];
    [self _updateAppearStateForBottomContainerView];
    [self _updateAppearStateForRightContainerView];
    [self _updateAppearStateForCenterContainerView];
    if (@available(iOS 11.0, *)) {
        [self _updateAppearStateForCustomStatusBar];
    }
}

- (void)_updateAppearStateForTopContainerView {
    if ( 0 == _topAdapter.numberOfItems ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_topContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_topContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_topContainerView, YES);
    }
}

- (void)_updateAppearStateForLeftContainerView {
    if ( 0 == _leftAdapter.numberOfItems ) {
        sj_view_makeDisappear(_leftContainerView, YES);
        return;
    }
    
    /// 锁屏状态下显示
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeAppear(_leftContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_leftContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_leftContainerView, YES);
    }
}

/// 更新显示状态
- (void)_updateAppearStateForBottomContainerView {
    if ( 0 == _bottomAdapter.numberOfItems ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_bottomContainerView, YES);
//        sj_view_makeAppear(_bottomProgressIndicator, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_bottomContainerView, YES);
//        sj_view_makeDisappear(_bottomProgressIndicator, YES);
    }
    else {
        sj_view_makeDisappear(_bottomContainerView, YES);
//        sj_view_makeAppear(_bottomProgressIndicator, YES);
    }
}

/// 更新显示状态
- (void)_updateAppearStateForRightContainerView {
    if ( 0 == _rightAdapter.numberOfItems ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 锁屏状态下, 使隐藏
    if ( _videoPlayer.isLockedScreen ) {
        sj_view_makeDisappear(_rightContainerView, YES);
        return;
    }
    
    /// 是否显示
    if ( _videoPlayer.isControlLayerAppeared ) {
        sj_view_makeAppear(_rightContainerView, YES);
    }
    else {
        sj_view_makeDisappear(_rightContainerView, YES);
    }
}

- (void)_updateAppearStateForCenterContainerView {
    if ( 0 == _centerAdapter.numberOfItems ) {
        sj_view_makeDisappear(_centerContainerView, YES);
        return;
    }
    
    sj_view_makeAppear(_centerContainerView, YES);
}

- (void)_updateAppearStateForBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator == nil )
        return;
    
    BOOL hidden = (_videoPlayer.isControlLayerAppeared && !_videoPlayer.isLockedScreen) || (_videoPlayer.isRotating);
    
    hidden ? sj_view_makeDisappear(_bottomProgressIndicator, NO) :
             sj_view_makeAppear(_bottomProgressIndicator, NO);
}

- (void)_updateAppearStateForCustomStatusBar NS_AVAILABLE_IOS(11.0) {
    BOOL shouldShow = self.shouldShowsCustomStatusBar(self);
    if ( shouldShow ) {
        if ( self.customStatusBar.superview == nil ) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                UIDevice.currentDevice.batteryMonitoringEnabled = YES;
            });
            
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_reloadCustomStatusBarIfNeeded) name:UIDeviceBatteryStateDidChangeNotification object:nil];
            
            self.customStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self.topContainerView addSubview:self.customStatusBar];
        }
        CGFloat containerW = self.topContainerView.frame.size.width;
        CGFloat statusBarW = self.topAdapter.frame.size.width;
        CGFloat startX = (containerW - statusBarW) * 0.5;
        self.customStatusBar.frame = CGRectMake(startX, 0, self.topAdapter.bounds.size.width, 20);
    }
    
    _customStatusBar.hidden = !shouldShow;
    _customStatusBar.isHidden ? [self.dateTimerControl interrupt] : [self.dateTimerControl resume];
}

- (void)_updateContentForPictureInPictureItem API_AVAILABLE(ios(14.0)) {
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    switch ( self.videoPlayer.playbackController.pictureInPictureStatus ) {
        case SJPictureInPictureStatusRunning:
            self.pictureInPictureItem.image = sources.pictureInPictureItemStopImage;
            break;
        case SJPictureInPictureStatusUnknown:
        case SJPictureInPictureStatusStarting:
        case SJPictureInPictureStatusStopping:
        case SJPictureInPictureStatusStopped:
            self.pictureInPictureItem.image = sources.pictureInPictureItemStartImage;
            break;
    }
}

#pragma mark - update items

- (void)_reloadAdaptersIfNeeded {
    [self _reloadTopAdapterIfNeeded];
    [self _reloadLeftAdapterIfNeeded];
    [self _reloadBottomAdapterIfNeeded];
    [self _reloadRightAdapterIfNeeded];
    [self _reloadCenterAdapterIfNeeded];
}

- (void)_reloadTopAdapterIfNeeded {
    if ( sj_view_isDisappeared(_topContainerView) ) return;
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    BOOL isFullscreen = _videoPlayer.isFullscreen;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;
    BOOL isSmallscreen = !isFullscreen && !isFitOnScreen;

    // back item
    {
        SJEdgeControlButtonItem *backItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Back];
        if ( backItem != nil ) {
            if ( _fixesBackItem ) {
                if ( !isFullscreen && _hiddenBackButtonWhenOrientationIsPortrait )
                    backItem.innerHidden = YES;
                else
                    backItem.innerHidden = NO;
            }
            else {
                if ( isFullscreen || isFitOnScreen )
                    backItem.innerHidden = NO;
                else if ( _hiddenBackButtonWhenOrientationIsPortrait )
                    backItem.innerHidden = YES;
                else
                    backItem.innerHidden = isPlayOnScrollView;
            }

            if ( backItem.hidden == NO ) {
                backItem.alpha = 1.0;
                backItem.image = _fixesBackItem ? nil : sources.backImage;
            }
            else {
                backItem.alpha = 0;
                backItem.image = nil;
            }
        }
    }
    
    // title item
    {
        SJEdgeControlButtonItem *titleItem = [self.topAdapter itemForTag:SJEdgeControlLayerTopItem_Title];
        if ( titleItem != nil ) {
            if ( self.isHiddenTitleItemWhenOrientationIsPortrait && isSmallscreen ) {
                titleItem.innerHidden = YES;
            }
            else {
                if ( titleItem.customView != self.titleView )
                    titleItem.customView = self.titleView;
                SJVideoPlayerURLAsset *asset = _videoPlayer.URLAsset.original ?: _videoPlayer.URLAsset;
                NSAttributedString *_Nullable attributedTitle = asset.attributedTitle;
                self.titleView.attributedText = attributedTitle;
                titleItem.innerHidden = (attributedTitle.length == 0);
            }

            if ( titleItem.hidden == NO ) {
                // margin
                NSInteger atIndex = [_topAdapter indexOfItemForTag:SJEdgeControlLayerTopItem_Title];
                CGFloat left  = [_topAdapter isHiddenWithRange:NSMakeRange(0, atIndex)] ? 16 : 0;
                CGFloat right = [_topAdapter isHiddenWithRange:NSMakeRange(atIndex, _topAdapter.numberOfItems)] ? 16 : 0;
                titleItem.insets = SJEdgeInsetsMake(left, right);
            }
        }
    }
    
    // picture in picture item
    {
        if (@available(iOS 14.0, *)) {
            if ( !self.automaticallyShowsPictureInPictureItem || (self.videoPlayer.isPlayOnScrollView && isSmallscreen) ) {
                [self.topAdapter removeItemForTag:SJEdgeControlLayerTopItem_PictureInPicture];
            }
            else if ( self.videoPlayer.playbackController.isPictureInPictureSupported ) {
                if ( ![self.topAdapter containsItem:self.pictureInPictureItem] ) {
                    [self _updateContentForPictureInPictureItem];
                    [self.topAdapter insertItem:self.pictureInPictureItem frontItem:SJEdgeControlLayerTopItem_Title];
                }
            }
        }
    }
    
    [_topAdapter reload];
}

- (void)_reloadLeftAdapterIfNeeded {
    if ( sj_view_isDisappeared(_leftContainerView) ) return;
    
    BOOL isFullscreen = _videoPlayer.isFullscreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;
    BOOL showsLockItem = isFullscreen && !_videoPlayer.rotationManager.isRotating;

    SJEdgeControlButtonItem *lockItem = [self.leftAdapter itemForTag:SJEdgeControlLayerLeftItem_Lock];
    if ( lockItem != nil ) {
        lockItem.innerHidden = !showsLockItem;
        if ( showsLockItem ) {
            id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
            lockItem.image = isLockedScreen ? sources.lockImage : sources.unlockImage;
        }
    }
    
    [_leftAdapter reload];
}

- (void)_reloadBottomAdapterIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) ) return;
    
    id<SJVideoPlayerControlLayerResources> sources = SJVideoPlayerConfigurations.shared.resources;
    id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
    
    // play item
    {
        SJEdgeControlButtonItem *playItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Play];
        if ( playItem != nil && playItem.hidden == NO ) {
            playItem.image = _videoPlayer.isPaused ? sources.playImage : sources.pauseImage;
        }
    }
    
    // progress item
    {
        SJEdgeControlButtonItem *progressItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        if ( progressItem != nil && progressItem.hidden == NO ) {
            SJProgressSlider *slider = progressItem.customView;
            slider.traceImageView.backgroundColor = sources.progressTraceColor;
            slider.trackImageView.backgroundColor = sources.progressTrackColor;
            slider.bufferProgressColor = sources.progressBufferColor;
            slider.trackHeight = sources.progressTrackHeight;
            slider.loadingColor = sources.loadingLineColor;
            
            if ( sources.progressThumbImage ) {
                slider.thumbImageView.image = sources.progressThumbImage;
            }
            else if ( sources.progressThumbSize ) {
                [slider setThumbCornerRadius:sources.progressThumbSize * 0.5 size:CGSizeMake(sources.progressThumbSize, sources.progressThumbSize) thumbBackgroundColor:sources.progressThumbColor];
            }
        }
    }
    
    // full item
    {
        SJEdgeControlButtonItem *fullItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Full];
        if ( fullItem != nil && fullItem.hidden == NO ) {
            BOOL isFullscreen = _videoPlayer.isFullscreen;
            BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
            fullItem.image = (isFullscreen || isFitOnScreen) ? sources.smallScreenImage : sources.fullscreenImage;
        }
    }
    
    // live text
    {
        SJEdgeControlButtonItem *liveItem = [self.bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_LIVEText];
        if ( liveItem != nil && liveItem.hidden == NO ) {
            liveItem.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append(strings.liveBroadcast);
                make.font(sources.titleLabelFont);
                make.textColor(sources.titleLabelColor);
                make.shadow(^(NSShadow * _Nonnull make) {
                    make.shadowOffset = CGSizeMake(0, 0.5);
                    make.shadowColor = UIColor.blackColor;
                });
            }];
        }
    }
    
    [_bottomAdapter reload];
}

- (void)_reloadRightAdapterIfNeeded {
//    if ( sj_view_isDisappeared(_rightContainerView) ) return;
    
}

- (void)_reloadCenterAdapterIfNeeded {
    if ( sj_view_isDisappeared(_centerContainerView) ) return;
    
    SJEdgeControlButtonItem *replayItem = [self.centerAdapter itemForTag:SJEdgeControlLayerCenterItem_Replay];
    if ( replayItem != nil ) {
        replayItem.innerHidden = !_videoPlayer.isPlaybackFinished;
        if ( replayItem.hidden == NO && replayItem.title == nil ) {
            id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
            id<SJVideoPlayerLocalizedStrings> strings = SJVideoPlayerConfigurations.shared.localizedStrings;
            UILabel *textLabel = replayItem.customView;
            textLabel.attributedText = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.alignment(NSTextAlignmentCenter).lineSpacing(6);
                make.font(resources.replayTitleFont);
                make.textColor(resources.replayTitleColor);
                if ( resources.replayImage != nil ) {
                    make.appendImage(^(id<SJUTImageAttachment>  _Nonnull make) {
                        make.image = resources.replayImage;
                    });
                }
                if ( strings.replay.length != 0 ) {
                    if ( resources.replayImage != nil ) make.append(@"\n");
                    make.append(strings.replay);
                }
            }];
            textLabel.bounds = (CGRect){CGPointZero, [textLabel.attributedText sj_textSize]};
        }
    }
    
    [_centerAdapter reload];
}

- (void)_updateContentForBottomCurrentTimeItemIfNeeded {
    if ( sj_view_isDisappeared(_bottomContainerView) )
        return;
    NSString *currentTimeStr = [_videoPlayer stringForSeconds:_videoPlayer.currentTime];
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    if ( currentTimeItem != nil && currentTimeItem.isHidden == NO ) {
        currentTimeItem.title = [self _textForTimeString:currentTimeStr];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_CurrentTime];
    }
}

- (void)_updateContentForBottomDurationItemIfNeeded {
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    if ( durationTimeItem != nil && durationTimeItem.isHidden == NO ) {
        durationTimeItem.title = [self _textForTimeString:[_videoPlayer stringForSeconds:_videoPlayer.duration]];
        [_bottomAdapter updateContentForItemWithTag:SJEdgeControlLayerBottomItem_DurationTime];
    }
}

- (void)_reloadSizeForBottomTimeLabel {
    // 00:00
    // 00:00:00
    NSString *ms = @"00:00";
    NSString *hms = @"00:00:00";
    NSString *durationTimeStr = [_videoPlayer stringForSeconds:_videoPlayer.duration];
    NSString *format = (durationTimeStr.length == ms.length)?ms:hms;
    CGSize formatSize = [[self _textForTimeString:format] sj_textSize];
    
    SJEdgeControlButtonItem *currentTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_CurrentTime];
    SJEdgeControlButtonItem *durationTimeItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_DurationTime];
    
    if ( !durationTimeItem && !currentTimeItem ) return;
    currentTimeItem.size = formatSize.width;
    durationTimeItem.size = formatSize.width;
    [_bottomAdapter reload];
}

- (void)_updateContentForBottomProgressSliderItemIfNeeded {
    if ( !sj_view_isDisappeared(_bottomContainerView) ) {
        SJEdgeControlButtonItem *progressItem = [_bottomAdapter itemForTag:SJEdgeControlLayerBottomItem_Progress];
        if ( progressItem != nil && !progressItem.isHidden ) {
            SJProgressSlider *slider = progressItem.customView;
            slider.maxValue = _videoPlayer.duration ? : 1;
            if ( !slider.isDragging ) slider.value = _videoPlayer.currentTime;
            slider.bufferProgress = _videoPlayer.playableDuration / slider.maxValue;
        }
    }
}

- (void)_updateContentForBottomProgressIndicatorIfNeeded {
    if ( _bottomProgressIndicator != nil && !sj_view_isDisappeared(_bottomProgressIndicator) ) {
        _bottomProgressIndicator.value = _videoPlayer.currentTime;
        _bottomProgressIndicator.maxValue = _videoPlayer.duration ? : 1;
    }
}

- (void)_updateCurrentTimeForDraggingProgressPopupViewIfNeeded {
    if ( !sj_view_isDisappeared(_draggingProgressPopupView) )
        _draggingProgressPopupView.currentTime = _videoPlayer.currentTime;
}

- (void)_updateAppearStateForFixedBackButtonIfNeeded {
    if ( !_fixesBackItem )
        return;
    BOOL isFitOnScreen = _videoPlayer.isFitOnScreen;
    BOOL isFullscreen = _videoPlayer.isFullscreen;
    BOOL isLockedScreen = _videoPlayer.isLockedScreen;
    if ( isLockedScreen ) {
        _fixedBackButton.hidden = YES;
    }
    else if ( _hiddenBackButtonWhenOrientationIsPortrait && !isFullscreen ) {
        _fixedBackButton.hidden = YES;
    }
    else {
        BOOL isPlayOnScrollView = _videoPlayer.isPlayOnScrollView;
        _fixedBackButton.hidden = isPlayOnScrollView && !isFitOnScreen && !isFullscreen;
    }
}

- (void)_updateNetworkSpeedStrForLoadingView {
    if ( !_videoPlayer || !self.loadingView.isAnimating )
        return;
    
    if ( self.loadingView.showsNetworkSpeed && !_videoPlayer.assetURL.isFileURL ) {
        self.loadingView.networkSpeedStr = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
            make.font(resources.loadingNetworkSpeedTextFont);
            make.textColor(resources.loadingNetworkSpeedTextColor);
            make.alignment(NSTextAlignmentCenter);
            make.append(self.videoPlayer.reachability.networkSpeedStr);
        }];
    }
    else {
        self.loadingView.networkSpeedStr = nil;
    }
}

- (void)_reloadCustomStatusBarIfNeeded NS_AVAILABLE_IOS(11.0) {
    if ( sj_view_isDisappeared(_customStatusBar) )
        return;
    _customStatusBar.networkStatus = _videoPlayer.reachability.networkStatus;
    _customStatusBar.date = NSDate.date;
    _customStatusBar.batteryState = UIDevice.currentDevice.batteryState;
    _customStatusBar.batteryLevel = UIDevice.currentDevice.batteryLevel;
}

#pragma mark -

- (void)_updateForDraggingProgressPopupView {
    SJDraggingProgressPopupViewStyle style = SJDraggingProgressPopupViewStyleNormal;
    if ( !_videoPlayer.URLAsset.isM3u8 &&
         [_videoPlayer.playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        if ( _videoPlayer.isFullscreen ) {
            style = SJDraggingProgressPopupViewStyleFullscreen;
        }
        else if ( _videoPlayer.isFitOnScreen ) {
            style = SJDraggingProgressPopupViewStyleFitOnScreen;
        }
    }
    _draggingProgressPopupView.style = style;
    _draggingProgressPopupView.duration = _videoPlayer.duration ?: 1;
    _draggingProgressPopupView.currentTime = _videoPlayer.currentTime;
    _draggingProgressPopupView.dragTime = _videoPlayer.currentTime;
}

- (nullable NSAttributedString *)_textForTimeString:(NSString *)timeStr {
    id<SJVideoPlayerControlLayerResources> resources = SJVideoPlayerConfigurations.shared.resources;
    return [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
        make.append(timeStr).font(resources.timeLabelFont).textColor(resources.timeLabelColor).alignment(NSTextAlignmentCenter);
    }];
}

/// 此处为重置控制层的隐藏间隔.(如果点击到当前控制层上的item, 则重置控制层的隐藏间隔)
- (void)_resetControlLayerAppearIntervalForItemIfNeeded:(NSNotification *)note {
    SJEdgeControlButtonItem *item = note.object;
    if ( item.resetsAppearIntervalWhenPerformingItemAction ) {
        if ( [_topAdapter containsItem:item] ||
             [_leftAdapter containsItem:item] ||
             [_bottomAdapter containsItem:item] ||
             [_rightAdapter containsItem:item] )
            [_videoPlayer controlLayerNeedAppear];
    }
}

- (void)_showOrRemoveBottomProgressIndicator {
    if ( _hiddenBottomProgressIndicator || _videoPlayer.playbackType == SJPlaybackTypeLIVE ) {
        if ( _bottomProgressIndicator ) {
            [_bottomProgressIndicator removeFromSuperview];
            _bottomProgressIndicator = nil;
        }
    }
    else {
        if ( !_bottomProgressIndicator ) {
            [self.controlView addSubview:self.bottomProgressIndicator];
            [self _updateLayoutForBottomProgressIndicator];
        }
    }
}

- (void)_updateLayoutForBottomProgressIndicator {
    if ( _bottomProgressIndicator == nil ) return;
    _bottomProgressIndicator.trackHeight = _bottomProgressIndicatorHeight;
    _bottomProgressIndicator.frame = CGRectMake(0, self.bounds.size.height - _bottomProgressIndicatorHeight, self.bounds.size.width, _bottomProgressIndicatorHeight);
}

- (void)_showOrHiddenLoadingView {
    if ( _videoPlayer == nil || _videoPlayer.URLAsset == nil ) {
        [self.loadingView stop];
        return;
    }
    
    if ( _videoPlayer.isPaused ) {
        [self.loadingView stop];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusPreparing ) {
        [self.loadingView start];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusFailed ) {
        [self.loadingView stop];
    }
    else if ( _videoPlayer.assetStatus == SJAssetStatusReadyToPlay ) {
        self.videoPlayer.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ? [self.loadingView start] : [self.loadingView stop];
    }
}

- (void)_willBeginDragging {
    [self.controlView addSubview:self.draggingProgressPopupView];
    [self _updateForDraggingProgressPopupView];
    [_draggingProgressPopupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    sj_view_initializes(_draggingProgressPopupView);
    sj_view_makeAppear(_draggingProgressPopupView, NO);
    
    if ( _draggingObserver.willBeginDraggingExeBlock )
        _draggingObserver.willBeginDraggingExeBlock(_draggingProgressPopupView.dragTime);
}

- (void)_didMove:(NSTimeInterval)progressTime {
    _draggingProgressPopupView.dragTime = progressTime;
    // 是否生成预览图
    if ( _draggingProgressPopupView.isPreviewImageHidden == NO ) {
        __weak typeof(self) _self = self;
        [_videoPlayer screenshotWithTime:progressTime size:CGSizeMake(_draggingProgressPopupView.frame.size.width, _draggingProgressPopupView.frame.size.height) completion:^(SJBaseVideoPlayer * _Nonnull videoPlayer, UIImage * _Nullable image, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self.draggingProgressPopupView setPreviewImage:image];
        }];
    }
    
    if ( _draggingObserver.didMoveExeBlock )
        _draggingObserver.didMoveExeBlock(_draggingProgressPopupView.dragTime);
}

- (void)_endDragging {
    NSTimeInterval time = _draggingProgressPopupView.dragTime;
    if ( _draggingObserver.willEndDraggingExeBlock )
        _draggingObserver.willEndDraggingExeBlock(time);
    
    [_videoPlayer seekToTime:time completionHandler:nil];

    sj_view_makeDisappear(_draggingProgressPopupView, YES, ^{
        if ( sj_view_isDisappeared(self->_draggingProgressPopupView) ) {
            [self->_draggingProgressPopupView removeFromSuperview];
        }
    });
    
    if ( _draggingObserver.didEndDraggingExeBlock )
        _draggingObserver.didEndDraggingExeBlock(time);
}

//#pragma mark - mark
//
//- (void)configurationsDidUpdate:(NSNotification *)note {
//    if ( @available(iOS 14.0, *) ) [self _updateContentForPictureInPictureItem];
//    [self _updateContentForBottomProgressSliderItemIfNeeded];
//}

@end


@implementation SJEdgeControlButtonItem (SJControlLayerExtended)
- (void)setResetsAppearIntervalWhenPerformingItemAction:(BOOL)resetsAppearIntervalWhenPerformingItemAction {
    objc_setAssociatedObject(self, @selector(resetsAppearIntervalWhenPerformingItemAction), @(resetsAppearIntervalWhenPerformingItemAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)resetsAppearIntervalWhenPerformingItemAction {
    id result = objc_getAssociatedObject(self, _cmd);
    return result == nil ? YES : [result boolValue];
}
@end
