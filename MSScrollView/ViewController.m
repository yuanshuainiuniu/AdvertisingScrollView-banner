//
//  ViewController.m
//  MSScrollView
//
//  Created by GoBeta on 15/4/29.
//  Copyright (c) 2015年 Marshal. All rights reserved.
//

#import "ViewController.h"
#import "MSScrollView.h"
@interface ViewController ()<MSScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array = @[@"img_index_01bg",@"img_index_02bg",@"img_index_03bg"];
    MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:self.view.frame
                                                            images:array
                                                          delegate:self
                                                         direction:MSCycleDirectionHorizontal
                                                          autoPlay:YES
                                                             delay:4.0];
    [self.view addSubview:scrollView];
}
#pragma mark-
#pragma mark- MSScrollView Delegate
- (void)MSScrollView:(MSScrollView *)MSScrollView didSelectPage:(NSInteger)index{
    NSLog(@"%ld",(long)index);
}
- (void)MSScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
