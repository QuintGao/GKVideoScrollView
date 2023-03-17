//
//  SJAttributeWorker.m
//  SJAttributeWorker
//
//  Created by 畅三江 on 2017/11/12.
//  Copyright © 2017年 畅三江. All rights reserved.
//

#import "SJAttributeWorker.h"
#import <CoreText/CoreText.h>
#import <objc/message.h>
#import "SJAttributesRecorder.h"

NS_ASSUME_NONNULL_BEGIN

NSMutableAttributedString *sj_makeAttributesString(void(^block)(SJAttributeWorker *make)) {
    SJAttributeWorker *worker = [SJAttributeWorker new];
    block(worker);
    return worker.endTask;
}

inline static BOOL _rangeContains(NSRange range, NSRange subRange) {
    return (range.location <= subRange.location) && (range.location + range.length >= subRange.location + subRange.length);
}

#ifdef DEBUG
inline static void _errorLog(NSString *msg, id __nullable target) {
    NSLog(@"\n__Error__: %@\nTarget: %@", msg, target);
}
#else
#define _errorLog(...)
#endif

#pragma mark -

@interface SJAttributesRangeOperator ()
@property (nonatomic, strong, readonly) SJAttributesRecorder *recorder;
@property (nonatomic) BOOL needToAdd; // deafult is Yes.

- (void)reset:(SJAttributesRecorder *)recorder;
@end

@implementation SJAttributesRangeOperator {
    NSMutableAttributedString *_target;
}

- (instancetype)initWithRange:(NSRange)range target:(__strong NSMutableAttributedString *)attrStr {
    SJAttributesRecorder *obj = [SJAttributesRecorder new];
    obj.range = range;
    return [self initWithRecorder:obj target:attrStr];
}

- (instancetype)initWithRecorder:(SJAttributesRecorder *)recorder target:(__strong NSMutableAttributedString *)attrStr {
    self = [super init];
    if ( !self ) return nil;
    _target = attrStr;
    [self reset:recorder];
    return self;
}

- (void)reset:(SJAttributesRecorder *)recorder {
    _recorder = recorder;
    _needToAdd = YES;
    __weak typeof(self) _self = self;
    _recorder.propertyDidChangeExeBlock = ^(SJAttributesRecorder * _Nonnull recorder) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self.needToAdd = YES;
    };
}

- (void)addAttributesToTargetIfNeeded {
    if ( !_needToAdd ) return;
    else _needToAdd = NO;
    
#ifdef SJ_MAC
    NSLog(@"%@", self);
#endif
    
    NSRange range = _recorder.range;
    if ( range.location == 0 && range.length == 0 ) {
        range = NSMakeRange(0, _target.length);
    }
    if ( range.length == 0 ) return;
    if ( nil != _recorder.font ) {
        [_target addAttribute:NSFontAttributeName value:_recorder.font range:range];
    }
    if ( nil != _recorder.textColor ) {
        [_target addAttribute:NSForegroundColorAttributeName value:_recorder.textColor range:range];
    }
    if ( 0 != _recorder.expansion ) {
        [_target addAttribute:NSExpansionAttributeName value:@(_recorder.expansion) range:range];
    }
    if ( nil != _recorder.shadow ) {
        [_target addAttribute:NSShadowAttributeName value:_recorder.shadow range:range];
    }
    if ( nil != _recorder.backgroundColor ) {
        [_target addAttribute:NSBackgroundColorAttributeName value:_recorder.backgroundColor range:range];
    }
    if ( nil != _recorder.underLine ) {
        [_target addAttribute:NSUnderlineStyleAttributeName value:@(_recorder.underLine.value) range:range];
        [_target addAttribute:NSUnderlineColorAttributeName value:_recorder.underLine.color range:range];
    }
    if ( nil != _recorder.strikethrough ) {
        [_target addAttribute:NSStrikethroughStyleAttributeName value:@(_recorder.strikethrough.value) range:range];
        [_target addAttribute:NSStrikethroughColorAttributeName value:_recorder.strikethrough.color range:range];
    }
    if ( nil != _recorder.stroke ) {
        [_target addAttribute:NSStrokeWidthAttributeName value:@(_recorder.stroke.value) range:range];
        [_target addAttribute:NSStrokeColorAttributeName value:_recorder.stroke.color range:range];
    }
    if ( 0 != _recorder.obliqueness ) {
        [_target addAttribute:NSObliquenessAttributeName value:@(_recorder.obliqueness) range:range];
    }
    if ( 0 != _recorder.letterSpacing ) {
        [_target addAttribute:NSKernAttributeName value:@(_recorder.letterSpacing) range:range];
    }
    if ( 0 != _recorder.offset ) {
        [_target addAttribute:NSBaselineOffsetAttributeName value:@(_recorder.offset) range:range];
    }
    if ( YES == _recorder.link ) {
        [_target addAttribute:NSLinkAttributeName value:@(1) range:range];
    }
    if ( nil != _recorder.paragraphStyleM ) {
        [_target addAttribute:NSParagraphStyleAttributeName value:_recorder.paragraphStyleM range:range];
    }
}

