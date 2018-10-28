//
//  HeeeScrollPageIndicator.h
//  HeeesScrollPageView-demo
//
//  Created by hgy on 2018/10/25.
//  Copyright © 2018 hgy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^showPageBlock)(NSUInteger index);

@interface HeeeScrollPageIndicator : UIView
- (instancetype)initWithFrame:(CGRect)frame AndTitle:(NSArray *)titleArray;
- (void)addTitle:(NSString *)title toIndex:(NSUInteger)index;
- (void)removeTitle:(NSUInteger)index;

@property (nonatomic,strong) UIColor *highlightColor;
@property (nonatomic,strong) UIColor *normalColor;
@property (nonatomic,assign) CGFloat titleGap;
@property (nonatomic,strong) UIFont *titleFont;
@property (nonatomic,assign) CGFloat lineHeight;
@property (nonatomic,assign) CGFloat lineGap;
@property (nonatomic,assign) CGFloat offsetX;
@property (nonatomic,assign) CGFloat titleOffsetY;
@property (nonatomic,assign) CGFloat lineOffsetY;
@property (nonatomic,strong) showPageBlock showPage;

@end

