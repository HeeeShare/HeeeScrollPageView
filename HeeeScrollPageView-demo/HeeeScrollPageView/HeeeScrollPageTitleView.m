//
//  HeeeScrollPageTitleView.m
//  ceshi010
//
//  Created by 过道边的iMac on 2019/7/1.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import "HeeeScrollPageTitleView.h"

@interface HeeeScrollPageTitleView ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray <UILabel *>*labelArray;
@property (nonatomic,assign) NSUInteger selectedIndex;
@property (nonatomic,strong) UIView *indicatorView;
@property (nonatomic,assign) CGFloat currentZoomScale;
@property (nonatomic,strong) UIView *bottomLine;
@property (nonatomic,assign) BOOL firstLoad;

@end

@implementation HeeeScrollPageTitleView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_setupInterface];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupInterface];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.titles.count > 0 && self.scrollView.subviews == 0) {
        [self setTitles:self.titles];
    }
}

- (void)setTitles:(NSArray<NSString *> *)titles {
    if (self.defaultPage >= titles.count) {
        self.defaultPage = 0;
    }
    
    [self.labelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labelArray removeAllObjects];
    self.scrollView.frame = self.bounds;
    _titles = titles;
    self.currentZoomScale = 1.0;
    if (self.firstLoad) {
        self.selectedIndex = self.defaultPage;
    }
    self.firstLoad = NO;
    
    self.bottomLine.backgroundColor = self.titleBottomLineColor;
    self.bottomLine.frame = CGRectMake(self.titleBottomLineMargin, self.bounds.size.height - self.titleBottomLineHeight, self.bounds.size.width - 2*self.titleBottomLineMargin, self.titleBottomLineHeight);
    
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        
        NSDictionary *attri;
        if (self.selectedIndex == idx) {
            attri = @{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:self.titleSelectedColor,
                      NSStrokeWidthAttributeName:@(self.strokeWidth)};
        }else{
            attri = @{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:self.titleNormalColor,
                      NSStrokeWidthAttributeName:@(0)};
        }
        
        NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc]initWithString:obj attributes:attri];
        label.attributedText = mAttributedString;
        [label sizeToFit];
        label.frame = CGRectMake(0, 0, ceil(label.bounds.size.width), ceil(label.bounds.size.height));
        if (self.selectedIndex != idx) {
            label.transform = CGAffineTransformMakeScale(1.0/self.titleZoomScale, 1.0/self.titleZoomScale);
        }
        
        [self.scrollView addSubview:label];
        [self.labelArray addObject:label];
    }];
    
    [self handleOffset:self.selectedIndex*self.scrollView.bounds.size.width];
}

- (void)setScrollViewOffsetX:(CGFloat)scrollViewOffsetX {
    _scrollViewOffsetX = scrollViewOffsetX;
    [self handleOffset:scrollViewOffsetX];
}