- (void)removeAttributeWithKey:(NSAttributedStringKey)attributedStringKey {
    if      ( attributedStringKey == NSFontAttributeName ) _recorder.font = nil;
    else if ( attributedStringKey == NSForegroundColorAttributeName ) _recorder.textColor = nil;
    else if ( attributedStringKey == NSExpansionAttributeName ) _recorder.expansion = 0;
    else if ( attributedStringKey == NSShadowAttributeName ) _recorder.shadow = nil;
    else if ( attributedStringKey == NSBackgroundColorAttributeName ) _recorder.backgroundColor = nil;
    else if ( attributedStringKey == NSUnderlineStyleAttributeName ) _recorder.underLine = nil;
    else if ( attributedStringKey == NSStrikethroughStyleAttributeName ) _recorder.strikethrough = nil;
    else if ( attributedStringKey == NSStrokeWidthAttributeName ) _recorder.stroke = nil;
    else if ( attributedStringKey == NSObliquenessAttributeName ) _recorder.obliqueness = 0;
    else if ( attributedStringKey == NSKernAttributeName ) _recorder.letterSpacing = 0;
    else if ( attributedStringKey == NSBaselineOffsetAttributeName ) _recorder.offset = 0;
    else if ( attributedStringKey == NSLinkAttributeName ) _recorder.link = NO;
    else if ( attributedStringKey == NSParagraphStyleAttributeName ) _recorder.paragraphStyleM = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
}
@end

#pragma mark -

@interface SJAttributeWorker ()
@property (nonatomic, strong, readonly) NSMutableAttributedString *attrStr;
@property (nonatomic, strong, readonly) NSMutableArray<SJAttributesRangeOperator *> *rangeOperatorsM;
@end

@implementation SJAttributeWorker
- (instancetype)init {
    NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
    self = [super initWithRange:NSMakeRange(0, 0) target:attrStr];
    if ( !self ) return nil;
    _rangeOperatorsM = [NSMutableArray array];
    self->_attrStr = attrStr;
    return self;
}

- (NSRange)range {
    return NSMakeRange(0, self->_attrStr.length);
}

- (NSInteger)length {
    return self->_attrStr.length;
}

- (void)pauseTask {
    [self endTask];
}

- (NSMutableAttributedString *)workInProcess {
    return self->_attrStr;
}

- (void)setDefaultFont:(UIFont *_Nullable)defaultFont {
    self.recorder.font = defaultFont;
}

- (UIFont *)defaultFont {
    return self.recorder.font?:[UIFont systemFontOfSize:14];
}

- (void)setDefaultTextColor:(UIColor *_Nullable)defaultTextColor {
    self.recorder.textColor = defaultTextColor;
}

- (UIColor *)defaultTextColor {
    return self.recorder.textColor?:[UIColor blackColor];
}

- (NSMutableAttributedString *)endTask {
    if ( 0 == self->_attrStr.length ) return self->_attrStr;
    [self addAttributesToTargetIfNeeded];
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self _addCommonValuesToRecorderIfNeed:obj.recorder];
        [obj addAttributesToTargetIfNeeded];
    }];
    return self->_attrStr;
}

- (void)_addCommonValuesToRecorderIfNeed:(SJAttributesRecorder *)recorder {
    if ( nil == recorder.font ) recorder.font = self.defaultFont;
    if ( nil == recorder.textColor ) recorder.textColor = self.defaultTextColor;
    if ( 0 == recorder.lineSpacing ) recorder.lineSpacing = self.recorder.lineSpacing;
    if ( nil == recorder.alignment ) recorder.alignment = self.recorder.alignment;
}

- (NSMutableAttributedString *)endTaskAndComplete:(void(^)(SJAttributeWorker *worker))block; {
    [self endTask];
    if ( block ) block(self);
    return self->_attrStr;
}

/// 范围编辑. 可以配合正则使用.
- (SJAttributeWorker * _Nonnull (^)(NSRange, void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))rangeEdit {
    return ^ SJAttributeWorker *(NSRange range, void(^task)(SJAttributesRangeOperator *matched)) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Edit Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return self;
        }
        SJAttributesRangeOperator *rangeOperator = [self _getOperatorWithRange:range];
        task(rangeOperator);
        return self;
    };
}

/// sub attr str
- (NSAttributedString * _Nonnull (^)(NSRange))subAttrStr {
    return ^ NSAttributedString *(NSRange subRange) {
        if ( !_rangeContains(self.range, subRange) ) {
            _errorLog(@"Get `subAttributedString` Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return nil;
        }
        [self pauseTask];
        return [self->_attrStr attributedSubstringFromRange:subRange];
    };
}

- (SJAttributesRangeOperator *)_getOperatorWithRange:(NSRange)range {
    __block SJAttributesRangeOperator *rangeOperator = nil;
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        if ( objRange.location == range.location && objRange.length == range.length ) {
            rangeOperator = obj;
            *stop = YES;
        }
    }];
    
    if ( rangeOperator ) return rangeOperator;
    
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        if ( _rangeContains(objRange, range) ) {
            rangeOperator = [[SJAttributesRangeOperator alloc] initWithRecorder:obj.recorder.mutableCopy target:self->_attrStr];
            rangeOperator.recorder.range = range;
            [self.rangeOperatorsM addObject:rangeOperator];
            *stop = YES;
        }
    }];
    
    if ( rangeOperator ) return rangeOperator;
    
    rangeOperator = [[SJAttributesRangeOperator alloc] initWithRange:range target:self->_attrStr];
    [self.rangeOperatorsM addObject:rangeOperator];
    return rangeOperator;
}

