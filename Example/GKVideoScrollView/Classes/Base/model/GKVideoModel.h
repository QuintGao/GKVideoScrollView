//
//  GKVideoModel.h
//  Example
//
//  Created by QuintGao on 2023/3/13.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKVideoModel : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *poster_small;
@property (nonatomic, copy) NSString *poster_big;
@property (nonatomic, copy) NSString *poster_pc;
@property (nonatomic, copy) NSString *source_name;
@property (nonatomic, copy) NSString *play_url;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *show_tag;
@property (nonatomic, copy) NSString *publish_time;
@property (nonatomic, copy) NSString *is_pay_column;
@property (nonatomic, copy) NSString *like;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *playcnt;
@property (nonatomic, copy) NSString *fmplaycnt;
@property (nonatomic, copy) NSString *fmplaycnt_2;
@property (nonatomic, copy) NSString *outstand_tag;
@property (nonatomic, copy) NSString *previewUrlHttp;
@property (nonatomic, copy) NSString *third_id;
@property (nonatomic, copy) NSString *vip;
@property (nonatomic, copy) NSString *author_avatar;

@property (nonatomic, assign) BOOL isLike;

@end

NS_ASSUME_NONNULL_END