- (void)handleOffset:(CGFloat)offset {
    if (self.labelArray.count == 1) {
        UILabel *titleLabel = self.labelArray.firstObject;
        if (self.titleArrangement == HeeeTitleArrangementCenter || self.titleArrangement == HeeeTitleArrangementSpaceAround) {
            CGFloat labelW = titleLabel.frame.size.width;
            CGFloat labelH = titleLabel.frame.size.height;
            CGFloat labelX = (self.bounds.size.width - titleLabel.frame.size.width)/2;
            CGFloat labelY = (self.bounds.size.height - labelH)/(self.titleVerticalCenter?2:1) - self.titleVerticalOffset;
            titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        }else{
            CGFloat labelW = titleLabel.frame.size.width;
            CGFloat labelH = titleLabel.frame.size.height;
            CGFloat labelX = self.titleLeftGap;
            CGFloat labelY = (self.bounds.size.height - labelH)/(self.titleVerticalCenter?2:1) - self.titleVerticalOffset;
            titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);
        }
        
        CGFloat indicatorViewW = self.indicatorWidth==0?titleLabel.frame.size.width:self.indicatorWidth;
        CGFloat indicatorViewH = self.indicatorHeight;
        CGFloat indicatorViewX = CGRectGetMidX(titleLabel.frame) - indicatorViewW/2;
        CGFloat indicatorViewY = self.bounds.size.height - indicatorViewH - self.titleBottomLineHeight - self.indicatorVerticalOffset;
        self.indicatorView.frame = CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewH);
        self.indicatorView.backgroundColor = self.indicatorColor;
        self.indicatorView.layer.cornerRadius = self.indicatorCornerRadius;
    }
    
    if (offset < 0 || offset > (self.labelArray.count - 1)*self.bounds.size.width || self.labelArray.count < 2) {
        return;
    }
    
    int firstPage = (int)(offset/self.bounds.size.width);
    BOOL justOnPage = offset - firstPage*self.bounds.size.width == 0;
    if (justOnPage) {
        self.selectedIndex = firstPage;
    }
    
    int pageNumber = offset/self.bounds.size.width;
    if (offset - pageNumber*self.bounds.size.width == 0 && firstPage > 0) {
        firstPage -= 1;
    }
    int secondPage = firstPage + 1;
    
    CGFloat rate = (offset - (int)(offset/self.bounds.size.width)*self.bounds.size.width)/self.bounds.size.width;
    if (rate == 0 && offset != 0) {
        rate = 1;
    }
    UILabel *firstLabel = self.labelArray[firstPage];
    UILabel *secondLabel = self.labelArray[secondPage];
    [self p_XChangeAttributeWithRate:rate firstLabel:firstLabel secondLabel:secondLabel];
    
    __block CGFloat right = 0;
    __block CGFloat firstLabelWidth = 0;
    __block CGFloat secondLabelWidth = 0;
    __block CGFloat firstLabelCenterX = 0;
    __block CGFloat secondLabelCenterX = 0;
    
    if (self.titleArrangement == HeeeTitleArrangementSpaceAround) {
        CGFloat totalWidth = 0;
        for (UILabel *titleL in self.labelArray) {
            totalWidth+=titleL.frame.size.width/self.titleZoomScale;
        }
        self.titleHorizontalGap = (self.bounds.size.width - totalWidth)/self.labelArray.count;
    }else if (self.titleArrangement == HeeeTitleArrangementCenter) {
        CGFloat totalWidth = 0;
        for (UILabel *titleL in self.labelArray) {
            totalWidth+=titleL.frame.size.width;
        }
        totalWidth+=self.labelArray.count*self.titleHorizontalGap;
        right = (self.bounds.size.width - totalWidth)/2;
    }
    
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelW = label.frame.size.width;
        CGFloat labelH = label.frame.size.height;
        CGFloat labelX = right + self.titleHorizontalGap*(idx==0?0.5:1.0) + (idx==0?self.titleLeftGap:0);
        CGFloat labelY = (self.bounds.size.height - labelH)/(self.titleVerticalCenter?2:1) - self.titleVerticalOffset;
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        right = labelX + labelW;
        if (firstPage == idx) {
            firstLabelWidth = labelW;
            firstLabelCenterX = label.center.x;
        }
        
        if (secondPage == idx) {
            secondLabelWidth = labelW;
            secondLabelCenterX = label.center.x;
        }
        
        CGFloat indicatorViewW = self.indicatorWidth==0?(secondLabelWidth - (secondLabelWidth - firstLabelWidth)*(1 - rate)):self.indicatorWidth;
        CGFloat indicatorViewH = self.indicatorHeight;
        CGFloat indicatorViewX = secondLabelCenterX*rate + firstLabelCenterX*(1 - rate) - indicatorViewW/2;
        CGFloat indicatorViewY = self.bounds.size.height - indicatorViewH - self.titleBottomLineHeight - self.indicatorVerticalOffset;
        self.indicatorView.frame = CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewH);
        self.indicatorView.backgroundColor = self.indicatorColor;
        self.indicatorView.layer.cornerRadius = self.indicatorCornerRadius;
    }];
    
    UILabel *lastLabel = self.labelArray.lastObject;
    self.scrollView.contentSize = CGSizeMake(lastLabel.frame.origin.x + lastLabel.frame.size.width + self.titleHorizontalGap/2 + self.titleRightGap, 0);
    
    if (self.titleArrangement == HeeeTitleArrangementDefault && self.scrollView.contentSize.width > self.bounds.size.width) {
        CGFloat offsetX = 0;
        CGFloat firstLabelX = firstLabel.center.x;
        CGFloat secondLabelX = secondLabel.center.x;
        if (secondLabelX > firstLabelX) {
            offsetX = firstLabelX + (secondLabelX - firstLabelX)*rate - self.bounds.size.width/2;
        }else{
            offsetX = firstLabelX - (secondLabelX - firstLabelX)*rate - self.bounds.size.width/2;
        }
        
        if (offsetX <= 0) {
            offsetX = 0;
        }else if (offsetX >= self.scrollView.contentSize.width - self.bounds.size.width) {
            offsetX = self.scrollView.contentSize.width - self.bounds.size.width;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
}

- (void)setScrollViewOffsetY:(CGFloat)scrollViewOffsetY {
    if (self.labelArray.count <= self.selectedIndex) return;
    CGFloat indicatorViewCenterX = self.indicatorView.center.x;
    CGFloat selectedLabelCenterX = self.labelArray[self.selectedIndex].center.x;
    if (indicatorViewCenterX != selectedLabelCenterX) {
        return;
    }
    
    _scrollViewOffsetY = scrollViewOffsetY;
    
    CGFloat rate = (self.maxHeight - self.bounds.size.height)/(self.maxHeight - self.miniHeight);
    if (self.maxHeight == self.miniHeight) {
        rate = 0;
    }
    [self p_YChangeAttributeWithRate:rate];
    
    __block CGFloat right = 0;
    if (self.titleArrangement == HeeeTitleArrangementSpaceAround) {
        CGFloat totalWidth = 0;
        for (UILabel *titleL in self.labelArray) {
            totalWidth+=titleL.frame.size.width/self.titleZoomScale;
        }
        self.titleHorizontalGap = (self.bounds.size.width - totalWidth)/self.labelArray.count;
    }else if (self.titleArrangement == HeeeTitleArrangementCenter) {
        CGFloat totalWidth = 0;
        for (UILabel *titleL in self.labelArray) {
            totalWidth+=titleL.frame.size.width;
        }
        totalWidth+=self.labelArray.count*self.titleHorizontalGap;
        right = (self.bounds.size.width - totalWidth)/2;
    }
    
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelW = label.frame.size.width;
        CGFloat labelH = label.frame.size.height;
        CGFloat labelX = right + self.titleHorizontalGap*(idx==0?0.5:1.0) + (idx==0?self.titleLeftGap:0);
        CGFloat labelY = (self.bounds.size.height - labelH)/(self.titleVerticalCenter?2:1) - self.titleVerticalOffset;
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        right = labelX + labelW;
        if (self.selectedIndex == idx) {
            CGFloat indicatorViewW = labelW;
            CGFloat indicatorViewH = self.indicatorHeight;
            CGFloat indicatorViewX = labelX;
            CGFloat indicatorViewY = self.bounds.size.height - indicatorViewH - self.titleBottomLineHeight;
            self.indicatorView.frame = CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewH);
            self.indicatorView.backgroundColor = self.indicatorColor;
            [self setScrollViewOffsetX:self.scrollViewOffsetX];
        }
    }];
}

