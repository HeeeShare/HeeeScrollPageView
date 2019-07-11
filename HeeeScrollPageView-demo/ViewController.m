//
//  ViewController.m
//  HeeeScrollPageView-demo
//
//  Created by hgy on 2018/10/28.
//  Copyright © 2018 hgy. All rights reserved.
//

#import "ViewController.h"
#import "HeeeScrollPageView.h"
#import "Page0ViewController.h"
#import "Page1ViewController.h"
#import "Page2ViewController.h"
#import "Page3ViewController.h"
#import "Page4ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) HeeeScrollPageView *scrollPageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Page0ViewController *page0 = [Page0ViewController new];
    Page1ViewController *page1 = [Page1ViewController new];
    Page2ViewController *page2 = [Page2ViewController new];
    Page3ViewController *page3 = [Page3ViewController new];
    Page4ViewController *page4 = [Page4ViewController new];
    self.scrollPageView.pageVCArray = @[page0,page1,page2,page3,page4];
    [self.view addSubview:self.scrollPageView];
}

- (HeeeScrollPageView *)scrollPageView {
    if (!_scrollPageView) {
        _scrollPageView = [[HeeeScrollPageView alloc] initWithFrame:CGRectMake(30, 80, 260, 500)];
        _scrollPageView.headerBackgroundColor = [UIColor cyanColor];
        _scrollPageView.headerViewHeight = 38;
        _scrollPageView.titleNormalColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        _scrollPageView.titleSelectedColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        _scrollPageView.titleZoomScale = 1.2;
        _scrollPageView.titleFontSize = 18;
        _scrollPageView.indicatorHeight = 2.0;
        _scrollPageView.indicatorColor = [UIColor redColor];
        _scrollPageView.strokeWidth = -2;
    }
    
    return _scrollPageView;
}

@end
