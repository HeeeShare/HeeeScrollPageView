//
//  HeeeScrollPageView.h
//  ceshi010
//
//  Created by Heee on 2019/7/7.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeeeScrollPageView : UIView
@property (nonatomic,strong) NSArray <UIViewController *>*pageVCArray;//标题栏的文字是UIViewController的title
@property (nonatomic,assign) BOOL spaceAround;//是否等间距占满header排列标题栏
@property (nonatomic,assign) CGFloat headerViewHeight;//默认36
@property (nonatomic,strong) UIColor *headerBackgroundColor;
@property (nonatomic,strong) UIColor *titleNormalColor;
@property (nonatomic,strong) UIColor *titleSelectedColor;
@property (nonatomic,assign) CGFloat titleFontSize;//选中时的大小
@property (nonatomic,assign) CGFloat titleZoomScale;//文字缩小的比例，比如：等于2时，非选中的文字等于titleFontSize的一半。
@property (nonatomic,assign) CGFloat titleGap;//标题间距，默认20
@property (nonatomic,strong) UIColor *indicatorColor;
@property (nonatomic,assign) CGFloat indicatorHeight;//默认1.0
@property (nonatomic,assign) CGFloat indicatorBottomOffset;
@property (nonatomic,assign) CGFloat selectTitleStrokeWidth;//选中标题的字宽，默认0，表示字体没有加粗，加粗建议设置为-1～-4。
@property (nonatomic,assign) CGFloat normalTitleStrokeWidth;//非选中标题的字宽，默认0，表示字体没有加粗，加粗建议设置为-1～-4。
@property (nonatomic,strong) UIColor *titleBottomViewLineColor;//标题栏底部细线颜色
@property (nonatomic,assign) CGFloat titleBottomViewLineHeight;//默认1.0
@property (nonatomic,assign) CGFloat titleBottomViewLineHorizonalMargin;//细线左右边距，默认0

@end

