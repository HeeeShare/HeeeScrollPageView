//
//  HeeeScrollPageHeaderView.m
//  ceshi010
//
//  Created by Heee on 2019/7/7.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import "HeeeScrollPageHeaderView.h"

@interface HeeeScrollPageHeaderView ()
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray <UILabel *>*labelArray;
@property (nonatomic,assign) NSUInteger selectedIndex;
@property (nonatomic,strong) UIView *indicatorView;
@property (nonatomic,strong) UIView *bottomLineView;
@property (nonatomic,assign) CGFloat currentZoomScale;

@end

@implementation HeeeScrollPageHeaderView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_setupInterface];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
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
    [self.labelArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labelArray removeAllObjects];
    self.scrollView.frame = self.bounds;
    self.bottomLineView.frame = CGRectMake(self.titleBottomViewLineHorizonalMargin/2, self.bounds.size.height - self.titleBottomViewLineHeight, self.bounds.size.width - 2*self.titleBottomViewLineHorizonalMargin, self.titleBottomViewLineHeight);
    self.bottomLineView.backgroundColor = self.titleBottomViewLineColor;
    
    _titles = titles;
    _currentZoomScale = 1.0;
    
    if (self.frame.size.width <= 0) {
        return;
    }
    
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        
        NSDictionary *attri;
        if (self.selectedIndex == idx) {
            attri = @{
                      NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:self.titleSelectedColor,
                      NSStrokeWidthAttributeName:@(self.strokeWidth),
                      };
        }else{
            attri = @{
                      NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:self.titleNormalColor,
                      NSStrokeWidthAttributeName:@(0),
                      };
            label.transform = CGAffineTransformMakeScale(1.0/self.titleZoomScale, 1.0/self.titleZoomScale);
        }
        
        NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc]initWithString:obj attributes:attri];
        label.attributedText = mAttributedString;
        [label sizeToFit];
        [self.scrollView addSubview:label];
        [self.labelArray addObject:label];
    }];
    
    [self handleOffset:0];
}

- (void)setScrollViewOffsetX:(CGFloat)scrollViewOffsetX {
    _scrollViewOffsetX = scrollViewOffsetX;
    [self handleOffset:scrollViewOffsetX];
}

- (void)handleOffset:(CGFloat)offset {
    if (offset < 0 || offset > (self.labelArray.count - 1)*self.bounds.size.width || (self.scrollView.contentSize.width > 0 && self.scrollView.contentSize.width < self.scrollView.bounds.size.width)) {
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
    [self p_changeAttributeWithRate:rate firstLabel:firstLabel secondLabel:secondLabel];
    
    __block CGFloat right = 0;
    __block CGFloat firstLabelWidth = 0;
    __block CGFloat secondLabelWidth = 0;
    __block CGFloat firstLabelCenterX = 0;
    __block CGFloat secondLabelCenterX = 0;
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat labelW = label.frame.size.width;
        CGFloat labelH = label.frame.size.height;
        CGFloat labelX = right + self.titleGap;
        CGFloat labelY = (self.bounds.size.height - labelH)/2;
        
        if (self.spaceAround) {
            labelX = self.bounds.size.width/(self.labelArray.count)/2*(2*idx + 1) - labelW/2;
        }
        
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        right += (labelW + self.titleGap);
        
        if (firstPage == idx) {
            firstLabelWidth = labelW;
            firstLabelCenterX = label.center.x;
        }
        
        if (secondPage == idx) {
            secondLabelWidth = labelW;
            secondLabelCenterX = label.center.x;
        }
        
        CGFloat indicatorViewW = secondLabelWidth - (secondLabelWidth - firstLabelWidth)*(1 - rate);
        CGFloat indicatorViewH = self.indicatorHeight;
        CGFloat indicatorViewX = secondLabelCenterX*rate + firstLabelCenterX*(1 - rate) - indicatorViewW/2;
        CGFloat indicatorViewY = self.bounds.size.height - indicatorViewH - self.indicatorBottomOffset - self.titleBottomViewLineHeight;
        self.indicatorView.frame = CGRectMake(indicatorViewX, indicatorViewY, indicatorViewW, indicatorViewH);
        self.indicatorView.backgroundColor = self.indicatorColor;
    }];
    
    UILabel *lastLabel = self.labelArray.lastObject;
    self.scrollView.contentSize = CGSizeMake(lastLabel.frame.origin.x + lastLabel.frame.size.width + self.titleGap, 0);
    
    if (justOnPage && !self.spaceAround && self.scrollView.contentSize.width > self.bounds.size.width) {
        UILabel *selectLabel = self.labelArray[self.selectedIndex];
        CGFloat selectLabelCenterX = selectLabel.center.x;
        CGFloat offsetX = selectLabelCenterX - self.bounds.size.width/2;
        if (offsetX <= 0) {
            offsetX = 0;
        }else if (offsetX >= self.scrollView.contentSize.width - self.bounds.size.width) {
            offsetX = self.scrollView.contentSize.width - self.bounds.size.width;
        }
        
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
}

