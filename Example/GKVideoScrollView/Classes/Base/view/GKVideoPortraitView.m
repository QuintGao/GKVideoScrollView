//
//  GKVideoPortraitView.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoPortraitView.h"
#import <Masonry/Masonry.h>

@interface GKVideoPortraitView()


@end

@implementation GKVideoPortraitView

@synthesize restarted = _restarted;

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToVideoPlayer:(__kindof SJBaseVideoPlayer *)videoPlayer {
    
}

- (void)restartControlLayer {
    _restarted = YES;
}

- (void)exitControlLayer {
    _restarted = NO;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.playBtn];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"ss_icon_pause"] forState:UIControlStateNormal];
        _playBtn.userInteractionEnabled = NO;
        _playBtn.hidden = YES;
    }
    return _playBtn;
}

- (GKDoubleLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKDoubleLikeView alloc] init];
    }
    return _likeView;
}

@end
