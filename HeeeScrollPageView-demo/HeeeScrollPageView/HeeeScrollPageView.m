//
//  HeeeScrollPageView.m
//  ceshi010
//
//  Created by Heee on 2019/7/7.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import "HeeeScrollPageView.h"
#import "HeeeScrollPageHeaderView.h"

@interface HeeeScrollPageView ()<UIScrollViewDelegate>
@property (nonatomic,  weak) UIViewController *parentVC;
@property (nonatomic,strong) HeeeScrollPageHeaderView *headerView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,strong) NSMutableArray *didAddVCArray;
@property (nonatomic,assign) CGFloat offset;
@property (nonatomic,assign) int currentPage;

@end

@implementation HeeeScrollPageView
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
    
    if (self.pageVCArray.count > 0 && self.scrollView.subviews.count == 0) {
        [self setPageVCArray:self.pageVCArray];
    }
}
- (void)setPageVCArray:(NSArray<UIViewController *> *)pageVCArray {
    _pageVCArray = pageVCArray;
    
    if (self.frame.size.width > 0) {
        [self p_setupHomeTopView];
        [self p_setupScrollView];
        [self p_addChildVC:0];
    }
}

#pragma mark - private
- (void)p_setupInterface {
    self.headerBackgroundColor = [UIColor whiteColor];
    self.titleNormalColor = [UIColor lightGrayColor];
    self.titleSelectedColor = [UIColor blackColor];
    self.headerViewHeight = 36;
    self.titleZoomScale = 1.0;
    self.titleFontSize = 16;
    self.indicatorHeight = 1.0;
    self.indicatorColor = [UIColor blueColor];
    self.titleBottomViewLineColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.titleBottomViewLineHeight = 1.0;
    self.titleGap = 20;
    
    [self p_setupDisplayLink];
    [self addSubview:self.headerView];
    [self addSubview:self.scrollView];
}

- (void)p_setupDisplayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_findViewController)];
        _displayLink.paused = NO;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)p_addChildVC:(NSUInteger)index {
    if (self.parentVC && index < self.pageVCArray.count) {
        UIViewController *childVC = self.pageVCArray[index];
        if (![self.didAddVCArray containsObject:childVC]) {
            [self.parentVC addChildViewController:childVC];
            [self.didAddVCArray addObject:childVC];
        }
        
        [self.scrollView addSubview:childVC.view];
        childVC.view.frame = CGRectMake(index*self.bounds.size.width, 0, self.bounds.size.width, _scrollView.bounds.size.height);
    }
}

- (void)p_setupScrollView {
    self.scrollView.frame = CGRectMake(0, self.headerViewHeight, self.bounds.size.width, self.bounds.size.height - self.headerViewHeight);
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*self.pageVCArray.count, 0);
}

- (void)p_setupHomeTopView {
    self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, self.headerViewHeight);
    self.headerView.backgroundColor = self.headerBackgroundColor;
    self.headerView.spaceAround = self.spaceAround;
    self.headerView.titleNormalColor = self.titleNormalColor;
    self.headerView.titleSelectedColor = self.titleSelectedColor;
    self.headerView.titleZoomScale = self.titleZoomScale;
    self.headerView.titleFontSize = self.titleFontSize;
    self.headerView.titleGap = self.titleGap;
    self.headerView.indicatorHeight = self.indicatorHeight;
    self.headerView.indicatorColor = self.indicatorColor;
    self.headerView.indicatorBottomOffset = self.indicatorBottomOffset;
    self.headerView.strokeWidth = self.strokeWidth;
    self.headerView.titleBottomViewLineColor = self.titleBottomViewLineColor;
    self.headerView.titleBottomViewLineHeight = self.titleBottomViewLineHeight;
    self.headerView.titleBottomViewLineHorizonalMargin = self.titleBottomViewLineHorizonalMargin;
    
    NSMutableArray *titles = [NSMutableArray array];
    for (UIViewController *vc in self.pageVCArray) {
        [titles addObject:vc.title?vc.title:@""];
    }
    
    self.headerView.titles = titles;
}

- (void)p_findViewController {
    self.parentVC = [self p_viewController];
    if (self.parentVC) {
        [_displayLink invalidate];
        _displayLink = nil;
        
        [self p_addChildVC:0];
    }
}

- (UIViewController *)p_viewController {
    UIView *next = self;
    while ((next = [next superview])) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.headerView.scrollViewOffsetX = offsetX;
    
    int pageNumber = offsetX/scrollView.bounds.size.width;
    if (offsetX - pageNumber*scrollView.bounds.size.width == 0) {
        self.currentPage = pageNumber;
        
        UIViewController *vc = self.pageVCArray[pageNumber];
        [self p_addChildVC:pageNumber];
        
        for (UIView *view in scrollView.subviews) {
            if (view != vc.view) {
                [view removeFromSuperview];
            }
        }
    }else{
        if ([scrollView.subviews containsObject:self.pageVCArray[pageNumber].view]) {
            [self p_addChildVC:pageNumber + 1];
        }else{
            [self p_addChildVC:pageNumber];
        }
    }
}

#pragma mark - lazy
- (HeeeScrollPageHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[HeeeScrollPageHeaderView alloc] init];
        __weak typeof(self) weakSelf = self;
        _headerView.shouldScrollToPage = ^(NSUInteger pageIndex, BOOL animate) {
            [weakSelf.scrollView setContentOffset:CGPointMake(pageIndex*weakSelf.scrollView.bounds.size.width, 0) animated:animate];
        };
    }
    
    return _headerView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.clipsToBounds = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
    }
    
    return _scrollView;
}

- (NSMutableArray *)didAddVCArray {
    if (!_didAddVCArray) {
        _didAddVCArray = [NSMutableArray array];
    }
    
    return _didAddVCArray;
}

@end
