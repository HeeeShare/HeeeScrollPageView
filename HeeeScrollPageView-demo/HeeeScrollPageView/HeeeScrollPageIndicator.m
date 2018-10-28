//
//  HeeeScrollPageIndicator.m
//  HeeesScrollPageView-demo
//
//  Created by hgy on 2018/10/25.
//  Copyright © 2018 hgy. All rights reserved.
//

#import "HeeeScrollPageIndicator.h"
#import "UIView+HeeeQuickFrame.h"

@interface CustomScrollView : UIScrollView

@end

@implementation CustomScrollView
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:[UIButton class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}
@end

@interface CustomButtom : UIButton
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,assign) CGFloat titleWidth;

@end

@implementation CustomButtom

@end

@interface HeeeScrollPageIndicator ()<UIScrollViewDelegate>
@property (nonatomic,strong) CustomScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) NSMutableArray *titleBtnArray;
@property (nonatomic,strong) UIView *lineView;
@property (nonatomic,strong) UIView *bottomLine;
@property (nonatomic,assign) NSUInteger currentIndex;
@property (nonatomic,assign) BOOL addtitleFlag;

@end

@implementation HeeeScrollPageIndicator
- (instancetype)initWithFrame:(CGRect)frame AndTitle:(NSArray *)titleArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _normalColor = [UIColor grayColor];
        _highlightColor = [UIColor colorWithRed:73/255.0 green:157/255.0 blue:251/255.0 alpha:1];
        _titleGap = 40;
        _titleFont = [UIFont systemFontOfSize:17];
        _lineHeight = 4;
        _lineGap = 2;
        _titleArray = [titleArray mutableCopy];
        _titleBtnArray = [NSMutableArray array];
        
        [self setupView];
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
        [self addSubview:_bottomLine];
    }
    
    return self;
}

- (void)setupView {
    if (!_scrollView.superview) {
        _scrollView = [[CustomScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    
    [_titleBtnArray removeAllObjects];
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat totalTitleWidth = 0;
    CGFloat btnLeft = 0;
    for (NSUInteger i = 0; i < _titleArray.count; i++) {
        NSString *title = _titleArray[i];
        CGRect rect = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:_titleFont,NSFontAttributeName,nil] context:nil];
        totalTitleWidth += rect.size.width;
        
        CustomButtom *titleBtn = [[CustomButtom alloc] initWithFrame:CGRectMake(btnLeft, 0, rect.size.width + _titleGap, rect.size.height)];
        titleBtn.index = i;
        titleBtn.titleWidth = rect.size.width;
        titleBtn.heee_centerY = self.bounds.size.height/2;
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [titleBtn setTitle:title forState:UIControlStateNormal];
        titleBtn.titleLabel.font = _titleFont;
        [_scrollView addSubview:titleBtn];
        [_titleBtnArray addObject:titleBtn];
        btnLeft = titleBtn.heee_right;
        
        if (i == _currentIndex) {
            [titleBtn setTitleColor:_highlightColor forState:UIControlStateNormal];
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, titleBtn.heee_bottom + _lineGap + _lineOffsetY, titleBtn.heee_width + 4 - _titleGap, _lineHeight)];
            _lineView.userInteractionEnabled = NO;
            _lineView.heee_centerX = titleBtn.heee_centerX;
            _lineView.backgroundColor = _highlightColor;
            [_scrollView addSubview:_lineView];
        }else{
            [titleBtn setTitleColor:_normalColor forState:UIControlStateNormal];
        }
        
        titleBtn.heee_top = 0;
        titleBtn.heee_height = self.bounds.size.height;
        [titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, _lineHeight + _lineGap - 2*_titleOffsetY, 0)];
    }
    
    //如果整个titleBtn都没有占完，就重新均分
    if (btnLeft > 0 && btnLeft < self.bounds.size.width) {
            CGFloat btnLeft = 0;
            for (NSUInteger i = 0; i < _titleBtnArray.count; i++) {
                CustomButtom *titleBtn = _titleBtnArray[i];
                titleBtn.heee_left = btnLeft;
                titleBtn.heee_width += (((self.bounds.size.width - totalTitleWidth)/_titleArray.count) - _titleGap);
                btnLeft = titleBtn.heee_right;
            }
        
            CustomButtom *currentTitleBtn = _titleBtnArray[_currentIndex];
            self.lineView.heee_width = currentTitleBtn.titleWidth + 4;
            self.lineView.heee_centerX = currentTitleBtn.heee_centerX;
        
            _scrollView.contentSize = CGSizeMake(btnLeft, 0);
    }else{
        _scrollView.contentSize = CGSizeMake(btnLeft, 0);
    }
    
    _lineView.heee_top -= (_lineHeight + _lineGap)/2;
}

- (void)addTitle:(NSString *)title toIndex:(NSUInteger)index {
    [_titleArray insertObject:title atIndex:index];
    _addtitleFlag = YES;
    [self setupView];
}

- (void)removeTitle:(NSUInteger)index {
    [_titleArray removeObjectAtIndex:index];
    _addtitleFlag = YES;
    
    if (_currentIndex == _titleArray.count) {
        _currentIndex--;
    }
    
    [self setupView];
}

- (void)setLineOffsetY:(CGFloat)lineOffsetY {
    _lineOffsetY = lineOffsetY;
    [self setupView];
}

- (void)setTitleOffsetY:(CGFloat)titleOffsetY {
    _titleOffsetY = titleOffsetY;
    [self setupView];
}

- (void)setLineGap:(CGFloat)lineGap {
    _lineGap = lineGap;
    [self setupView];
}

- (void)setTitleGap:(CGFloat)titleGap {
    _titleGap = titleGap;
    [self setupView];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [self setupView];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [self setupView];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self setupView];
}

- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    [self setupView];
}

- (void)titleBtnClick:(CustomButtom *)sender {
    if (sender.index != _currentIndex && _showPage) {
        _showPage(sender.index);
    }
}

- (void)setOffsetX:(CGFloat)offsetX {
    _offsetX = offsetX;
    
    NSUInteger index = (_offsetX + 0.5*self.frame.size.width)/self.frame.size.width;
    if (_currentIndex != index) {
        CustomButtom *oldTitleBtn = _titleBtnArray[_currentIndex];
        [oldTitleBtn setTitleColor:_normalColor forState:UIControlStateNormal];
        _currentIndex = index;
        CustomButtom *newTitleBtn = _titleBtnArray[_currentIndex];
        [newTitleBtn setTitleColor:_highlightColor forState:UIControlStateNormal];
        [UIView animateWithDuration:_addtitleFlag?0:0.25 animations:^{
            self.lineView.heee_width = newTitleBtn.titleWidth + 4;
            self.lineView.heee_centerX = newTitleBtn.heee_centerX;
        }];
        
        if (newTitleBtn.heee_centerX < self.bounds.size.width/2) {
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:!_addtitleFlag];
        }else if (newTitleBtn.heee_centerX > self.bounds.size.width/2 && newTitleBtn.heee_centerX < self.scrollView.contentSize.width - self.bounds.size.width/2) {
            [self.scrollView setContentOffset:CGPointMake(newTitleBtn.heee_centerX - self.bounds.size.width/2, 0) animated:!_addtitleFlag];
        }else{
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - self.bounds.size.width, 0) animated:!_addtitleFlag];
        }
    }
    
    _addtitleFlag = NO;
}

@end
