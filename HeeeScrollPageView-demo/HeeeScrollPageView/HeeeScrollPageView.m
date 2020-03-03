//
//  HeeeScrollPageView.m
//  ceshi010
//
//  Created by Heee on 2019/7/5.
//  Copyright © 2019 WeInsight. All rights reserved.
//

#import "HeeeScrollPageView.h"
#import "HeeeScrollPageTitleView.h"

@interface HeeeScrollPageView ()<UIScrollViewDelegate>
@property (nonatomic,  weak) UIViewController *parentVC;
@property (nonatomic,strong) HeeeScrollPageTitleView *titleView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,strong) NSMutableArray *didAddVCArray;
@property (nonatomic,assign) CGFloat offset;
@property (nonatomic,assign) NSUInteger currentPage;
@property (nonatomic,strong) NSMutableArray <NSString *>*offsetYArray;
@property (nonatomic,strong) UIView *snapShotView;
@property (nonatomic,assign) NSInteger clickTitleIndex;

@end

@implementation HeeeScrollPageView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self p_setupSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupSubView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.VCArray.count > 0 && self.scrollView.subviews.count == 0) {
        [self setVCArray:self.VCArray];
    }
}

- (void)setVCArray:(NSArray<UIViewController *> *)VCArray {
    _VCArray = VCArray;
    
    if (self.frame.size.width > 0) {
        [self p_setupTitleView];
        [self p_setupScrollView];
        [self p_addChildVC:0];
        
        for (NSUInteger i = 0; i < self.VCArray.count; i++) {
            [self.offsetYArray addObject:@"0"];
        }
    }
}

- (void)pageViewControllerDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.mj_header.isRefreshing || scrollView.mj_footer.isRefreshing) {
//        return;
//    }
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (self.scrollView.contentOffset.x - self.currentPage*self.scrollView.bounds.size.width == 0) {
        self.offsetYArray[self.currentPage] = [NSString stringWithFormat:@"%f",offsetY];
    }
    
    if (self.offset >= self.titleMaxHeight - self.titleMiniHeight) {
        self.offset = self.titleMaxHeight - self.titleMiniHeight;
    }else if(self.offset <= 0) {
        self.offset = 0;
    }else{
//        [scrollView setContentOffset:CGPointMake(0, scrollView.mj_header.isRefreshing?-scrollView.mj_header.height:0)];
    }
    
    self.titleView.frame = CGRectMake(0, 0, self.bounds.size.width, self.titleMaxHeight - self.offset);
    self.scrollView.frame = CGRectMake(0, self.titleView.frame.origin.y + self.titleView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - self.titleMiniHeight);
    self.titleView.scrollViewOffsetY = self.offset;
    self.offset += offsetY;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageView:titleViewDidChangeHeight:)]) {
        [self.delegate scrollPageView:self titleViewDidChangeHeight:self.titleView.bounds.size.height];
    }
}

- (void)foldTitleViewUncondition:(BOOL)uncondition {
    CGFloat offsetY = self.offsetYArray[self.currentPage].floatValue;
    if (uncondition || offsetY > self.titleMaxHeight - self.titleMiniHeight) {
        self.offset = self.titleMaxHeight - self.titleMiniHeight;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.titleView.frame = CGRectMake(0, 0, self.bounds.size.width, self.titleMiniHeight);
            self.scrollView.frame = CGRectMake(0, self.titleView.frame.origin.y + self.titleView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - self.titleView.bounds.size.height);
            self.titleView.scrollViewOffsetY = self.titleMaxHeight - self.titleMiniHeight;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageView:titleViewDidChangeHeight:)]) {
                [self.delegate scrollPageView:self titleViewDidChangeHeight:self.titleView.bounds.size.height];
            }
        }];
    }
}

- (void)unfoldTitleView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            self.titleView.frame = CGRectMake(0, 0, self.bounds.size.width, self.titleMaxHeight);
            self.scrollView.frame = CGRectMake(0, self.titleView.frame.origin.y + self.titleView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - self.titleView.bounds.size.height);
            self.titleView.scrollViewOffsetY = 0;
            self.offset = 0;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageView:titleViewDidChangeHeight:)]) {
                [self.delegate scrollPageView:self titleViewDidChangeHeight:self.titleView.bounds.size.height];
            }
        }];
    });
}

#pragma mark - private
- (void)p_setupSubView {
    self.titleViewBackgroundColor = [UIColor whiteColor];
    self.titleNormalColor = [UIColor lightGrayColor];
    self.titleSelectedColor = [UIColor blackColor];
    self.titleFontSize = 18;
    self.titleZoomScale = 1.0;
    self.titleMaxHeight = 36;
    self.titleMiniHeight = 36;
    self.indicatorColor = [UIColor grayColor];
    self.indicatorHeight = 1.0;
    self.titleVerticalCenter = YES;
    self.titleVerticalOffset = 0;
    self.titleHorizontalGap = 20;
    self.titleBottomLineHeight = 1;
    self.titleBottomLineColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.titleBottomLineMargin = 0;
    
    self.clickTitleIndex = -1;
    [self p_setupDisplayLink];
    [self addSubview:self.titleView];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.snapShotView];
}

