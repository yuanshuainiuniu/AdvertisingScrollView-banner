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
//    NSArray *array = @[@"img_index_01bg",@"img_index_02bg",@"img_index_03bg",@"img_index_03bg",@"img_index_03bg"];
//    MSScrollView *scr = [[MSScrollView alloc] init];
//    scr.delegate = self;
//    scr.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
//    [self.view addSubview:scr];
//    scr.autoPlay = YES;
//    scr.timeInterval = 5;
//    scr.images = [NSMutableArray arrayWithArray:array];
    
//    MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:self.view.frame
//                                                            images:array
//                                                          delegate:self
//                                                         direction:MSCycleDirectionHorizontal
//                                                          autoPlay:YES
//                                                             delay:2.0];
//    [self.view addSubview:scrollView];
    
    NSArray *array = @[@"http://b.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3ce5254cb2e9045d688d43f2012.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/f31fbe096b63f624d7f185648544ebf81a4ca32d.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/7a899e510fb30f241e175064ca95d143ac4b03c3.jpg",
                       @"xxx",
                       @"http://b.hiphotos.baidu.com/image/w%3D230/sign=c3c1b560738b4710ce2ffacff3cfc3b2/83025aafa40f4bfb828dd315024f78f0f7361815.jpg",
                       @"http://e.hiphotos.baidu.com/image/pic/item/7a899e510fb30f241e175064ca95d143ac4b0e3c3.jpg",
                       ];
    MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:self.view.bounds imageUrls:array placeholderImage:nil delegate:self direction:0 autoPlay:YES delay:2.0];
    [self.view addSubview:scrollView];
    
   
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
