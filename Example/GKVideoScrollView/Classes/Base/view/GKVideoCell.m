//
//  GKVideoCell.m
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

@interface GKVideoCell()

@end

@implementation GKVideoCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.coverImgView];
    
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)loadData:(GKVideoModel *)model {
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
}

- (void)resetView {
    
}

- (void)scrollViewBeginDragging {
    
}

- (void)scrollViewDidEndDragging {
    
}

- (void)showLoading {
    
}

- (void)hideLoading {
    
}

- (void)setProgress:(float)progress {
    
}

#pragma mark - Lazy
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
    }
    return _coverImgView;
}

@end
