//
//  GKVideoScrollView.m
//  GKVideoScrollView
//
//  Created by QuintGao on 2023/2/21.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKVideoScrollView.h"

#define kScreenW UIScreen.mainScreen.bounds.size.height
#define kScreenH UIScreen.mainScreen.bounds.size.height

@interface GKVideoScrollView()<UIScrollViewDelegate>

@property (nonatomic, weak) id<GKVideoScrollViewDelegate> userDelegate;

// 创建三个控制视图，用于滑动切换
@property (nonatomic, strong) UIView *topCell; // 顶部视图
@property (nonatomic, strong) UIView *ctrCell; // 中间视图
@property (nonatomic, strong) UIView *btmCell; // 底部视图

// 控制播放的索引，不完全等于当前播放内容的索引
@property (nonatomic, assign) NSInteger index;

// 当前索引
@property (nonatomic, assign) NSInteger currentIndex;

// 当前显示的view
@property (nonatomic, weak) UIView *currentCell;

// 将要改变的索引
@property (nonatomic, assign) NSInteger changeIndex;

// 内容总数
@property (nonatomic, assign) NSInteger totalCount;

// 处理上拉加载回弹问题
@property (nonatomic, assign) NSInteger lastCount;
@property (nonatomic, assign) BOOL isDelay;

// 当前正在更新的view
@property (nonatomic, weak) UIView *updateCell;

// 处理view即将显示
@property (nonatomic, assign) CGFloat lastOffsetY;
@property (nonatomic, weak) UIView *lastWillDisplayCell;

// 记录是否在切换页面
@property (nonatomic, assign) BOOL isChanging;

// 存放cell标识和对应的类
@property (nonatomic, strong) NSMutableDictionary<NSString *, Class> *cellClasses;

// 存放cell标识和对应的可重用view列表
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *reusableCells;

@end

@implementation GKVideoScrollView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = UIColor.clearColor;
    self.pagingEnabled = YES;
    self.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.cellClasses = [NSMutableDictionary dictionary];
    self.reusableCells = [NSMutableDictionary dictionary];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat controlW = CGRectGetWidth(self.frame);
    CGFloat controlH = CGRectGetHeight(self.frame);
    
    self.topCell.frame = CGRectMake(0, 0, controlW, controlH);
    self.ctrCell.frame = CGRectMake(0, controlH, controlW, controlH);
    self.btmCell.frame = CGRectMake(0, controlH * 2, controlW, controlH);
}

- (void)setDelegate:(id<GKVideoScrollViewDelegate>)delegate {
    if (delegate) {
        [super setDelegate:self];
        self.userDelegate = delegate;
    }else {
        [super setDelegate:nil];
        self.userDelegate = nil;
    }
}

#pragma mark - Public Methods
- (NSArray<__kindof UIView *> *)visibleCells {
    return @[self.currentCell];
}

- (NSInteger)numberOfRows {
    return self.totalCount;
}