- (UIColor *)changeColorWithRate:(CGFloat)rate andIsFirstLabel:(BOOL)isFirstLabel {
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

- (void)tapAction:(UIGestureRecognizer *)ges {
    CGPoint touchPoint = [ges locationInView:self];
    CGPoint scrollViewPoint = [self convertPoint:touchPoint toView:self.scrollView];
    
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * label, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect touchFrame = CGRectMake(label.frame.origin.x - self.titleGap/2, 0, label.frame.size.width + self.titleGap, self.bounds.size.height);
        if (CGRectContainsPoint(touchFrame, scrollViewPoint)) {
            BOOL animate = NO;
            if (abs((int)(idx - self.selectedIndex)) == 1) {
                animate = YES;
            }
            
            !self.shouldScrollToPage?:self.shouldScrollToPage(idx,animate);
            *stop = YES;
        }
    }];
}

#pragma mark - private
- (void)p_setupInterface {
    self.clipsToBounds = YES;
    [self addSubview:self.scrollView];
    [self addSubview:self.bottomLineView];
    [self.scrollView addSubview:self.indicatorView];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGes];
}

- (void)p_changeAttributeWithRate:(CGFloat)rate firstLabel:(UILabel *)firstLabel secondLabel:(UILabel *)secondLabel {
    [self.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = self.titles[idx];
        NSDictionary *attri;
        if (label == firstLabel) {
            attri = @{
                      NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:[self changeColorWithRate:rate andIsFirstLabel:YES],
                      NSStrokeWidthAttributeName:@(self.strokeWidth*(1 - rate)),
                      };
            CGFloat zoomScale = 1.0/self.titleZoomScale + (self.currentZoomScale - 1.0/self.titleZoomScale)*(1 - rate);
            label.transform = CGAffineTransformMakeScale(zoomScale,zoomScale);
        }else if (label == secondLabel){
            attri = @{
                      NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:[self changeColorWithRate:rate andIsFirstLabel:NO],
                      NSStrokeWidthAttributeName:@(self.strokeWidth*rate),
                      };
            CGFloat zoomScale = 1.0/self.titleZoomScale + (self.currentZoomScale - 1.0/self.titleZoomScale)*rate;
            label.transform = CGAffineTransformMakeScale(zoomScale,zoomScale);
        }else{
            attri = @{
                      NSFontAttributeName:[UIFont systemFontOfSize:self.titleFontSize],
                      NSForegroundColorAttributeName:self.titleNormalColor,
                      NSStrokeWidthAttributeName:@(0),
                      };
            label.transform = CGAffineTransformMakeScale(1.0/self.titleZoomScale, 1.0/self.titleZoomScale);
        }
        
        NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:attri];
        label.attributedText = mAttributedString;
    }];
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

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
    }
    
    return _bottomLineView;
}

@end
