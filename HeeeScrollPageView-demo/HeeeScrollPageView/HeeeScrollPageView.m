//
//  HeeeScrollPageView.m
//  HeeeScrollPageView-demo
//
//  Created by hgy on 2018/10/28.
//  Copyright © 2018 hgy. All rights reserved.
//

#import "HeeeScrollPageView.h"
#import "HeeeScrollPageIndicator.h"
#import "UIView+HeeeQuickFrame.h"

@interface HeeeScrollPageView()<UIScrollViewDelegate>
@property (nonatomic,  weak) UIViewController *parentVC;
@property (nonatomic,strong) NSMutableArray <UIViewController *>*childVCArr;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HeeeScrollPageIndicator *pageIndicator;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) NSUInteger willAppearIndex;
@property (nonatomic,assign) NSUInteger didAppearIndex;
@property (nonatomic,assign) NSUInteger willDisappearIndex;
@property (nonatomic,assign) NSUInteger didDisappearIndex;
@property (nonatomic,strong) NSMutableArray *loadVCArray;
@property (nonatomic,strong) NSMutableArray *appearVCArray;
@property (nonatomic,strong) UIViewController *NEWVC;
@property (nonatomic,assign) BOOL clickFlag;
@property (nonatomic,assign) BOOL animate;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation HeeeScrollPageView
- (instancetype)initWithFrame:(CGRect)frame childVC:(NSArray<UIViewController *> *)childVCArr andIndicatorHeight:(CGFloat)indicatorHeight{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _childVCArr = [childVCArr mutableCopy];
        _width = frame.size.width;
        _loadVCArray = [NSMutableArray array];
        _appearVCArray = [NSMutableArray array];
        
        NSMutableArray *titleArr = [NSMutableArray array];
        for (NSUInteger i = 0; i < _childVCArr.count; i++) {
            UIViewController *vc = _childVCArr[i];
            if (vc.title && vc.title.length > 0) {
                [titleArr addObject:vc.title];
            }else{
                [titleArr addObject:@"    "];
            }
        }
        
        _pageIndicator = [[HeeeScrollPageIndicator alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, indicatorHeight) AndTitle:titleArr];
        __weak typeof(self) weakSelf = self;
        _pageIndicator.showPage = ^(NSUInteger index) {
            weakSelf.clickFlag = YES;
            
            weakSelf.animate = YES;
            for (NSUInteger i = MIN(index, weakSelf.didAppearIndex) + 1; i < MAX(index, weakSelf.didAppearIndex); i++) {
                if (![weakSelf.loadVCArray containsObject:weakSelf.childVCArr[i]]) {
                    weakSelf.animate = NO;
                }
            }
            
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.bounds.size.width*index, 0) animated:weakSelf.animate];
        };
        [self addSubview:_pageIndicator];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _pageIndicator.heee_bottom, self.frame.size.width, self.frame.size.height - _pageIndicator.heee_bottom)];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(findViewController) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)findViewController {
    _parentVC = [self viewController];
    if (_parentVC) {
        [_timer invalidate];
        _timer = nil;
        
        if (_childVCArr.count > 0) {
            _scrollView.contentSize = CGSizeMake(_width*_childVCArr.count, 0);
            [self addChildVCIndex:0];
        }
    }
}

- (UIViewController *)viewController {
    UIView *next = self;
    while ((next = [next superview])) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)addChildVCIndex:(NSUInteger)index {
    UIViewController *childVC = _childVCArr[index];
    childVC.view.frame = CGRectMake(index*self.bounds.size.width, 0, self.bounds.size.width, _scrollView.heee_height);
    [childVC.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [childVC viewDidLoad];
    _NEWVC = childVC;
    [_parentVC addChildViewController:childVC];
    [_scrollView addSubview:childVC.view];
    [_loadVCArray addObject:childVC];
    [_appearVCArray addObject:childVC];
    _didAppearIndex = index;
}

- (void)addChildVC:(UIViewController *)childVC toIndex:(NSUInteger)index {
    if (childVC) {
        if (index < 0) {
            index = 0;
        }else if (index > _childVCArr.count) {
            index = _childVCArr.count;
        }
        
        [_childVCArr insertObject:childVC atIndex:index];
        
        for (NSUInteger i = 0; i < _loadVCArray.count; i++) {
            UIViewController *loadVC = _loadVCArray[i];
            if ([_childVCArr indexOfObject:loadVC] > index) {
                loadVC.view.heee_right+=_width;
            }
        }
        
        [_pageIndicator addTitle:childVC.title toIndex:index];
        _scrollView.contentSize = CGSizeMake(_width*_childVCArr.count, 0);
        
        if (index <= _didAppearIndex) {
            _didAppearIndex++;
            _willAppearIndex++;
            
            [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x+_width, 0) animated:NO];
        }
        
        if (_didAppearIndex != index) {
            if (_willAppearIndex == index || _willDisappearIndex == index) {
                [self addChildVCIndex:index];
            }
        }
    }
}