- (NSIndexPath *)indexPathForCell:(UIView *)cell {
    NSInteger index = -1;
    if (cell == self.topCell) {
        if (self.currentCell == self.topCell) {
            index = self.currentIndex;
        }else if (self.currentCell == self.ctrCell) {
            index = self.currentIndex - 1;
        }else if (self.currentCell == self.btmCell) {
            index = self.currentIndex - 2;
        }
    }else if (cell == self.ctrCell) {
        if (self.currentCell == self.topCell) {
            index = self.currentIndex + 1;
        }else if (self.currentCell == self.ctrCell) {
            index = self.currentIndex;
        }else if (self.currentCell == self.btmCell) {
            index = self.currentIndex - 1;
        }
    }else if (cell == self.btmCell) {
        if (self.currentCell == self.topCell) {
            index = self.currentIndex + 2;
        }else if (self.currentCell == self.ctrCell) {
            index = self.currentIndex + 1;
        }else if (self.currentCell == self.btmCell) {
            index = self.currentIndex;
        }
    }
    
    if (index >= 0) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (__kindof UIView *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    UIView *cell = nil;
    if (self.totalCount == 1) {
        if (index == 0) {
            cell = self.topCell;
        }
    }else if (self.totalCount == 2) {
        if (index == 0) {
            cell = self.topCell;
        }else {
            cell = self.ctrCell;
        }
    }else if (self.totalCount >= 3) {
        NSInteger diff = self.currentIndex - index;
        if (self.currentIndex == 0) {
            if (diff == 0) {
                cell = self.topCell;
            }else if (diff == -1) {
                cell = self.ctrCell;
            }else if (diff == -2) {
                cell = self.btmCell;
            }
        }else if (self.currentIndex == self.totalCount - 1) {
            if (diff == 0) {
                cell = self.btmCell;
            }else if (diff == 1) {
                cell = self.ctrCell;
            }else if (diff == 2) {
                cell = self.topCell;
            }
        }else {
            if (diff == -1) {
                cell = self.btmCell;
            }else if (diff == 0) {
                cell = self.ctrCell;
            }else if (diff == 1) {
                cell = self.topCell;
            }
        }
    }
    return cell;
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    NSAssert(cellClass, @"cellClass不能为nil");
    NSAssert(identifier.length > 0, @"标识不能为nil或空字符串");
    [self.cellClasses setValue:cellClass forKey:identifier];
    [self.reusableCells setValue:[NSMutableSet set] forKey:identifier];
}

- (__kindof UIView *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    NSAssert(identifier.length > 0, @"标识不能为nil或空字符串");
    NSAssert([self.cellClasses.allKeys containsObject:identifier], @"请先注册cell");
    Class cellClass = self.cellClasses[identifier];
    UIView *cell = nil;
    if (!self.updateCell || self.updateCell.class != cellClass) {
        cell = [self dequeueReusableCellWithIdentifier:identifier];
        if (self.updateCell) {
            [self saveReusableCell:self.updateCell];
            self.updateCell = nil;
        }
        [self addSubview:cell];
    }else {
        cell = self.updateCell;
        self.updateCell = nil;
    }
    return cell;
}

- (void)reloadData {
    // 获取默认索引
    NSInteger index = self.defaultIndex;
    self.defaultIndex = -1;
    // 获取总数
    self.totalCount = [self.dataSource numberOfRowsInScrollView:self];
    
    // 容错处理
    if (self.totalCount <= 0) return;
    if (index > self.totalCount - 1) return;
    
    if (index == -1) {
        [self createCellsIfNeeded];
        [self updateContentSize];
        [self updateDisplayCell];
    }else {
        self.index = index;
        self.currentIndex = index;
        self.changeIndex = index;
        [self createCellsIfNeeded];
        [self updateContentSize];
        [self updateContentOffset];
        [self updateDisplayCell];
    }
}

- (void)scrollToPageWithIndex:(NSInteger)index {
    if (self.currentIndex == index) return;
    if (index < 0 || index > self.totalCount - 1) return;
    self.isChanging = YES;
    self.index = index;
    self.changeIndex = index;
    
    // 更新cell
    NSInteger updateIndex = 0;
    if (index == 0) {
        updateIndex = index + 1;
    }else if (index == self.totalCount - 1) {
        updateIndex = index - 1;
        self.index = index - 1; // 特殊处理
    }else {
        updateIndex = index;
    }
    [self updateCellWithIndex:updateIndex];
    
    // 显示cell
    [self updateDisplayCellWithIndex:index];
    
    self.isChanging = NO;
}

- (void)scrollToNextPage {
    // 当前是最后一个，不做处理
    if (self.currentIndex == self.totalCount - 1) return;
    
    self.changeIndex = self.currentIndex + 1;
    // 即将显示
    UIView *cell = nil;
    if (self.currentCell == self.topCell) {
        cell = self.ctrCell;
    }else if (self.currentCell == self.ctrCell) {
        cell = self.btmCell;
    }
    if (cell) {
        [self willDisplayCell:cell forIndex:self.changeIndex];
        self.lastWillDisplayCell = nil;
    }
    
    // 切换
    CGFloat offsetY = self.contentOffset.y;
    offsetY += self.viewHeight;
    [self setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

#pragma mark - Private Methods
#pragma mark - dequeue reusable cell
- (UIView *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    NSMutableSet *cells = self.reusableCells[identifier];
    
    UIView *cell = cells.anyObject;
    if (cell) {
        [cells removeObject:cell];
    }else {
        Class cellClass = self.cellClasses[identifier];
        cell = [[cellClass alloc] initWithFrame:self.bounds];
    }
    return cell;
}

- (void)saveReusableCell:(UIView *)cell {
    NSString *identifier = [self identifierWithClass:cell.class];
    NSMutableSet *cells = self.reusableCells[identifier];
    [cells addObject:cell];
    [cell removeFromSuperview];
    [self.reusableCells setValue:cells forKey:identifier];
}

- (NSString *)identifierWithClass:(Class)class {
    __block NSString *identifier = nil;
    [self.cellClasses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == class) {
            identifier = key;
            *stop = YES;
        }
    }];
    return identifier;
}

#pragma mark - create and update cell
- (void)createCellsIfNeeded {
    NSInteger index = 0;
    if (self.totalCount == 1) {
        index = 0;
    }else if (self.totalCount == 2) {
        index = 1;
    }else {
        if (self.defaultIndex == -1 && self.topCell && self.ctrCell && self.btmCell) {
            if (self.currentIndex == 0) {
                index = self.currentIndex + 1;
            }else {
                if (self.currentCell == self.btmCell) {
                    index = self.currentIndex - 1;
                }else {
                    index = self.currentIndex;
                }
            }
        }else {
            if (self.currentIndex == 0) {
                index = self.currentIndex + 1;
            }else if (self.currentIndex == self.totalCount - 1) {
                index = self.currentIndex - 1;
            }else {
                index = self.currentIndex;
            }
        }
    }
    [self createCellWithIndex:index];
}

- (void)updateDisplayCell {
    UIView *cell = nil;
    if (self.totalCount == 1) {
        cell = self.topCell;
    }else if (self.totalCount == 2) {
        cell = self.currentIndex == 0 ? self.topCell : self.ctrCell;
    }else {
        if (self.currentIndex == 0) {
            cell = self.topCell;
        }else if (self.currentIndex == self.totalCount - 1) {
            cell = self.btmCell;
        }else {
            cell = self.ctrCell;
        }
    }
    [self willDisplayCell:cell forIndex:self.currentIndex];
    self.lastWillDisplayCell = nil;
    if (self.isDecelerating) return;
    if (self.contentOffset.y > 0 && self.contentOffset.y != self.viewHeight * 2) return;
    [self didEndScrollingCell:cell];
}

- (void)updateDisplayCellWithIndex:(NSInteger)index {
    CGFloat viewH = self.viewHeight;
    
    UIView *cell = nil;
    CGFloat offsetY = 0;
    if (self.totalCount == 1) {
        cell = self.topCell;
        offsetY = 0;
    }else if (self.totalCount == 2) {
        cell = index == 0 ? self.topCell : self.ctrCell;
        offsetY = index == 0 ? 0 : viewH;
    }else {
        if (index == 0) {
            cell = self.topCell;
            offsetY = 0;
        }else if (index == self.totalCount - 1) {
            cell = self.btmCell;
            offsetY = viewH * 2;
        }else {
            cell = self.ctrCell;
            offsetY = viewH;
        }
    }
    //即将显示cell
    [self willDisplayCell:cell forIndex:index];
    self.lastWillDisplayCell = nil;
    
    // 切换位置
    [self updateContentOffset:CGPointMake(0, offsetY)];
    
    // 滑动结束显示
    [self didEndScrollingCell:cell];
}

- (void)updateContentSize {
    CGFloat height = self.viewHeight * (self.totalCount >= 3 ? 3 : self.totalCount);
    [self updateContentSize:CGSizeMake(self.viewWidth, height)];
}

- (void)updateContentOffset {
    CGFloat viewH = self.viewHeight;
    CGFloat offsetY = 0;
    if (self.totalCount == 0) {
        offsetY = 0;
    }else if (self.totalCount == 1) {
        offsetY = self.currentIndex == 0 ? 0 : viewH;
    }else {
        if (self.currentIndex == 0) {
            offsetY = 0;
        }else if (self.currentIndex == self.totalCount - 1) {
            offsetY = viewH * 2;
        }else {
            offsetY = viewH;
        }
    }
    [self updateContentOffset:CGPointMake(0, offsetY)];
}

- (void)createCellWithIndex:(NSInteger)index {
    if (self.totalCount == 1) {
        self.updateCell = self.topCell;
        self.topCell = [self cellForIndex:0];
        [self layoutSubviews];
    }else if (self.totalCount == 2) {
        self.updateCell = self.topCell;
        self.topCell = [self cellForIndex:0];
        self.updateCell = self.ctrCell;
        self.ctrCell = [self cellForIndex:1];
        [self layoutSubviews];
    }else {
        [self updateCellWithIndex:index];
    }
}

- (void)updateCellWithIndex:(NSInteger)index {
    if (index < 1 || index > self.totalCount - 2) return;
    self.updateCell = self.topCell;
    self.topCell = [self cellForIndex:index - 1];
    self.updateCell = self.ctrCell;
    self.ctrCell = [self cellForIndex:index];
    self.updateCell = self.btmCell;
    self.btmCell = [self cellForIndex:index + 1];
    [self layoutSubviews];
}

- (UIView *)cellForIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [self.dataSource scrollView:self cellForRowAtIndexPath:indexPath];
}

