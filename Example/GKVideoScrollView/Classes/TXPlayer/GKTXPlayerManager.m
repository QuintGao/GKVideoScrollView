//
//  GKTXPlayerManager.m
//  Example
//
//  Created by QuintGao on 2024/11/13.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKTXPlayerManager.h"
#import <TXLiteAVSDK_Player/TXVodPlayer.h>

@interface GKTXPlayerManager()<TXVodPlayListener>

@property (nonatomic, strong) TXVodPlayer *player;

@property (nonatomic, copy) void(^seekCompletion)(BOOL);

@property (nonatomic, assign) BOOL isSetUrl;

@end

@implementation GKTXPlayerManager

@synthesize view                           = _view;
@synthesize currentTime                    = _currentTime;
@synthesize totalTime                      = _totalTime;
@synthesize playerPlayTimeChanged          = _playerPlayTimeChanged;
@synthesize playerBufferTimeChanged        = _playerBufferTimeChanged;
@synthesize playerDidToEnd                 = _playerDidToEnd;
@synthesize bufferTime                     = _bufferTime;
@synthesize playState                      = _playState;
@synthesize loadState                      = _loadState;
@synthesize assetURL                       = _assetURL;
@synthesize playerPrepareToPlay            = _playerPrepareToPlay;
@synthesize playerReadyToPlay              = _playerReadyToPlay;
@synthesize playerPlayStateChanged         = _playerPlayStateChanged;
@synthesize playerLoadStateChanged         = _playerLoadStateChanged;
@synthesize seekTime                       = _seekTime;
@synthesize muted                          = _muted;
@synthesize volume                         = _volume;
@synthesize presentationSize               = _presentationSize;
@synthesize isPlaying                      = _isPlaying;
@synthesize rate                           = _rate;
@synthesize isPreparedToPlay               = _isPreparedToPlay;
@synthesize shouldAutoPlay                 = _shouldAutoPlay;
@synthesize scalingMode                    = _scalingMode;
@synthesize playerPlayFailed               = _playerPlayFailed;
@synthesize presentationSizeChanged        = _presentationSizeChanged;

- (instancetype)init {
    self = [super init];
    if (self) {
        _scalingMode = ZFPlayerScalingModeAspectFit;
        _shouldAutoPlay = YES;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"GKTXPlayerManager dealloc");
    [self stop];
}

- (void)prepareToPlay {
    if (!_assetURL) return;
    _isPreparedToPlay = YES;
    [self initializePlayer];
    if (self.shouldAutoPlay) {
        [self play];
    }
    self.loadState = ZFPlayerLoadStatePrepare;
    if (self.playerPrepareToPlay) self.playerPrepareToPlay(self, self.assetURL);
}

- (void)reloadPlayer {
    self.seekTime = self.currentTime;
    [self prepareToPlay];
}

- (void)play {
    if (!_isPreparedToPlay) {
        [self prepareToPlay];
    } else {
        if (self.isSetUrl) {
            [self.player resume];
        }else {
            [self.player startVodPlay:self.assetURL.absoluteString];
            self.player.rate = self.rate;
            self.isSetUrl = YES;
        }
        self->_isPlaying = YES;
        self.playState = ZFPlayerPlayStatePlaying;
    }
}

- (void)pause {
    [self.player pause];
    self->_isPlaying = NO;
    self.playState = ZFPlayerPlayStatePaused;
}

- (void)stop {
    self.loadState = ZFPlayerLoadStateUnknown;
    self.playState = ZFPlayerPlayStatePlayStopped;
    self.player.vodDelegate = nil;
    [self.player stopPlay];
    [self.player removeVideoWidget];
    self.presentationSize = CGSizeZero;
    _isPlaying = NO;
    _player = nil;
    _assetURL = nil;
    _isPreparedToPlay = NO;
    self->_currentTime = 0;
    self->_totalTime = 0;
    self->_bufferTime = 0;
    self.isSetUrl = NO;
}

- (void)replay {
    @zf_weakify(self)
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        @zf_strongify(self)
        if (finished) {
            [self play];
        }
    }];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    self.seekCompletion = completionHandler;
    if (self.totalTime > 0) {
        [self.player seek:time accurateSeek:YES];
    } else {
        self.seekTime = time;
    }
}

- (UIImage *)thumbnailImageAtCurrentTime {
    __block UIImage *image = nil;
    
    [self.player snapshot:^(UIImage *img) {
        image = img;
    }];
    
    return image;
}

- (void)thumbnailImageAtCurrentTime:(void(^)(UIImage *))handler {
    [self.player snapshot:^(UIImage *image) {
        !handler ?: handler(image);
    }];
}

#pragma mark - private method

- (void)initializePlayer {
    self.player = [[TXVodPlayer alloc] init];
    
    // 设置代理
    self.player.vodDelegate = self;
    
    // 设置部分视图
    UIView *playerView = [[UIView alloc] init];
    self.view.playerView = playerView;
    [self.player setupVideoWidget:playerView insertIndex:0];
    
    // 是否自动播放
    self.player.isAutoPlay = self.shouldAutoPlay;
}