- (void)tapAction:(UIGestureRecognizer *)ges {
    CGPoint touchPoint = [ges locationInView:self];
    CGPoint scrollViewPoint = [self convertPoint:touchPoint toView:self.scrollView];
    
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect touchFrame = CGRectMake(label.frame.origin.x - self.titleHorizontalGap/2, 0, label.frame.size.width + self.titleHorizontalGap, self.bounds.size.height);
        if (CGRectContainsPoint(touchFrame, scrollViewPoint)) {
            !self.shouldScrollToPage?:self.shouldScrollToPage(idx);
            *stop = YES;
        }
    }];
}

#pragma mark - private
- (void)p_setupInterface {
    self.firstLoad = YES;
    self.clipsToBounds = YES;
    [self addSubview:self.scrollView];
    [self addSubview:self.bottomLine];
    [self.scrollView addSubview:self.indicatorView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGes];
    
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)p_YChangeAttributeWithRate:(CGFloat)rate {
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.selectedIndex == idx) {
            self.currentZoomScale = 1.0/self.titleZoomScale + (1 - 1.0/self.titleZoomScale)*(1 - rate);
            label.transform = CGAffineTransformMakeScale(self.currentZoomScale, self.currentZoomScale);
        }else{
            label.transform = CGAffineTransformMakeScale(1.0/self.titleZoomScale, 1.0/self.titleZoomScale);
        }
    }];
}

