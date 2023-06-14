//
//  GKTestCell1.m
//  Example
//
//  Created by QuintGao on 2023/6/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKTestCell1.h"
#import <Masonry/Masonry.h>

@implementation GKTestCell1

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)loadData:(GKTestModel *)model {
    self.textLabel.text = [NSString stringWithFormat:@"%@---%zd", @"GKTestCell1", model.pos];
}

#pragma mark - Lazy
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:16];
        _textLabel.textColor = UIColor.whiteColor;
    }
    return _textLabel;
}

@end