- (void)_adjustOperatorsWhenRemovingText:(NSRange)deletingRange {
    NSInteger deletingLinePoint = deletingRange.location + deletingRange.length;
    [self.rangeOperatorsM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        NSInteger objLinePoint = objRange.location + objRange.length;
        /**
                    1                               2
         -----------|<------------ObjRange--------->|----------------------
                        3                     4
         ---------------|<---DeletingRange--->|----------------------------
         - 1 objRange.location
         - 2 objLinePoint (objRange.location + objRange.length)
         - 3 deletingRange.location
         - 4 deletingLinePoint (deletingRange.location + deletingRange.length)
         */
        if ( _rangeContains(deletingRange, objRange) ) {
            [self.rangeOperatorsM removeObject:obj];
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         -------------------|<------------DeletingRange--------->|---------
         */
        else if ( objRange.location <= deletingRange.location && deletingRange.location < objLinePoint ) {
            objRange.length = objLinePoint - deletingRange.location;
            obj.recorder.range = objRange;  // adjust
        }
        /**
         ----------------------|<------------ObjRange--------->|-----------
         -----------|<------------DeletingRange--------->|-----------------
         */
        else if ( deletingRange.location <= objRange.location && objRange.location < deletingLinePoint ) {
            objRange.location = deletingRange.location;
            objRange.length = objLinePoint - deletingLinePoint;
            obj.recorder.range = objRange;  // adjust
        }
        /**
         -------------------------------|<---ObjRange--->|----------------
         ---|<---DeletingRange--->|---------------------------------------
         */
        else if ( deletingLinePoint < objRange.location ) {
            objRange.location -= deletingRange.length;
            obj.recorder.range = objRange;  // adjust
        }
        /**
         ---|<---ObjRange--->|--------------------------------------------
         -------------------------------|<---DeletingRange--->|-----------
         */
//        else {
        
//        }
    }];
}

- (void)_adjustOperatorsWhenRemovingAttributes:(NSRange)deletingRange {
    NSInteger deletingLinePoint = deletingRange.location + deletingRange.length;
    [self.rangeOperatorsM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        NSInteger objLinePoint = objRange.location + objRange.length;
        if ( _rangeContains(deletingRange, objRange) ) {
            [self.rangeOperatorsM removeObject:obj];
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         -------------------|<------------DeletingRange--------->|---------
         */
        else if ( objRange.location <= deletingRange.location && deletingRange.location < objLinePoint ) {
            objRange.length = deletingRange.location - objRange.location;
            obj.recorder.range = objRange;  // adjust
        }
        /**
         ----------------------|<------------ObjRange--------->|-----------
         -----------|<------------DeletingRange--------->|-----------------
         */
        else if ( deletingRange.location <= objRange.location && objRange.location < deletingLinePoint ) {
            objRange.location = deletingLinePoint;
            objRange.length = objLinePoint - deletingLinePoint;
            obj.recorder.range = objRange;  // adjust
        }
        /**
         -------------------------------|<---ObjRange--->|----------------
         ---|<---DeletingRange--->|---------------------------------------
         */
//        else if ( deleteingLinePoint < objRange.location ) {
//        }
        /**
         ---|<---ObjRange--->|--------------------------------------------
         -------------------------------|<---DeletingRange--->|-----------
         */
//        else {
//        }
    }];
}

- (void)_adjustOperatorsWhenRemovingAttribute:(NSAttributedStringKey)key deleteingRange:(NSRange)deletingRange {
    NSInteger deletingLinePoint = deletingRange.location + deletingRange.length;
    [self.rangeOperatorsM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        NSInteger objLinePoint = objRange.location + objRange.length;
        if ( _rangeContains(deletingRange, objRange) ) {
            [obj removeAttributeWithKey:key];
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         -------------------|<------------DeletingRange--------->|---------
         */
        else if ( objRange.location <= deletingRange.location && deletingRange.location < objLinePoint ) {
            obj.recorder.range = NSMakeRange(objRange.location, deletingRange.location - objRange.location);   // adjust
            NSRange range_new = NSMakeRange(deletingRange.location, objLinePoint - deletingRange.location);
            SJAttributesRangeOperator *operator_new = [self _getOperatorWithRange:range_new];
            [operator_new removeAttributeWithKey:key];
        }
        /**
         ----------------------|<------------ObjRange--------->|-----------
         -----------|<------------DeletingRange--------->|-----------------
         */
        else if ( deletingRange.location <= objRange.location && objRange.location < deletingLinePoint ) {
            obj.recorder.range = NSMakeRange(deletingLinePoint, objLinePoint - deletingLinePoint);   // adjust
            NSRange range_new = NSMakeRange(objRange.location, deletingLinePoint - objRange.location);
            SJAttributesRangeOperator *operator_new = [self _getOperatorWithRange:range_new];
            [operator_new removeAttributeWithKey:key];
        }
        /**
         -------------------------------|<---ObjRange--->|----------------
         ---|<---DeletingRange--->|---------------------------------------
         */
//        else if ( deleteingLinePoint < objRange.location ) {
//        }
        /**
         ---|<---ObjRange--->|--------------------------------------------
         -------------------------------|<---DeletingRange--->|-----------
         */
//        else {
//        }
    }];
}