#pragma mark - DisplayCell
- (void)delayUpdateCellWithIndex:(NSInteger)index {
    if (self.isDelay) return;
    self.isDelay = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isDelay = NO;
        self.index = index;
        self.lastCount = 0;
        [self updateContentOffset:CGPointMake(0, self.viewHeight)];
        
        // 瞬移大法
        UIView *tempCell = self.btmCell;
        self.btmCell = self.ctrCell;
        self.ctrCell = tempCell;
        
        [self updateCellWithIndex:self.index];
        [self didEndScrollingCell:self.ctrCell];
    });
}

- (void)handleWillDisplayCell {
    if (!self.isDragging) return;
    CGFloat offsetY = self.contentOffset.y;
    if (offsetY < self.lastOffsetY) { // 下拉
        if (offsetY < 0) return; // 第一个cell下拉
        if (offsetY > self.viewHeight * 2) return; // 显示footer时下拉
        NSInteger index = self.currentIndex - 1;
        if (self.currentCell == self.ctrCell) {
            [self willDisplayCell:self.topCell forIndex:index];
        }else if (self.currentCell == self.btmCell) {
            [self willDisplayCell:self.ctrCell forIndex:index];
        }
    }else if (offsetY > self.lastOffsetY) { // 上拉
        if (offsetY > self.viewHeight * 3) return; // 最后一个cell上拉
        NSInteger index = self.currentIndex + 1;
        if (self.currentCell == self.topCell) {
            [self willDisplayCell:self.ctrCell forIndex:index];
        }else if (self.currentCell == self.ctrCell) {
            [self willDisplayCell:self.btmCell forIndex:index];
        }
    }
}

