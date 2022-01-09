//
//  ViewController.m
//  HeeeScrollPageView-demo
//
//  Created by hgy on 2018/10/28.
//  Copyright © 2018 hgy. All rights reserved.
//

#import "ViewController.h"
#import "HeeeScrollPageView.h"
#import "PageViewController.h"

@interface ViewController ()
@property (nonatomic,strong) HeeeScrollPageView *scrollPageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *pageVCArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < 4; i++) {
        PageViewController *page = [PageViewController new];
        page.title = [NSString stringWithFormat:@"page%zd",i];
        [pageVCArray addObject:page];
    }
    
    self.scrollPageView.VCArray = [pageVCArray mutableCopy];
    [self.view addSubview:self.scrollPageView];
}

- (HeeeScrollPageView *)scrollPageView {
    if (!_scrollPageView) {
        _scrollPageView = [[HeeeScrollPageView alloc] init];
        _scrollPageView.frame = CGRectMake(30, 100, 300, 500);
        _scrollPageView.titleViewBackgroundColor = [UIColor whiteColor];
        _scrollPageView.titleMiniHeight = 40;
        _scrollPageView.titleMaxHeight = 40;
        _scrollPageView.titleNormalColor = [UIColor lightGrayColor];
        _scrollPageView.titleSelectedColor = [UIColor blackColor];
        _scrollPageView.titleZoomScale = 1.0;
        _scrollPageView.titleFontSize = 18;
        _scrollPageView.indicatorWidth = 32;
        _scrollPageView.indicatorHeight = 3.0;
        _scrollPageView.indicatorCornerRadius = 1.5;
        _scrollPageView.indicatorColor = [UIColor redColor];
        _scrollPageView.strokeWidth = -3;
        _scrollPageView.defaultPage = 2;
        _scrollPageView.titleLeftGap = 16;
        
        _scrollPageView.layer.borderWidth = 0.5;
        _scrollPageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }
    
    return _scrollPageView;
}

@end
