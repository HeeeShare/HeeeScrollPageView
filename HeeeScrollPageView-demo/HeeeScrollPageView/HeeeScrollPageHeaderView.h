//
//  HeeeScrollPageHeaderView.h
//  ceshi010
//
//  Created by Heee on 2019/7/7.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeeeScrollPageHeaderView : UIView
@property (nonatomic,strong) NSArray <NSString *>*titles;
@property (nonatomic,assign) BOOL spaceAround;
@property (nonatomic,strong) UIColor *titleNormalColor;
@property (nonatomic,strong) UIColor *titleSelectedColor;
@property (nonatomic,assign) CGFloat titleFontSize;
@property (nonatomic,assign) CGFloat titleZoomScale;
@property (nonatomic,assign) CGFloat titleGap;
@property (nonatomic,assign) CGFloat scrollViewOffsetX;
@property (nonatomic,assign) CGFloat scrollViewOffsetY;
@property (nonatomic,strong) UIColor *indicatorColor;
@property (nonatomic,assign) CGFloat indicatorHeight;
@property (nonatomic,assign) CGFloat indicatorBottomOffset;
@property (nonatomic,assign) CGFloat strokeWidth;
@property (nonatomic,strong) UIColor *titleBottomViewLineColor;
@property (nonatomic,assign) CGFloat titleBottomViewLineHeight;
@property (nonatomic,assign) CGFloat titleBottomViewLineHorizonalMargin;
@property (nonatomic,copy) void (^shouldScrollToPage)(NSUInteger pageIndex, BOOL animate);

@end