- (void)_adjustOperatorsWhenInsertingText:(NSRange)insertingRange {
    NSInteger insertingLinePoint = insertingRange.location + insertingRange.length;
    [self.rangeOperatorsM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        NSInteger objLinePoint = objRange.location + objRange.length;
        /**
         -----------|<------------ObjRange--------->|----------------------
         ---------------|<---InsertingRange--->|---------------------------
         */
        if ( _rangeContains(insertingRange, objRange) ) {
            NSRange leftRange = NSMakeRange(objRange.location, insertingRange.location - objRange.location);
            NSRange rightRange = NSMakeRange(insertingLinePoint, objRange.length - leftRange.length);
            if ( leftRange.length != 0 ) [self _getOperatorWithRange:leftRange];
            if ( rightRange.length != 0 ) {
                // adjust
                SJAttributesRangeOperator *operator = [self _getOperatorWithRange:rightRange];
                SJAttributesRecorder *recorder = obj.recorder.mutableCopy;
                recorder.range = rightRange;
                [operator reset:recorder];
            }
            [self.rangeOperatorsM removeObject:obj];
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         -------------------|<------------InsertingRange--------->|--------
         */
        else if ( objRange.location <= insertingRange.location && insertingRange.location < objLinePoint ) {
            NSRange leftRange = NSMakeRange(objRange.location, insertingRange.location - objRange.location);
            NSRange rightRange = NSMakeRange(insertingLinePoint, objRange.length - leftRange.length);
            if ( leftRange.length != 0 ) [self _getOperatorWithRange:leftRange];
            if ( rightRange.length != 0 ) {
                // adjust
                SJAttributesRangeOperator *operator = [self _getOperatorWithRange:rightRange];
                SJAttributesRecorder *recorder = obj.recorder.mutableCopy;
                recorder.range = rightRange;
                [operator reset:recorder];
            }
            [self.rangeOperatorsM removeObject:obj];
        }
        /**
         ----------------------|<------------ObjRange--------->|-----------
         -----------|<------------InsertingRange--------->|----------------
         */
        else if ( insertingRange.location <= objRange.location && objRange.location < insertingLinePoint ) {
            NSRange range_new = NSMakeRange(insertingLinePoint, objRange.length);
            obj.recorder.range = range_new;
        }
        /**
         -------------------------------|<---ObjRange--->|----------------
         ---|<---InsertingRange--->|--------------------------------------
         */
        else if ( insertingLinePoint < objRange.location ) {
            NSRange range_new = NSMakeRange(objRange.location + insertingRange.length, objRange.length);
            obj.recorder.range = range_new;
        }
        /**
         ---|<---ObjRange--->|--------------------------------------------
         -------------------------------|<---InsertingRange--->|----------
         */
//        else {
//        }
    }];
}

