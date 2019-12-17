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
    for (NSUInteger i = 0; i < 6; i++) {
        PageViewController *page = [PageViewController new];
        page.title = [NSString stringWithFormat:@"page%zd",i];
        [pageVCArray addObject:page];
    }
    
    self.scrollPageView.pageVCArray = [pageVCArray mutableCopy];
    [self.view addSubview:self.scrollPageView];
}

- (HeeeScrollPageView *)scrollPageView {
    if (!_scrollPageView) {
        _scrollPageView = [[HeeeScrollPageView alloc] initWithFrame:CGRectMake(30, 100, 300, 500)];
        _scrollPageView.headerBackgroundColor = [UIColor whiteColor];
        _scrollPageView.headerViewHeight = 60;
        _scrollPageView.titleNormalColor = [UIColor lightGrayColor];
        _scrollPageView.titleSelectedColor = [UIColor blackColor];
        _scrollPageView.titleZoomScale = 1.4;
        _scrollPageView.titleFontSize = 28;
        _scrollPageView.indicatorHeight = 2.0;
        _scrollPageView.indicatorColor = [UIColor redColor];
        _scrollPageView.strokeWidth = -2;
        
        _scrollPageView.layer.borderWidth = 0.5;
        _scrollPageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }
    
    return _scrollPageView;
}

@end
