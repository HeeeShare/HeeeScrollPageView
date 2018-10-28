//
//  ViewController.m
//  HeeeScrollPageView-demo
//
//  Created by hgy on 2018/10/28.
//  Copyright © 2018 hgy. All rights reserved.
//

#import "ViewController.h"
#import "HeeeScrollPageView.h"
#import "ColorViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSMutableArray *vcArr = [NSMutableArray array];
    for (NSUInteger i = 0; i < 6; i++) {
        ColorViewController *vc = [ColorViewController new];
        
        if (i == 0) {
            vc.color = [UIColor redColor];
            vc.title = @"red";
        }
        
        if (i == 1) {
            vc.color = [UIColor yellowColor];
            vc.title = @"yellow";
        }
        
        if (i == 2) {
            vc.color = [UIColor greenColor];
            vc.title = @"green";
        }
        
        if (i == 3) {
            vc.color = [UIColor blueColor];
            vc.title = @"blue";
        }
        
        if (i == 4) {
            vc.color = [UIColor cyanColor];
            vc.title = @"cyan";
        }
        
        if (i == 5) {
            vc.color = [UIColor orangeColor];
            vc.title = @"orange";
        }
        
        [vcArr addObject:vc];
    }
    
    HeeeScrollPageView *pageView = [[HeeeScrollPageView alloc] initWithFrame:CGRectMake(20, 60, 280, 500) childVC:vcArr andIndicatorHeight:36];
    [self.view addSubview:pageView];
}
@end
