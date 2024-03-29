//
//  HeeeScrollPageView.h
//  ceshi010
//
//  Created by Heee on 2019/7/5.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeeeScrollPageTitleView.h"
@class HeeeScrollPageView;

@protocol HeeeScrollPageViewDelegate <NSObject>
@optional
- (void)scrollPageView:(HeeeScrollPageView *)scrollPageView titleViewDidChangeHeight:(CGFloat)titleViewHeight;
- (void)scrollPageView:(HeeeScrollPageView *)scrollPageView willScrollToIndex:(NSInteger)pageIndex;
- (void)scrollPageView:(HeeeScrollPageView *)scrollPageView didScrollToIndex:(NSInteger)pageIndex isTop:(BOOL)isTop;

@end

@interface HeeeScrollPageView : UIView
@property (nonatomic,strong,readonly) UIScrollView *scrollView;
@property (nonatomic,assign,readonly) NSUInteger currentPage;
@property (nonatomic,assign) NSUInteger defaultPage;//默认选中的page
@property (nonatomic,strong) NSArray <UIViewController *>*VCArray;
@property (nonatomic,assign) HeeeTitleArrangement titleArrangement;
@property (nonatomic,strong) UIColor *titleViewBackgroundColor;
@property (nonatomic,strong) UIColor *titleNormalColor;
@property (nonatomic,strong) UIColor *titleSelectedColor;
@property (nonatomic,assign) CGFloat titleFontSize;
@property (nonatomic,assign) CGFloat titleZoomScale;

//如果标题栏竖直方向高度不可变，则titleMaxHeight应与titleMaxHeight的值相等，且该值就是标题栏的高度，默认36。
@property (nonatomic,assign) CGFloat titleMaxHeight;
@property (nonatomic,assign) CGFloat titleMiniHeight;

@property (nonatomic,assign) BOOL titleVerticalCenter;//标题竖直是否居中，否表示居底部，默认yes。
@property (nonatomic,assign) CGFloat titleVerticalOffset;//标题竖直方向的偏移，默认0。
@property (nonatomic,assign) CGFloat titleHorizontalGap;//标题水平方向的间距，默认20。

@property (nonatomic,strong) UIColor *indicatorColor;
@property (nonatomic,assign) CGFloat indicatorHeight;
@property (nonatomic,assign) CGFloat indicatorWidth;//指示线的宽度，默认是文字的宽度。
@property (nonatomic,assign) CGFloat indicatorCornerRadius;
@property (nonatomic,assign) CGFloat indicatorVerticalOffset;//表示指示线距离底部往上偏移了多少。

@property (nonatomic,strong) UIColor *titleBottomLineColor;
@property (nonatomic,assign) CGFloat titleBottomLineHeight;
@property (nonatomic,assign) CGFloat titleBottomLineMargin;//左右两边的间距

@property (nonatomic,assign) CGFloat strokeWidth;//选中标题的字宽，默认0，表示不加宽。建议加宽范围(-1~-4)
@property (nonatomic,assign) CGFloat titleRightGap;//标题栏右侧多余空隙
@property (nonatomic,assign) CGFloat titleLeftGap;//标题栏左侧多余空隙

@property (nonatomic,strong,readonly) HeeeScrollPageTitleView *titleView;
@property (nonatomic,weak) id<HeeeScrollPageViewDelegate> delegate;

- (void)setSelectedPageIndex:(NSInteger)selectedIndex animate:(BOOL)animate;

- (void)pageViewControllerDidScroll:(UIScrollView *)scrollView;
- (void)foldTitleViewUncondition:(BOOL)uncondition;//是否无条件收起标题栏
- (void)unfoldTitleView;//展开标题栏

@end
