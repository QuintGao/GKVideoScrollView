//
//  SJButtonProgressSlider.h
//
//  Created by 畅三江 on 2017/11/20.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJCommonProgressSlider.h"

/*!
 *  two button each on the left and right.
 *  You can adjust the spacing by setting `spacing`.
 *
 *  两个按钮, 分别在左边和右边.
 *  你可以设置父类中的`spacing`, 来调整他们之间的间距.
 **/
NS_ASSUME_NONNULL_BEGIN
@interface SJButtonProgressSlider : SJCommonProgressSlider

@property (nonatomic, strong, readonly) UIButton *leftBtn;
@property (nonatomic, strong, readonly) UIButton *rightBtn;

@property (nonatomic, strong, nullable) NSString *leftText;
@property (nonatomic, strong, nullable) NSString *rightText;

@property (nonatomic, strong, nullable) UIColor *titleColor;

@property (nonatomic, strong, nullable) UIFont *font;

@end
NS_ASSUME_NONNULL_END
