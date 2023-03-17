//
//  GKDoubleLikeView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/6/19.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDoubleLikeView.h"

@interface GKDoubleLikeView()

@property (nonatomic, copy) void(^completion)(void);

@end

@implementation GKDoubleLikeView

- (void)createAnimationWithTouch:(UITouch *)touch {
    if (touch.tapCount <= 1.0f) return;
    
    [self createAnimationWithPoint:[touch locationInView:touch.view] view:touch.view completion:nil];
}

- (void)createAnimationWithPoint:(CGPoint)point view:(UIView *)view completion:(nullable void (^)(void))completion {
    self.completion = completion;
    
    UIImage *image = [UIImage imageNamed:@"likeHeart"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    imgView.image = image;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.center = point;
    
    // 随机左右显示
    int leftOrRight = arc4random() % 2;
    leftOrRight = leftOrRight ? leftOrRight : -1;
    imgView.transform = CGAffineTransformRotate(imgView.transform, M_PI / 9.0f * leftOrRight);
    [view addSubview:imgView];
    
    // 出现的时候回弹一下
    __block UIImageView *blockImgV = imgView;
    __block UIImage *blockImage = image;
    
    [UIView animateWithDuration:0.1 animations:^{
        blockImgV.transform = CGAffineTransformScale(blockImgV.transform, 1.2f, 1.2f);
    } completion:^(BOOL finished) {
        blockImgV.transform = CGAffineTransformScale(blockImgV.transform, 0.8f, 0.8f);
        
        // 向上飘，放大，透明
        [self performSelector:@selector(animationToTop:) withObject:@[blockImgV, blockImage] afterDelay:0.3f];
    }];
}

- (void)animationToTop:(NSArray *)imgObjects {
    if (imgObjects && imgObjects.count > 0) {
        __block UIImageView *imgView = (UIImageView *)imgObjects.firstObject;
        __block UIImage *image = (UIImage *)imgObjects.lastObject;
        [UIView animateWithDuration:1.0f animations:^{
            CGRect imgViewFrame = imgView.frame;
            imgViewFrame.origin.y -= 100.0f;
            imgView.frame = imgViewFrame;
            imgView.transform = CGAffineTransformScale(imgView.transform, 1.8f, 1.8f);
            imgView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [imgView removeFromSuperview];
            imgView = nil;
            image = nil;
            !self.completion ?: self.completion();
        }];
    }
}

@end
