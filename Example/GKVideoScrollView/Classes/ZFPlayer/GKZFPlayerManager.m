//
//  GKZFPlayerManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKZFPlayerManager.h"
#import "GKZFPortraitView.h"
#import "GKZFLandscapeView.h"
#import <SDWebImage/SDWebImage.h>
#import "GKVideoPlayerViewController.h"
//#import <KTVHTTPCache/KTVHTTPCache.h>
#import <SJMediaCacheServer/SJMediaCacheServer.h>

@interface GKZFPlayerManager()

@property (nonatomic, strong) GKZFPortraitView *portraitView;

@property (nonatomic, strong) GKZFLandscapeView *landscapeView;

@property (nonatomic, strong) id<MCSPrefetchTask> lastPrefetchTask;
@property (nonatomic, strong) id<MCSPrefetchTask> nextPrefetchTask;

@end

@implementation GKZFPlayerManager

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d -- [%@ %s]", (int)__LINE__, NSStringFromClass(self.class), sel_getName(_cmd));
#endif
}

- (void)initPlayer {
    // 初始化播放器
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = YES; // 自动播放
    
    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO;
    self.player = player;
    
    // 设置竖屏controlView
    self.player.controlView = self.portraitView;
    
    __weak __typeof(self) weakSelf = self;
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        __strong __typeof(weakSelf) self = weakSelf;
        // 重播
        [self.player.currentPlayerManager replay];
    };
    
    // 加载状态改变回调
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        __strong __typeof(weakSelf) self = weakSelf;
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            [self.currentCell showLoading];
        }else {
            [self.currentCell hideLoading];
        }
    };
    
    // 播放进度回调
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        __strong __typeof(weakSelf) self = weakSelf;
        [self.currentCell setProgress:self.player.progress];
    };
    
    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        self.player.controlView.hidden = YES;
        if (player.isFullScreen) {
            [self.landscapeView.statusBar startTimer];
        }else {
            [self.landscapeView.statusBar destoryTimer];
        }
    };
    
    // 方向已经改变
    player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (isFullScreen) {
            self.landscapeView.hidden = NO;
            self.player.controlView = self.landscapeView;
        }else {
            self.portraitView.hidden = NO;
            self.player.controlView = self.portraitView;
        }
    };
}

- (void)mediaCacheServer {
    // 开启控制台log
    [SJMediaCacheServer shared].enabledConsoleLog = YES;
//    [SJMediaCacheServer shared].resolveAssetIdentifier = ^NSString * _Nonnull(NSURL * _Nonnull URL) {
//        return [URL.absoluteString stringByDeletingPathExtension];
//    };
}

#pragma mark -

//- (void)ktv_loaderDidFinish:(KTVHCDataLoader *)loader {
//    NSLog(@"预加载完成---");
//}
//
//- (void)ktv_loader:(KTVHCDataLoader *)loader didFailWithError:(NSError *)error {
//    NSLog(@"预加载失败---%@", error);
//    
//}
//- (void)ktv_loader:(KTVHCDataLoader *)loader didChangeProgress:(double)progress {
//    NSLog(@"预加载进度更新---%f", progress);
//}

- (void)destoryPlayer {
    [self.player stop];
    self.player = nil;
}

// 预加载指定url的`1M`的内容
- (nullable id<MCSPrefetchTask>)_prefetchTaskWithIndex:(NSInteger)index {
    if (index < 0 || index > self.dataSource.count) {
        return nil;
    }
    GKVideoModel *model = self.dataSource[index];
    
    return [[SJMediaCacheServer shared] prefetchWithURL:[NSURL URLWithString:model.play_url] preloadSize:1 * 1024 * 1024];
}

- (void)preloadVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
    NSLog(@"即将出现---%zd", index);
    
//    // 根据索引获取url
//    GKVideoModel *model = self.dataSource[index];
//    NSLog(@"播放url===%@", model.url);
//    
//    if (model.play_url) {
//        NSURL *url = [NSURL URLWithString:model.play_url];
//        KTVHCDataRequest *request = [[KTVHCDataRequest alloc] initWithURL:url headers:nil];
//        KTVHCDataLoader *loader = [KTVHTTPCache cacheLoaderWithRequest:request];
//        loader.delegate = self;
//        [loader prepare];
//    }
    [self.lastPrefetchTask cancel];
    [self.nextPrefetchTask cancel];
    self.lastPrefetchTask = [self _prefetchTaskWithIndex:index - 1];
    self.nextPrefetchTask = [self _prefetchTaskWithIndex:index + 1];
}

- (void)playVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
//    // 预加载下一页数据
//    if (index == self.dataSource.count - 1) {
//        NSLog(@"预加载下一个页");
//        [self.viewController requestMoreData];
//    }
    
//    NSLog(@"播放----%zd", index);
    GKVideoModel *model = self.dataSource[index];
    
    [self.landscapeView loadData:model];
    
    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }
    
    // 设置视频封面图
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    manager.view.coverImageView.image = nil;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    // 播放内容一致，不做处理
    NSString *playUrl = manager.assetURL.absoluteString;
    if (playUrl.length > 0 && [playUrl isEqualToString:model.play_url]) return;
    
    NSURL *url = [NSURL URLWithString:model.play_url];
    
//    NSURL *proxyURL = [KTVHTTPCache proxyURLWithOriginalURL:url];
    NSURL *proxyURL = [[SJMediaCacheServer shared] playbackURLWithURL:url];
    
//    self.player.assetURL = [NSURL URLWithString:model.play_url];
    self.player.assetURL = proxyURL;
    self.portraitView.playBtn.hidden = YES;
    
    
}

- (void)stopVideoWithCell:(GKVideoCell *)cell index:(NSInteger)index {
//    NSLog(@"停止---%zd", index);
    GKVideoModel *model = self.dataSource[index];
    
    // 判断播放内容是否一致
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    
    NSString *playUrl = manager.assetURL.absoluteString;
    if (playUrl.length > 0 && ![playUrl isEqualToString:model.play_url]) return;
    
    [self.player stop];
    [cell resetView];
}

- (void)enterFullScreen {
    [self.player enterFullScreen:YES animated:YES];
}

- (void)longAction {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"测试" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"不感兴趣(有动画)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.portraitScrollView removeCurrentPageAnimated:YES];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"不感兴趣(无动画)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.portraitScrollView removeCurrentPageAnimated:NO];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"清空后切换索引" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.dataSource removeAllObjects];
        [self.portraitScrollView reloadData];
        
        self.portraitScrollView.defaultIndex = self.currentIndex;
        [self.viewController requestNewData];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"顶部插入数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.viewController requestNewDataInsertFront];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"加载下一页" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.viewController requestMoreData];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.viewController presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - Lazy
- (GKZFPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKZFPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _portraitView.likeBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:nil];
        };
        
        _portraitView.longBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self longAction];
        };
    }
    return _portraitView;
}

- (GKZFLandscapeView *)landscapeView {
    if (!_landscapeView) {
        _landscapeView = [[GKZFLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        __weak __typeof(self) weakSelf = self;
        _landscapeView.likeBlock = ^(GKVideoModel *model) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self likeVideoWithModel:model];
        };
    }
    return _landscapeView;
}

@end