- (void)p_setupDisplayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_findViewController)];
        _displayLink.paused = NO;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)p_addChildVC:(NSUInteger)index {
    if (self.parentVC && index < self.VCArray.count) {
        UIViewController *childVC = self.VCArray[index];
        if (![self.didAddVCArray containsObject:childVC]) {
            [self.parentVC addChildViewController:childVC];
            [self.didAddVCArray addObject:childVC];
        }
        
        if (childVC.view.superview!=self.scrollView) {
            [self.scrollView addSubview:childVC.view];
            [[self.snapShotView viewWithTag:100+index] removeFromSuperview];
        }
        childVC.view.frame = CGRectMake(index*self.bounds.size.width, 0, self.bounds.size.width, _scrollView.bounds.size.height);
    }
}

- (void)p_setupScrollView {
    self.scrollView.frame = CGRectMake(0, self.titleView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - self.titleMiniHeight);
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*self.VCArray.count, 0);
    self.snapShotView.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.bounds.size.height);
}

- (void)p_setupTitleView {
    self.titleView.backgroundColor = self.titleViewBackgroundColor;
    self.titleView.spaceAround = self.spaceAround;
    self.titleView.titleNormalColor = self.titleNormalColor;
    self.titleView.titleSelectedColor = self.titleSelectedColor;
    self.titleView.maxHeight = self.titleMaxHeight;
    self.titleView.miniHeight = self.titleMiniHeight;
    self.titleView.titleZoomScale = self.titleZoomScale;
    self.titleView.titleFontSize = self.titleFontSize;
    self.titleView.indicatorHeight = self.indicatorHeight;
    self.titleView.indicatorWidth = self.indicatorWidth;
    self.titleView.indicatorCornerRadius = self.indicatorCornerRadius;
    self.titleView.indicatorColor = self.indicatorColor;
    self.titleView.indicatorVerticalOffset = self.indicatorVerticalOffset;
    self.titleView.titleVerticalCenter = self.titleVerticalCenter;
    self.titleView.titleVerticalOffset = self.titleVerticalOffset;
    self.titleView.titleHorizontalGap = self.titleHorizontalGap;
    self.titleView.titleBottomLineHeight = self.titleBottomLineHeight;
    self.titleView.titleBottomLineColor = self.titleBottomLineColor;
    self.titleView.titleBottomLineMargin = self.titleBottomLineMargin;
    self.titleView.strokeWidth = self.strokeWidth;
    self.titleView.titleRightGap = self.titleRightGap;
    self.titleView.frame = CGRectMake(0, 0, self.bounds.size.width, self.titleMaxHeight);
    
    NSMutableArray *titles = [NSMutableArray array];
    for (UIViewController *vc in self.VCArray) {
        [titles addObject:vc.title?vc.title:@""];
    }
    
    self.titleView.titles = titles;
    self.titleView.scrollViewOffsetY = 0;
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
    self.titleView.scrollViewOffsetX = offsetX;
    
    NSUInteger pageNumber = offsetX/scrollView.bounds.size.width;
    if (offsetX - pageNumber*scrollView.bounds.size.width == 0) {
        if (self.clickTitleIndex!=-1 && pageNumber != self.clickTitleIndex) return;
        self.clickTitleIndex = -1;
        self.currentPage = pageNumber;
        
        UIViewController *vc = self.VCArray[pageNumber];
        [self p_addChildVC:pageNumber];
        
        for (UIView *view in scrollView.subviews) {
            if (view != vc.view && view != self.snapShotView) {
                NSUInteger index = view.frame.origin.x/self.bounds.size.width;
                [[self.snapShotView viewWithTag:index + 100] removeFromSuperview];
                UIView *shotView = [view snapshotViewAfterScreenUpdates:NO];
                shotView.tag = index + 100;
                shotView.frame = CGRectMake(index*self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
                [self.snapShotView addSubview:shotView];
                [view removeFromSuperview];
            }
        }
        
        CGFloat offsetY = self.offsetYArray[self.currentPage].floatValue;
        BOOL isTop = offsetY > self.titleMaxHeight - self.titleMiniHeight;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollPageView:didScrollToIndex:isTop:)]) {
            [self.delegate scrollPageView:self didScrollToIndex:self.currentPage isTop:isTop];
        }
        
        [self foldTitleViewUncondition:NO];
    }else if (scrollView.tracking) {
        self.clickTitleIndex = -1;
        if ([scrollView.subviews containsObject:self.VCArray[pageNumber].view]) {
            [self p_addChildVC:pageNumber + 1];
        }else{
            [self p_addChildVC:pageNumber];
        }
    }
}

#pragma mark - lazy
- (HeeeScrollPageTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[HeeeScrollPageTitleView alloc] init];
        if (self.titleViewBackgroundColor) {
            _titleView.backgroundColor = self.titleViewBackgroundColor;
        }
        
        __weak typeof(self) weakSelf = self;
        _titleView.shouldScrollToPage = ^(NSUInteger pageIndex) {
            weakSelf.clickTitleIndex = pageIndex;
            [weakSelf.scrollView setContentOffset:CGPointMake(pageIndex*weakSelf.scrollView.bounds.size.width, 0) animated:YES];
        };
    }
    
    return _titleView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.pagingEnabled = YES;
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

- (NSMutableArray<NSString *> *)offsetYArray {
    if (!_offsetYArray) {
        _offsetYArray = [NSMutableArray array];
    }
    
    return _offsetYArray;
}

- (UIView *)snapShotView {
    if (!_snapShotView) {
        _snapShotView = [[UIView alloc] init];
    }
    
    return _snapShotView;
}

@end