#pragma mark - TXVodPlayListener
- (void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param {
    if (EvtID == PLAY_EVT_VOD_PLAY_PREPARED) {
        // 播放器准备完成事件
        // 设置尺寸
        CGSize size = CGSizeMake(player.width, player.height);
        self.presentationSize = size;
        self.loadState = ZFPlayerLoadStatePlaythroughOK;
        if (self.seekTime > 0) {
            [self.player seek:self.seekTime accurateSeek:YES];
            self.seekTime = 0;
        }
    }else if (EvtID == PLAY_EVT_PLAY_LOADING) {
        // 加载中事件
        self.loadState = ZFPlayerLoadStateStalled;
    }else if (EvtID == PLAY_EVT_VOD_LOADING_END) {
        // 加载完成事件
        self.loadState = ZFPlayerLoadStatePlayable;
    }else if (EvtID == PLAY_ERR_NET_DISCONNECT ||
              EvtID == PLAY_ERR_HLS_KEY ||
              EvtID == VOD_PLAY_ERR_SYSTEM_PLAY_FAIL ||
              EvtID == VOD_PLAY_ERR_DECODE_VIDEO_FAIL ||
              EvtID == VOD_PLAY_ERR_DECODE_AUDIO_FAIL ||
              EvtID == VOD_PLAY_ERR_DECODE_SUBTITLE_FAIL ||
              EvtID == VOD_PLAY_ERR_RENDER_FAIL ||
              EvtID == VOD_PLAY_ERR_PROCESS_VIDEO_FAIL ||
              EvtID == VOD_PLAY_ERR_GET_PLAYINFO_FAIL) {
        // 播放失败事件
        self.playState = ZFPlayerPlayStatePlayFailed;
        self->_isPlaying = NO;
        NSInteger code = [param[VOD_PLAY_EVT_ERROR_CODE] integerValue];
        NSString *msg = param[VOD_PLAY_EVENT_MSG];
        NSError *error = [NSError errorWithDomain:@"TXErrorDomain" code:code userInfo:@{NSLocalizedDescriptionKey: msg}];
        if (self.playerPlayFailed) {
            self.playerPlayFailed(self, error);
        }
    }else if (EvtID == PLAY_EVT_PLAY_PROGRESS) {
        // 视频播放进度，会通知当前播放进度、加载进度和总体时长
        
        // 播放进度
        if (self.playerPlayTimeChanged) {
            self.playerPlayTimeChanged(self, self.currentTime, self.totalTime);
        }
        
        // 加载进度
        if (self.playerBufferTimeChanged) {
            self.playerBufferTimeChanged(self, self.bufferTime);
        }
    }else if (EvtID == PLAY_EVT_PLAY_END) {
        // 播放结束事件
        if (self.playerDidToEnd) {
            self.playerDidToEnd(self);
        }
    }else if (EvtID == VOD_PLAY_EVT_VOD_PLAY_SEEK_COMPLETE) {
        !self.seekCompletion ?: self.seekCompletion(YES);
    }
}

#pragma mark - getter

- (ZFPlayerView *)view {
    if (!_view) {
        ZFPlayerView *view = [[ZFPlayerView alloc] init];
        _view = view;
    }
    return _view;
}

- (float)rate {
    return _rate == 0 ?1:_rate;
}

- (NSTimeInterval)totalTime {
    NSTimeInterval sec = self.player.duration;
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = self.player.currentPlaybackTime;
    if (isnan(sec) || sec < 0) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)bufferTime {
    NSTimeInterval sec = self.player.playableDuration;
    if (isnan(sec) || sec < 0) {
        return 0;
    }
    return sec;
}

#pragma mark - setter

- (void)setPlayState:(ZFPlayerPlaybackState)playState {
    _playState = playState;
    if (self.playerPlayStateChanged) self.playerPlayStateChanged(self, playState);
}

- (void)setLoadState:(ZFPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playerLoadStateChanged) self.playerLoadStateChanged(self, loadState);
}

- (void)setAssetURL:(NSURL *)assetURL {
    if (self.player) [self stop];
    _assetURL = assetURL;
    [self prepareToPlay];
}

- (void)setRate:(float)rate {
    _rate = rate;
    self.player.rate = rate;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    [self.player setMute:muted];
}

- (void)setScalingMode:(ZFPlayerScalingMode)scalingMode {
    _scalingMode = scalingMode;
    self.view.scalingMode = scalingMode;
    switch (scalingMode) {
        case ZFPlayerScalingModeNone:
            [self.player setRenderMode:RENDER_MODE_FILL_SCREEN];
            break;
        case ZFPlayerScalingModeAspectFit:
            [self.player setRenderMode:RENDER_MODE_FILL_EDGE];
            break;
        case ZFPlayerScalingModeAspectFill:
            [self.player setRenderMode:RENDER_MODE_FILL_SCREEN];
            break;
        case ZFPlayerScalingModeFill:
            [self.player setRenderMode:RENDER_MODE_FILL_EDGE];
            break;
        default:
            break;
    }
}

- (void)setVolume:(float)volume {
    _volume = MIN(MAX(0, volume), 1);
    
    // volume 0-1 转换为0-150
    float playVolume = volume * 150;
    
    [self.player setAudioPlayoutVolume:playVolume];
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    self.view.presentationSize = presentationSize;
    if (self.presentationSizeChanged) {
        self.presentationSizeChanged(self, self.presentationSize);
    }
}

@end
