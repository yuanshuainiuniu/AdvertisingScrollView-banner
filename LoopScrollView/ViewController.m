//
//  ViewController.m
//  LoopScrollView
//
//  Created by Mark on 3/18/15.
//  Copyright (c) 2015 yq. All rights reserved.
//

#import "ViewController.h"
#import "MSScrollView.h"
@interface ViewController ()<MSScrollViewDelegate>

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *array = @[@"1.jpg",@"2.jpg",@"3.jpg",@"2.jpg",@"1.jpg"];
    CGRect frame = CGRectMake(0, 100, self.view.frame.size.width, 150);
    MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:frame
                                                            images:array
                                                          delegate:self
                                                         direction:MSCycleDirectionHorizontal
                                                          autoPlay:YES
                                                             delay:4.0];
    [self.view addSubview:scrollView];
}
#pragma mark -
#pragma mark - MSScrollView Delegate
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
