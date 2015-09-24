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
    NSArray *array = @[@"img_index_01bg",@"img_index_02bg",@"img_index_03bg",@"img_index_03bg",@"img_index_03bg"];
    MSScrollView *scr = [[MSScrollView alloc] init];
    scr.delegate = self;
    scr.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.view addSubview:scr];
    scr.autoPlay = NO;
    scr.timeInterval = 5;
    scr.images = [NSMutableArray arrayWithArray:array];
    
//    MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:self.view.frame
//                                                            images:array
//                                                          delegate:self
//                                                         direction:MSCycleDirectionHorizontal
//                                                          autoPlay:YES
//                                                             delay:2.0];
//    [self.view addSubview:scrollView];
//   
    
   
}
#pragma mark-
#pragma mark- MSScrollView Delegate
- (void)MSScrollView:(MSScrollView *)MSScrollView didSelectPage:(NSInteger)index{
    NSLog(@"%ld",(long)index);
}
- (void)MSScrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"contentOffset=%f",scrollView.contentOffset.x);
}

@end