- (void)_adjustOperatorsWhenReplaceCharactersInRange:(NSRange)range_old textLength:(NSInteger)textLength {
    NSRange range_new = NSMakeRange(range_old.location, textLength);
    if ( NSEqualRanges(range_old, range_new) ) return;
    NSInteger range_old_linePoint = range_old.length + range_old.location;
    NSInteger sub = (NSInteger)range_old.length - (NSInteger)range_new.length;

    NSInteger range_new_linePoint = range_new.length + range_new.location;
    
    [self.rangeOperatorsM enumerateObjectsUsingBlock:^(SJAttributesRangeOperator * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange objRange = obj.recorder.range;
        NSInteger objLinePoint = objRange.location + objRange.length;

       /**
         -----------|<------------ObjRange--------->|----------------------
         -----------------|<----Range_old---->|----------------------------
         -----------------|<--Range_new-->|--------------------------------
         */
        if ( _rangeContains(objRange, range_old) ) {
            objRange.length -= sub;
            obj.recorder.range = objRange;
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         -----------------|<------------Range_old------------>|------------
         -----------------|<--Range_new-->|--------------------------------
         */
        else if ( objRange.location <= range_old.location && range_old_linePoint > objLinePoint ) {
            // 只保留未替换部分
            obj.recorder.range = NSMakeRange(objRange.location, range_old.location - objRange.location);
        }
        /**
         -----------|<------------ObjRange--------->|----------------------
         ------|<-------Range_old------>|----------------------------------
         ------|<--Range_new-->|-------------------------------------------
         */
        else if ( range_old.location <= objRange.location && objRange.location < range_old_linePoint ) {
            obj.recorder.range = NSMakeRange(range_new_linePoint, objLinePoint - range_old_linePoint);
        }
        /**
         -----------------------------------|<---ObjRange--->|-------------
         ------|<-------Range_old------>|----------------------------------
         ------|<--Range_new-->|-------------------------------------------
         */
        else if ( range_old_linePoint <= objRange.location ) {
            obj.recorder.range = NSMakeRange(objRange.location - sub, objRange.length);
        }
    }];
}

@end

#pragma mark - regular
@implementation SJAttributeWorker(Regexp)

- (void)setRegexpOptions:(NSRegularExpressionOptions)regexpOptions {
    objc_setAssociatedObject(self, @selector(regexpOptions), @(regexpOptions), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSRegularExpressionOptions)regexpOptions {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

/// 正则匹配
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))regexp {
    return ^ SJAttributeWorker *(NSString *regStr, void(^task)(SJAttributesRangeOperator *matched)) {
        return self.regexp_r(regStr, ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
            [matchedRanges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange matchedRange = [obj rangeValue];
                self.rangeEdit(matchedRange, task);
            }];
        }, YES);
    };
}
/// 正则匹配. [NSRange]
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, void (^ _Nonnull)(NSArray<NSValue *> * _Nonnull), BOOL reverse))regexp_r {
    return ^ SJAttributeWorker *(NSString *regStr, void(^task)(NSArray<NSValue *> *ranges), BOOL reverse) {
        NSMutableArray<NSValue *> *rangesM = [NSMutableArray array];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr options:self.regexpOptions error:nil];
        [regex enumerateMatchesInString:self->_attrStr.string options:NSMatchingWithoutAnchoringBounds range:self.range usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if ( result ) { [rangesM addObject:[NSValue valueWithRange:result.range]];}
        }];
        if ( reverse ) {
            NSMutableArray<NSValue *> *reverseM = [NSMutableArray array];
            [rangesM enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { [reverseM addObject:obj];}];
            rangesM = reverseM;
        }
        task(rangesM);
        return self;
    };
}

- (void (^)(NSString * _Nonnull, id _Nonnull, ...))regexp_replace {
    return ^ (NSString *regexp, id replaceByStrOrAttrStrOrImg, ...) {
        CGPoint origin = CGPointZero;
        CGSize size = CGSizeZero;
        va_list args;
        va_start(args, replaceByStrOrAttrStrOrImg);
        if ( [replaceByStrOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            origin = va_arg(args, CGPoint);
            size = va_arg(args, CGSize);
        }
        self.regexp_r(regexp, ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
            [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if      ( [replaceByStrOrAttrStrOrImg isKindOfClass:[NSString class]] ||
                          [replaceByStrOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
                    self.replace([obj rangeValue], replaceByStrOrAttrStrOrImg);
                }
                else if ( [replaceByStrOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
                    self.replace([obj rangeValue], replaceByStrOrAttrStrOrImg, origin, size);
                }
                else {
                    _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self->_attrStr.string);
                }
            }];
        }, YES);
        va_end(args);
    };
}