- (void)p_XChangeAttributeWithRate:(CGFloat)rate firstLabel:(UILabel *)firstLabel secondLabel:(UILabel *)secondLabel {
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = self.titles[idx];
        NSDictionary *attri = @{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                                NSForegroundColorAttributeName:self.titleNormalColor,
                                NSStrokeWidthAttributeName:@(0)};
        CGFloat zoomScale = 1.0/self.titleZoomScale;
        
        if (label == firstLabel) {
            attri = @{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:[self p_changeColorWithRate:rate andIsFirstLabel:YES],
                      NSStrokeWidthAttributeName:@(self.strokeWidth*(1 - rate))};
            zoomScale = 1.0/self.titleZoomScale + (self.currentZoomScale - 1.0/self.titleZoomScale)*(1 - rate);
        }else if (label == secondLabel){
            attri = @{NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:[self p_changeColorWithRate:rate andIsFirstLabel:NO],
                      NSStrokeWidthAttributeName:@(self.strokeWidth*rate)};
            zoomScale = 1.0/self.titleZoomScale + (self.currentZoomScale - 1.0/self.titleZoomScale)*rate;
        }
        
        NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attri];
        label.attributedText = mAttributedString;
        label.transform = CGAffineTransformMakeScale(zoomScale,zoomScale);
    }];
}

- (UIColor *)p_changeColorWithRate:(CGFloat)rate andIsFirstLabel:(BOOL)isFirstLabel {
    CGFloat r0,g0,b0,a0 = 0.0;
    [self.titleSelectedColor getRed:&r0 green:&g0 blue:&b0 alpha:&a0];
    
    CGFloat r1,g1,b1,a1 = 0.0;
    [self.titleNormalColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    if (isFirstLabel) {
        return [UIColor colorWithRed:(r0 + (r1 - r0)*rate) green:(g0 + (g1 - g0)*rate) blue:(b0 + (b1 - b0)*rate) alpha:(a0 + (a1 - a0)*rate)];
    }else{
        return [UIColor colorWithRed:(r1 + (r0 - r1)*rate) green:(g1 + (g0 - g1)*rate) blue:(b1 + (b0 - b1)*rate) alpha:(a1 + (a0 - a1)*rate)];
    }
}

#pragma mark - lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    
    return _scrollView;
}

- (NSMutableArray<UILabel *> *)labelArray {
    if (!_labelArray) {
        _labelArray = [NSMutableArray array];
    }
    
    return _labelArray;
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
    }
    
    return _indicatorView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
    }
    
    return _bottomLine;
}

@end