- (void)willDisplayCell:(UIView *)cell forIndex:(NSInteger)index {
    if (!cell) return;
    if (self.lastWillDisplayCell == cell) return;
    self.lastWillDisplayCell = cell;
    if ([self.userDelegate respondsToSelector:@selector(scrollView:willDisplayCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.userDelegate scrollView:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)didEndDisplayingCell:(UIView *)cell forIndex:(NSInteger)index {
    if ([self.userDelegate respondsToSelector:@selector(scrollView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.userDelegate scrollView:self didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)didEndScrollingCell:(UIView *)cell {
    // 隐藏cell
    if (self.currentIndex != self.changeIndex) {
        if (self.currentCell == self.topCell || self.totalCount <= 3) {
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        }
    }
    
    // 显示新的cell
    self.currentCell = cell;
    self.currentIndex = self.changeIndex;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.userDelegate respondsToSelector:@selector(scrollView:didEndScrollingCell:forRowAtIndexPath:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            [self.userDelegate scrollView:self didEndScrollingCell:cell forRowAtIndexPath:indexPath];
        }
    });
}

#pragma mark - update view
- (CGFloat)viewWidth {
    CGFloat width = self.bounds.size.width;
    return width == 0 ? kScreenW : width;
}

- (CGFloat)viewHeight {
    CGFloat height = self.bounds.size.height;
    return height == 0 ? kScreenH : height;
}

- (void)updateContentSize:(CGSize)size {
    if (CGSizeEqualToSize(self.contentSize, size)) return;
    self.contentSize = size;
}

- (void)updateContentOffset:(CGPoint)offset {
    if (CGPointEqualToPoint(self.contentOffset, offset)) return;
    self.contentOffset = offset;
}

@end

@interface GKVideoScrollView (UIScrollView)

@end

@implementation GKVideoScrollView (UIScrollView)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.userDelegate scrollViewDidScroll:scrollView];
    }
    // 处理cell显示
    [self handleWillDisplayCell];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat viewH = self.viewHeight;
    
    // 小于等于3个，不用处理
    if (self.totalCount <= 3) {
        self.lastCount = self.totalCount;
        return;
    }
    
    // 下滑到第一个
    if (self.index == 0 && offsetY <= viewH) {
        return;
    }
    
    // 上滑到最后一个
    if (self.index > 0 && self.index == self.totalCount - 1 && offsetY > viewH) {
        return;
    }
    
    // 判断是从中间视图上滑还是下滑
    if (offsetY >= 2 * viewH) { // 上滑
        if (self.currentCell != self.btmCell) {
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        }
        if (self.index == 0) {
            if (self.lastCount > 0) {
                [self delayUpdateCellWithIndex:2];
            }else {
                self.index = 2;
                [self updateContentOffset:CGPointMake(0, viewH)];
                self.changeIndex = self.index;
                [self updateCellWithIndex:self.index];
            }
        }else {
            if (self.index < self.totalCount - 1) {
                self.index += 1;
                if (self.index == self.totalCount - 1) {
                    if (self.lastCount > 0 && self.lastCount < self.totalCount) {
                        [self delayUpdateCellWithIndex:self.lastCount - 1];
                    }else {
                        self.changeIndex = self.index;
                        [self updateCellWithIndex:self.index - 1];
                        self.lastCount = self.totalCount;
                    }
                }else {
                    if (self.lastCount > 0 && self.lastCount < self.totalCount) {
                        [self delayUpdateCellWithIndex:(self.index == 2 ? 2 : self.lastCount - 1)];
                    }else {
                        [self updateContentOffset:CGPointMake(0, viewH)];
                        self.changeIndex = self.index;
                        [self updateCellWithIndex:self.index];
                    }
                }
            }
        }
    }else if (offsetY <= 0) { // 下滑
        if (self.currentCell != self.topCell) {
            [self didEndDisplayingCell:self.currentCell forIndex:self.currentIndex];
        }
        self.lastCount = 0;
        if (self.index == 1) {
            self.index -= 1;
            self.changeIndex = self.index;
            [self updateCellWithIndex:self.index + 1];
        }else {
            if (self.index == self.totalCount - 1) {
                self.index -= 2;
            }else {
                self.index -= 1;
            }
            [self updateContentOffset:CGPointMake(0, viewH)];
            self.changeIndex = self.index;
            [self updateCellWithIndex:self.index];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.userDelegate scrollViewWillBeginDragging:scrollView];
    }
    self.lastOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.userDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.userDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.userDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.userDelegate scrollViewDidEndDecelerating:scrollView];
    }
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.userDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.userDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
    // 清空上一次将要显示的cell，保证下一次正常显示
    self.lastWillDisplayCell = nil;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat viewH = self.viewHeight;
    
    if (self.totalCount <= 3) {
        self.changeIndex = offsetY / viewH + 0.5;
    }
    
    UIView *cell = nil;
    if (offsetY == 0) {
        cell = self.topCell;
    }else if (offsetY == viewH) {
        if (self.index == 0) {
            self.index += 1;
            self.changeIndex = self.index;
        }else if (self.index == self.totalCount - 1) {
            self.index -= 1;
            self.changeIndex = self.index;
        }
        cell = self.ctrCell;
    }else {
        if (!self.isDelay) {
            cell = self.btmCell;
        }
    }
    if (!cell) return;
    [self didEndScrollingCell:cell];
}

@end