- (void (^)(NSString * _Nonnull, SJAttributeRegexpInsertPosition, id _Nonnull, ...))regexp_insert {
    return ^ (NSString *regexp, SJAttributeRegexpInsertPosition position, id insertingStrOrAttrStrOrImg, ...) {
        va_list args;
        va_start(args, insertingStrOrAttrStrOrImg);
        CGPoint origin = CGPointZero;
        CGSize size = CGSizeZero;
        if ( [insertingStrOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            origin = va_arg(args, CGPoint);
            size = va_arg(args, CGSize);
        }
        self.regexp_r(regexp, ^(NSArray<NSValue *> * _Nonnull matchedRanges) {
            [matchedRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange objRange = [obj rangeValue];
                NSInteger index = -1;
                switch ( position ) {
                    case SJAttributeRegexpInsertPositionLeft: {
                        index = objRange.location;
                    }
                        break;
                    case SJAttributeRegexpInsertPositionRight: {
                        index = objRange.location + objRange.length;
                    }
                        break;
                }
                if      ( [insertingStrOrAttrStrOrImg isKindOfClass:[NSString class]] ) {
                    self.insertText(insertingStrOrAttrStrOrImg, index);
                }
                else if ( [insertingStrOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
                    self.insertAttrStr(insertingStrOrAttrStrOrImg, index);
                }
                else if ( [insertingStrOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
                    self.insertImage(insertingStrOrAttrStrOrImg, index, origin, size);
                }
                else {
                    _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self->_attrStr.string);
                }
            }];
        }, YES);
        va_end(args);
    };
}
@end


#pragma mark - size
@implementation SJAttributeWorker(Size)

- (CGSize (^)(void))size {
    return ^ CGSize() {
        return [self sizeWithAttrString:self->_attrStr width:CGFLOAT_MAX height:CGFLOAT_MAX];
    };
}

- (CGSize (^)(NSRange))sizeByRange {
    return ^ CGSize (NSRange byRange) {
        return [self sizeWithAttrString:self.subAttrStr(byRange) width:CGFLOAT_MAX height:CGFLOAT_MAX];
    };
}
- (CGSize (^)(double))sizeByHeight {
    return ^ CGSize (double height) {
        return [self sizeWithAttrString:self->_attrStr width:CGFLOAT_MAX height:height];
    };
}
- (CGSize (^)(double))sizeByWidth {
    return ^ CGSize (double width) {
        return [self sizeWithAttrString:self->_attrStr width:width height:CGFLOAT_MAX];
    };
}
- (CGSize)sizeWithAttrString:(NSAttributedString *)attrStr width:(double)width height:(double)height {
    if ( 0 == attrStr ) {
        _errorLog(@"Get `size` Failed! param 'attrStr' is empty!", nil);
        return CGSizeZero;
    }
    [self pauseTask];
    CGRect bounds = [attrStr boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    bounds.size.width = ceil(bounds.size.width);
    bounds.size.height = ceil(bounds.size.height);
    return bounds.size;
}
@end



#pragma mark - insert
@implementation SJAttributeWorker(Insert)

- (void)setLastInsertedRange:(NSRange)lastInsertedRange {
    objc_setAssociatedObject(self, @selector(lastInsertedRange), [NSValue valueWithRange:lastInsertedRange], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSRange)lastInsertedRange {
    return [objc_getAssociatedObject(self, _cmd) rangeValue];
}
- (SJAttributeWorker * _Nonnull (^)(void (^ _Nonnull)(SJAttributesRangeOperator * _Nonnull)))lastInserted {
    return ^ SJAttributeWorker *(void(^task)(SJAttributesRangeOperator *lastOperator)) {
        return self.rangeEdit(self.lastInsertedRange, task);
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSAttributedStringKey _Nonnull, id _Nonnull, NSRange))add {
    return ^ SJAttributeWorker *(NSAttributedStringKey key, id value, NSRange range) {
        if ( !key || !value ) {
            _errorLog(@"Added Attribute Failed! param `key or value` is Empty!", self->_attrStr.string);
            return self;
        }
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Add Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return self;
        }
        [self->_attrStr addAttribute:key value:value range:range];
        return self;
    };
}
- (SJAttributesRangeOperator * _Nonnull (^)(id _Nonnull, ...))append {
    return ^ SJAttributesRangeOperator *(id strOrImg, ...) {
        va_list args;
        va_start(args, strOrImg);
        if      ( [strOrImg isKindOfClass:[NSString class]] ) {
            self.insertText(strOrImg, -1);
        }
        else if ( [strOrImg isKindOfClass:[UIImage class]] ) {
            self.insertImage(strOrImg, -1, va_arg(args, CGPoint), va_arg(args, CGSize));
        }
        else {
            _errorLog(@"append `text` Failed! param `strOrImg` is Unlawfulness!", self->_attrStr.string);
        }
        va_end(args);
        return [self _getOperatorWithRange:self.lastInsertedRange];
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSString * _Nonnull, NSInteger))insertText {
    return ^ SJAttributeWorker *(NSString *text, NSInteger idx) {
        if ( 0 == text.length ) {
            _errorLog(@"inset `text` Failed! param `text` is Empty!", self->_attrStr.string);
            return self;
        }
        return self.insertAttrStr([[NSAttributedString alloc] initWithString:text], idx);
    };
}
- (SJAttributeWorker * _Nonnull (^)(UIImage * _Nonnull, NSInteger, CGPoint, CGSize))insertImage {
    return ^ SJAttributeWorker *(UIImage *image, NSInteger idx, CGPoint offset, CGSize size) {
        if ( nil == image ) {
            _errorLog(@"inset `image` Failed! param `image` is Empty!", self->_attrStr.string);
            return self;
        }
        NSTextAttachment *attachment = [NSTextAttachment new];
        attachment.image = image;
        if ( CGSizeEqualToSize(size, CGSizeZero) ) size = image.size;
        attachment.bounds = (CGRect){offset, size};
        return self.insertAttrStr([NSAttributedString attributedStringWithAttachment:attachment], idx);
    };
}
- (SJAttributeWorker * _Nonnull (^)(NSAttributedString * _Nonnull, NSInteger))insertAttrStr {
    return ^ SJAttributeWorker *(NSAttributedString *text, NSInteger idx) {
        if ( 0 == text.length ) {
            _errorLog(@"inset `text` Failed! param `text` is Empty!", self->_attrStr.string);
            return self;
        }
        if ( -1 == idx || idx > self->_attrStr.length ) {
            idx = self->_attrStr.length;
        }
        self.lastInsertedRange = NSMakeRange(idx, text.length);
        [self _adjustOperatorsWhenInsertingText:self.lastInsertedRange];
        [self->_attrStr insertAttributedString:text atIndex:idx];
        return self;
    };
}
- (SJAttributeWorker * _Nonnull (^)(id _Nonnull, NSInteger, ...))insert {
    return ^ SJAttributeWorker *(id strOrAttrStrOrImg, NSInteger idx, ...) {
        va_list args;
        va_start(args, idx);
        if      ( [strOrAttrStrOrImg isKindOfClass:[NSString class]] ) {
            self.insertText(strOrAttrStrOrImg, idx);
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
            self.insertAttrStr(strOrAttrStrOrImg, idx);
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            self.insertImage(strOrAttrStrOrImg, idx, va_arg(args, CGPoint), va_arg(args, CGSize));
        }
        else {
            _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self->_attrStr.string);
        }
        va_end(args);
        return self;
    };
}
@end




#pragma mark - replace
@implementation SJAttributeWorker(Replace)
- (void (^)(NSRange, id _Nonnull, ...))replace {
    return ^ void (NSRange range, id strOrAttrStrOrImg, ...) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Replace Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return;
        }

        NSAttributedString *text = nil;
        if      ( [strOrAttrStrOrImg isKindOfClass:[NSString class]] ) {
            text = [[NSAttributedString alloc] initWithString:strOrAttrStrOrImg];
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[NSAttributedString class]] ) {
            text = strOrAttrStrOrImg;
        }
        else if ( [strOrAttrStrOrImg isKindOfClass:[UIImage class]] ) {
            va_list args;
            va_start(args, strOrAttrStrOrImg);
            NSTextAttachment *attachment = [NSTextAttachment new];
            attachment.image = strOrAttrStrOrImg;
            CGPoint origin = va_arg(args, CGPoint);
            CGSize size = va_arg(args, CGSize); if ( CGSizeEqualToSize(size, CGSizeZero) ) size = attachment.image.size;
            attachment.bounds = (CGRect){origin, size};
            text = [NSAttributedString attributedStringWithAttachment:attachment];
            va_end(args);
        }
        else {
            _errorLog(@"inset `text` Failed! param `strOrAttrStrOrImg` is Unlawfulness!", self->_attrStr.string);
        }
        
        if ( !text ) return;

        [self->_attrStr replaceCharactersInRange:range withAttributedString:text];
        [self _adjustOperatorsWhenReplaceCharactersInRange:range textLength:[text length]];
    };
}
@end


