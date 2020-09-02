//
//  HeeeScrollPageTitleView.h
//  ceshi010
//
//  Created by 过道边的iMac on 2019/7/1.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeeeScrollPageTitleView : UIView
@property (nonatomic,strong) NSArray <NSString *>*titles;
@property (nonatomic,assign) NSUInteger defaultPage;//默认选中的page
@property (nonatomic,assign) BOOL spaceAround;
@property (nonatomic,strong) UIColor *titleNormalColor;
@property (nonatomic,strong) UIColor *titleSelectedColor;
@property (nonatomic,assign) CGFloat titleFontSize;
@property (nonatomic,assign) CGFloat titleZoomScale;
@property (nonatomic,assign) CGFloat maxHeight;
@property (nonatomic,assign) CGFloat miniHeight;
@property (nonatomic,assign) CGFloat scrollViewOffsetX;
@property (nonatomic,assign) CGFloat scrollViewOffsetY;
@property (nonatomic,strong) UIColor *indicatorColor;
@property (nonatomic,assign) CGFloat indicatorHeight;
@property (nonatomic,assign) CGFloat indicatorWidth;//指示线的宽度，默认是文字的宽度。
@property (nonatomic,assign) CGFloat indicatorCornerRadius;
@property (nonatomic,assign) CGFloat indicatorVerticalOffset;
@property (nonatomic,assign) BOOL titleVerticalCenter;//标题竖直是否居中，否表示居底部，默认yes。
@property (nonatomic,assign) CGFloat titleVerticalOffset;//标题竖直方向的偏移，默认0。
@property (nonatomic,assign) CGFloat titleHorizontalGap;//标题水平方向的间距，默认20。
@property (nonatomic,strong) UIColor *titleBottomLineColor;
@property (nonatomic,assign) CGFloat titleBottomLineHeight;
@property (nonatomic,assign) CGFloat titleBottomLineMargin;//左右两边的间距
@property (nonatomic,assign) CGFloat strokeWidth;
@property (nonatomic,assign) CGFloat titleRightGap;
@property (nonatomic,assign) CGFloat titleLeftGap;
@property (nonatomic,copy) void (^shouldScrollToPage)(NSUInteger pageIndex);

@end
