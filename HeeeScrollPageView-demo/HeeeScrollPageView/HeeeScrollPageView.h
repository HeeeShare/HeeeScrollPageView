//
//  HeeeScrollPageView.h
//  HeeeScrollPageView-demo
//
//  Created by hgy on 2018/10/28.
//  Copyright © 2018 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeeeScrollPageView : UIView
/**
 实例方法
 
 @param frame 实例的frame
 @param childVCArr 需要显示的子控制器
 @param indicatorHeight 标题栏的高度
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame childVC:(NSArray <UIViewController *>*)childVCArr andIndicatorHeight:(CGFloat)indicatorHeight;

/**
 动态添加子控制器
 
 @param childVC 需要添加的子控制器
 @param index 添加到哪个的位置
 */
- (void)addChildVC:(UIViewController *)childVC toIndex:(NSUInteger)index;

/**
 动态移除子控制器
 
 @param index 需要移除子控制器的位置
 */
- (void)removeChildVC:(NSUInteger)index;

@property (nonatomic,strong) UIColor *highlightColor;//标题高亮颜色
@property (nonatomic,strong) UIColor *normalColor;//标题正常颜色
@property (nonatomic,assign) CGFloat titleGap;//标题间距
@property (nonatomic,strong) UIFont *titleFont;//标题字体大小
@property (nonatomic,assign) CGFloat lineHeight;//标题下面细线的高度
@property (nonatomic,assign) CGFloat lineGap;//标题与细线的间距
@property (nonatomic,assign) UIColor *indicatorBGColor;//标题栏的背景色

/**
 默认标题和细线加上lineGap，会居中显示在标题栏上。
 设置下面两个参数会在居中的情况下再单独偏移标题或者细线，正数向下偏移，负数向上偏移。
 */
@property (nonatomic,assign) CGFloat titleOffsetY;
@property (nonatomic,assign) CGFloat lineOffsetY;

/**
 点击标题切换页面动画开关，默认NO，没有动画。
 开启动画，可能会将动画经过且没有加载过的controller加载。
 如果之间的controller较多，且页面操作复杂，会引起卡顿。
 如果controller已经加载，则没有影响。
 */
@property (nonatomic,assign) BOOL clickTitleAnimate;

@end
