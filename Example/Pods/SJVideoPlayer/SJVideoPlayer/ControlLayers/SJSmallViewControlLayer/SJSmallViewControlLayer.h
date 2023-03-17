//
//  SJSmallViewControlLayer.h
//  Pods
//
//  Created by 畅三江 on 2019/6/6.
//
//  浮窗小视图的控制层
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"

#pragma mark - 小浮窗模式下的控制层


NS_ASSUME_NONNULL_BEGIN
extern SJEdgeControlButtonItemTag const SJSmallViewControlLayerTopItem_Close;

@interface SJSmallViewControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>

@end
NS_ASSUME_NONNULL_END