- (void)removeChildVC:(NSUInteger)index {
    if (index >= 0 && index < _childVCArr.count) {
        UIViewController *needRemoveVC = [_childVCArr objectAtIndex:index];
        [_childVCArr removeObject:needRemoveVC];
        
        if ([_loadVCArray containsObject:needRemoveVC]) {
            [_loadVCArray removeObject:needRemoveVC];
        }
        
        [needRemoveVC.view removeFromSuperview];
        
        for (NSUInteger i = 0; i < _loadVCArray.count; i++) {
            UIViewController *loadVC = _loadVCArray[i];
            if ([_childVCArr indexOfObject:loadVC] >= index) {
                loadVC.view.heee_right-=_width;
            }
        }
        
        [_pageIndicator removeTitle:index];
        
        BOOL flag = NO;
        
        if (_didAppearIndex > index) {
            _didAppearIndex--;
            flag = YES;
        }
        
        if (_willAppearIndex > index) {
            flag = YES;
            _willAppearIndex--;
        }
        
        if (flag) {
            [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x - _width, 0) animated:NO];
        }
        
        _scrollView.contentSize = CGSizeMake(_width*_childVCArr.count, 0);
        
        if (_didAppearIndex == index) {
            UIViewController *didAppearVC = _childVCArr[index];
            if (![_loadVCArray containsObject:didAppearVC]) {
                [self addChildVCIndex:index];
            }
        }
        
        UIViewController *willAppearVC = _childVCArr[_willAppearIndex];
        if (![_loadVCArray containsObject:willAppearVC]) {
            [self addChildVCIndex:_willAppearIndex];
        }
    }
}

- (void)setTitleGap:(CGFloat)titleGap {
    _titleGap = titleGap;
    _pageIndicator.titleGap = titleGap;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _pageIndicator.titleFont = titleFont;
}

- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    _pageIndicator.lineHeight = lineHeight;
}

- (void)setLineGap:(CGFloat)lineGap {
    _lineGap = lineGap;
    _pageIndicator.lineGap = lineGap;
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    _pageIndicator.normalColor = normalColor;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    _pageIndicator.highlightColor = highlightColor;
}

- (void)setIndicatorBGColor:(UIColor *)indicatorBGColor {
    _indicatorBGColor = indicatorBGColor;
    _pageIndicator.backgroundColor = indicatorBGColor;
}

- (void)setLineOffsetY:(CGFloat)lineOffsetY {
    _lineOffsetY = lineOffsetY;
    _pageIndicator.lineOffsetY = lineOffsetY;
}

- (void)setTitleOffsetY:(CGFloat)titleOffsetY {
    _titleOffsetY = titleOffsetY;
    _pageIndicator.titleOffsetY = titleOffsetY;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSUInteger page = scrollView.contentOffset.x/_width;
    
    if (_clickFlag && !_animate && offsetX - page*_width == 0) {
        _clickFlag = NO;
        _pageIndicator.offsetX = offsetX;
        UIViewController *willAppearVC = _childVCArr[page];
        if ([_loadVCArray containsObject:willAppearVC]) {
            _didAppearIndex = page;
            [willAppearVC viewWillAppear:NO];
            [willAppearVC viewDidAppear:NO];
            [_appearVCArray addObject:willAppearVC];
        }else{
            [self addChildVCIndex:page];
        }
        
        [self clearShouldDisappearVC];
        _NEWVC = nil;
        return;
    }
    
    if (offsetX >= 0 && offsetX <= (_childVCArr.count- 1)*_width) {
        _pageIndicator.offsetX = offsetX;
        
        if (offsetX - page*_width != 0) {
            for (NSUInteger i = page; i <= page + 1; i++) {
                UIViewController *willAppearVC = _childVCArr[i];
                if (![_loadVCArray containsObject:willAppearVC]) {
                    [self addChildVCIndex:i];
                    [self clearShouldDisappearVC];
                    break;
                }
            }
        }
        
        if (_clickFlag && offsetX - page*_width == 0) {
            _clickFlag = NO;
            _didAppearIndex = page;
            UIViewController *didAppearVC = _childVCArr[_didAppearIndex];
            if (_NEWVC != didAppearVC) {
                [didAppearVC viewWillAppear:NO];
                [didAppearVC viewDidAppear:NO];
                [_appearVCArray addObject:didAppearVC];
            }
            
            [self clearShouldDisappearVC];
            _NEWVC = nil;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSUInteger page = scrollView.contentOffset.x/_width;
    
    if (offsetX >= 0 && offsetX <= (_childVCArr.count- 1)*_width && _didAppearIndex != page) {
        _didAppearIndex = page;
        UIViewController *didAppearVC = _childVCArr[_didAppearIndex];
        
        if (_NEWVC != didAppearVC) {
            [didAppearVC viewWillAppear:NO];
            [didAppearVC viewDidAppear:YES];
            [_appearVCArray addObject:didAppearVC];
        }
        
        [self clearShouldDisappearVC];
        _NEWVC = nil;
    }
}

- (void)clearShouldDisappearVC {
    NSMutableArray *temArr = [NSMutableArray array];
    UIViewController *didAppearVC = _childVCArr[_didAppearIndex];
    
    for (NSUInteger i = 0; i < _appearVCArray.count; i++) {
        UIViewController *shouldDisappearVC = _appearVCArray[i];
        if (shouldDisappearVC != didAppearVC) {
            [shouldDisappearVC viewWillDisappear:NO];
            [shouldDisappearVC viewDidDisappear:NO];
            [temArr addObject:shouldDisappearVC];
        }
    }
    
    [_appearVCArray removeObjectsInArray:temArr];
}

@end