#pragma mark - delete
@implementation SJAttributeWorker(Delete)

- (void (^)(NSRange))removeText {
    return ^ (NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return ;
        }
        [self _adjustOperatorsWhenRemovingText:range];
        [self->_attrStr deleteCharactersInRange:range];
    };
}
- (void (^)(NSAttributedStringKey _Nonnull, NSRange))removeAttribute {
    return ^ (NSAttributedStringKey key, NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return ;
        }
        [self _adjustOperatorsWhenRemovingAttribute:key deleteingRange:range];
        [self->_attrStr removeAttribute:key range:range];
    };
}
- (void (^)(NSRange))removeAttributes {
    return ^ (NSRange range) {
        if ( !_rangeContains(self.range, range) ) {
            _errorLog(@"Remove Failed! param 'range' is unlawfulness!", self->_attrStr.string);
            return ;
        }
        [self _adjustOperatorsWhenRemovingAttributes:range];
        NSString *subAttrStr = self.subAttrStr(range).string;
        self.replace(range, subAttrStr);
    };
}
@end


#pragma mark - property
@implementation SJAttributesRangeOperator(Property)
/// 字体
- (SJAttributesRangeOperator * _Nonnull (^)(UIFont * _Nonnull))font {
    return ^ SJAttributesRangeOperator *(UIFont *font) {
        self.recorder.font = font;
        return self;
    };
}
/// 文本颜色
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull))textColor {
    return ^ SJAttributesRangeOperator *(UIColor *textColor) {
        self.recorder.textColor = textColor;
        return self;
    };
}
/// 放大, 扩大
- (SJAttributesRangeOperator * _Nonnull (^)(double))expansion {
    return ^ SJAttributesRangeOperator *(double expansion) {
        self.recorder.expansion = expansion;
        return self;
    };
}
/// 阴影
- (SJAttributesRangeOperator * _Nonnull (^)(CGSize, CGFloat, UIColor * _Nonnull))shadow {
    return ^ SJAttributesRangeOperator *(CGSize shadowOffset, CGFloat shadowBlurRadius, UIColor *shadowColor) {
        if ( nil != self.recorder.backgroundColor ) {
            _errorLog(@"`shadow`会与`backgroundColor`冲突, 设置了`backgroundColor`后, `shadow`将不会显示.", [NSValue valueWithRange:self.recorder.range]);
        }
        NSShadow *shadow = [NSShadow new];
        shadow.shadowOffset = shadowOffset;
        shadow.shadowBlurRadius = shadowBlurRadius;
        shadow.shadowColor = shadowColor;
        self.recorder.shadow = shadow;
        return self;
    };
}
/// 背景颜色
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull))backgroundColor {
    return ^ SJAttributesRangeOperator *(UIColor *color) {
        if ( nil != self.recorder.shadow ) {
            _errorLog(@"`shadow`会与`backgroundColor`冲突, 设置了`backgroundColor`后, `shadow`将不会显示.", [NSValue valueWithRange:self.recorder.range]);
        }
        self.recorder.backgroundColor = color;
        return self;
    };
}
/// 下划线
- (SJAttributesRangeOperator * _Nonnull (^)(NSUnderlineStyle, UIColor * _Nonnull))underLine {
    return ^ SJAttributesRangeOperator *(NSUnderlineStyle style, UIColor *color) {
        self.recorder.underLine = [SJUnderlineAttribute underLineWithStyle:style color:color];
        return self;
    };
}
/// 删除线
- (SJAttributesRangeOperator * _Nonnull (^)(NSUnderlineStyle, UIColor * _Nonnull))strikethrough {
    return ^ SJAttributesRangeOperator *(NSUnderlineStyle style, UIColor *color) {
        self.recorder.strikethrough = [SJUnderlineAttribute underLineWithStyle:style color:color];
        return self;
    };
}
/// 边界`border`
- (SJAttributesRangeOperator * _Nonnull (^)(UIColor * _Nonnull, double))stroke {
    return ^ SJAttributesRangeOperator *(UIColor * color, double stroke) {
        self.recorder.stroke = [SJStrokeAttribute strokeWithValue:stroke color:color];
        return self;
    };
}
/// 倾斜(-1 ... 1)
- (SJAttributesRangeOperator * _Nonnull (^)(double))obliqueness {
    return ^ SJAttributesRangeOperator *(double obliqueness) {
        self.recorder.obliqueness = obliqueness;
        return self;
    };
}
/// 字间隔
- (SJAttributesRangeOperator * _Nonnull (^)(double))letterSpacing {
    return ^ SJAttributesRangeOperator *(double letterSpacing) {
        self.recorder.letterSpacing = letterSpacing;
        return self;
    };
}
/// 上下偏移
- (SJAttributesRangeOperator * _Nonnull (^)(double))offset {
    return ^ SJAttributesRangeOperator *(double offset) {
        self.recorder.offset = offset;
        return self;
    };
}
/// 链接
- (SJAttributesRangeOperator * _Nonnull (^)(void))isLink {
    return ^ SJAttributesRangeOperator *() {
        self.recorder.link = YES;
        return self;
    };
}
/// 段落 style
- (SJAttributesRangeOperator * _Nonnull (^)(NSParagraphStyle * _Nonnull))paragraphStyle {
    return ^ SJAttributesRangeOperator *(NSParagraphStyle *style) {
        self.recorder.paragraphStyleM = style.mutableCopy;
        return self;
    };
}
/// 行间隔
- (SJAttributesRangeOperator * _Nonnull (^)(double))lineSpacing {
    return ^ SJAttributesRangeOperator *(double lineSpacing) {
        self.recorder.lineSpacing = lineSpacing;
        return self;
    };
}
/// 段后间隔(\n)
- (SJAttributesRangeOperator * _Nonnull (^)(double))paragraphSpacing {
    return ^ SJAttributesRangeOperator *(double paragraphSpacing) {
        self.recorder.paragraphSpacing = paragraphSpacing;
        return self;
    };
}
/// 段前间隔(\n)
- (SJAttributesRangeOperator * _Nonnull (^)(double))paragraphSpacingBefore {
    return ^ SJAttributesRangeOperator *(double paragraphSpacingBefore) {
        self.recorder.paragraphSpacingBefore = paragraphSpacingBefore;
        return self;
    };
}
/// 首行头缩进
- (SJAttributesRangeOperator * _Nonnull (^)(double))firstLineHeadIndent {
    return ^ SJAttributesRangeOperator *(double firstLineHeadIndent) {
        self.recorder.firstLineHeadIndent = firstLineHeadIndent;
        return self;
    };
}
/// 左缩进
- (SJAttributesRangeOperator * _Nonnull (^)(double))headIndent {
    return ^ SJAttributesRangeOperator *(double headIndent) {
        self.recorder.headIndent = headIndent;
        return self;
    };
}
/// 右缩进(正值从左算起, 负值从右算起)
- (SJAttributesRangeOperator * _Nonnull (^)(double))tailIndent {
    return ^ SJAttributesRangeOperator *(double tailIndent) {
        self.recorder.tailIndent = tailIndent;
        return self;
    };
}
/// 对齐方式
- (SJAttributesRangeOperator * _Nonnull (^)(NSTextAlignment))alignment {
    return ^ SJAttributesRangeOperator *(NSTextAlignment alignment) {
        self.recorder.alignment = @(alignment);
        return self;
    };
}
/// 截断模式
- (SJAttributesRangeOperator * _Nonnull (^)(NSLineBreakMode))lineBreakMode {
    return ^ SJAttributesRangeOperator *(NSLineBreakMode lineBreakMode) {
        self.recorder.lineBreakMode = lineBreakMode;
        return self;
    };
}
@end
NS_ASSUME_NONNULL_END
