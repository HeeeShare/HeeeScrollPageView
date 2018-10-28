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
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) NSUInteger willAppearIndex;
@property (nonatomic,assign) NSUInteger didAppearIndex;
@property (nonatomic,assign) NSUInteger willDisappearIndex;
@property (nonatomic,assign) NSUInteger didDisappearIndex;
@property (nonatomic,strong) NSMutableArray *loadVCArray;
@property (nonatomic,strong) NSMutableArray *appearVCArray;
@property (nonatomic,strong) UIViewController *NEWVC;
@property (nonatomic,strong) HeeeScrollPageIndicator *pageIndicator;
@property (nonatomic,assign) BOOL clickFlag;
@property (nonatomic,assign) BOOL addRemoveTitleFlag;
@property (nonatomic,assign) BOOL insideContentSizeFlag;
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
            [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.bounds.size.width*index, 0) animated:weakSelf.clickTitleAnimate];
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
}

- (void)addChildVC:(UIViewController *)childVC toIndex:(NSUInteger)index {
    if (childVC) {
        if (index < 0) {
            index = 0;
        }else if (index > _childVCArr.count) {
            index = _childVCArr.count;
        }
        
        _addRemoveTitleFlag = YES;
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
    NSUInteger totalPage = _childVCArr.count;
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if ((!_clickTitleAnimate && _clickFlag) || _addRemoveTitleFlag) {
        _clickFlag = NO;
        _addRemoveTitleFlag = NO;
        _pageIndicator.offsetX = offsetX;
        NSUInteger page = scrollView.contentOffset.x/_width;
        UIViewController *disAppearVC = _childVCArr[_didAppearIndex];
        [disAppearVC viewWillDisappear:NO];
        [disAppearVC viewDidDisappear:NO];
        [_appearVCArray removeObject:disAppearVC];
        _willDisappearIndex = _didAppearIndex;
        _didDisappearIndex = _didAppearIndex;
        
        UIViewController *appearVC = _childVCArr[page];
        if ([_loadVCArray containsObject:appearVC]) {
            [appearVC viewWillAppear:NO];
            [appearVC viewDidAppear:NO];
            if (![_appearVCArray containsObject:appearVC]) {
                [_appearVCArray addObject:appearVC];
            }
        }else{
            [self addChildVCIndex:page];
            _NEWVC = nil;
        }
        
        _willAppearIndex = page;
        _didAppearIndex = page;
        return;
    }
    
    if (offsetX > 0 && offsetX < (totalPage - 1)*_width) {
        if (_NEWVC) {
            NSUInteger index = [_childVCArr indexOfObject:_NEWVC];
            if (offsetX > index*_width || offsetX < (index - 1)*_width) {
                _NEWVC = nil;
            }
        }
        
        _insideContentSizeFlag = YES;
        _pageIndicator.offsetX = offsetX;
        
        for (NSUInteger i = 0; i < _childVCArr.count; i++) {
            if (offsetX > i*_width && offsetX < (i+1)*_width) {
                if (_willAppearIndex != i && _willDisappearIndex != i) {
                    _willAppearIndex = i;
                    _willDisappearIndex = i + 1;
                    UIViewController *willDisappearVC = _childVCArr[_willDisappearIndex];
                    [willDisappearVC viewWillDisappear:YES];
                    
                    UIViewController *willAppearVC = _childVCArr[_willAppearIndex];
                    if ([_loadVCArray containsObject:willAppearVC]) {
                        if (_NEWVC != willAppearVC) {
                            [willAppearVC viewWillAppear:YES];
                            if (![_appearVCArray containsObject:willAppearVC]) {
                                [_appearVCArray addObject:willAppearVC];
                            }
                        }
                    }else{
                        [self addChildVCIndex:i];
                    }
                }
                
                if (_willAppearIndex != i + 1  && _willDisappearIndex != i + 1) {
                    _willAppearIndex = i + 1;
                    _willDisappearIndex = i;
                    UIViewController *willDisappearVC = _childVCArr[_willDisappearIndex];
                    [willDisappearVC viewWillDisappear:YES];
                    
                    UIViewController *willAppearVC = _childVCArr[_willAppearIndex];
                    if ([_loadVCArray containsObject:willAppearVC]) {
                        if (_NEWVC != willAppearVC) {
                            [willAppearVC viewWillAppear:YES];
                            if (![_appearVCArray containsObject:willAppearVC]) {
                                [_appearVCArray addObject:willAppearVC];
                            }
                        }
                    }else{
                        [self addChildVCIndex:i + 1];
                    }
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x/_width;
    
    if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= (_childVCArr.count- 1)*_width) {
        if (_didAppearIndex == 0 && page == 0  && _willAppearIndex == 0) {
            [self clearShouldDisappearVC:_insideContentSizeFlag];
            return;
        }
        
        if (_didAppearIndex == self.childVCArr.count - 1 && page == self.childVCArr.count - 1 && _willAppearIndex == self.childVCArr.count - 1) {
            [self clearShouldDisappearVC:_insideContentSizeFlag];
            return;
        }
        
        _willAppearIndex = page;
        UIViewController *didAppearVC = _childVCArr[_willAppearIndex];
        if (didAppearVC != _NEWVC) {
            [didAppearVC viewDidAppear:YES];
            if (![_appearVCArray containsObject:didAppearVC]) {
                [_appearVCArray addObject:didAppearVC];
            }
            _didDisappearIndex = _willDisappearIndex;
        }
        _didAppearIndex = _willAppearIndex;
        
        if (_willDisappearIndex != _willAppearIndex) {
            UIViewController *didDisAppearVC = _childVCArr[_willDisappearIndex];
            [didDisAppearVC viewDidDisappear:YES];
            [_appearVCArray removeObject:didDisAppearVC];
            _willDisappearIndex = _willAppearIndex;
        }
        
        [self clearShouldDisappearVC:NO];
        
        _NEWVC = nil;
    }
}

- (void)clearShouldDisappearVC:(BOOL)flag {
    NSMutableArray *temArr = [NSMutableArray array];
    UIViewController *didAppearVC = _childVCArr[_didAppearIndex];
    
    for (NSUInteger i = 0; i < _appearVCArray.count; i++) {
        UIViewController *shouldDisappearVC = _appearVCArray[i];
        if (shouldDisappearVC != didAppearVC) {
            [shouldDisappearVC viewDidDisappear:NO];
            [temArr addObject:shouldDisappearVC];
        }
    }
    
    if (flag) {
        [didAppearVC viewDidAppear:YES];
    }
    
    _insideContentSizeFlag = NO;
    [_appearVCArray removeObjectsInArray:temArr];
}

@end
