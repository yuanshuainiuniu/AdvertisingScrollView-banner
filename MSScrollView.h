//
//  MSScrollView.h
//  LoopScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//
//

#import <UIKit/UIKit.h>
@class MSScrollView;
typedef enum{
    MSCycleDirectionVertical,
    MSCycleDirectionHorizontal
} MSCycleDirection;

@protocol MSScrollViewDelegate <NSObject>
/**
 *  代理方法,点击返回图片的序号,
 *  可用于判断用户点击的图片号,进行图片的跳转等操作
 *
 *  @param MSScrollView MSScrollView实例
 *  @param index        图片序号
 */
- (void)MSScrollView:(MSScrollView *)MSScrollView didSelectPage:(NSInteger)index;
/**
 *  代理方法, 通过该代理方法,可时时得知scrollView的滚动
 *
 */
- (void)MSScrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface MSScrollView : UIView <UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) id<MSScrollViewDelegate> delegate;
@property (nonatomic,assign) CGFloat timeInterval;
@property (nonatomic,assign) BOOL isAutoPlay;
@property (nonatomic,strong) NSMutableArray *images;
@property (nonatomic,assign) MSCycleDirection direction;
/**
 *  构造方法
 *
 *  @param frame        设置MSScrollView的frame属性
 *  @param images       图片数组，内为图片名
 *  @param delegate     设置代理
 *  @param direction    MSScrollView的滚动方向，分垂直和水平
 *  @param autoPlay     是否自动滚动
 *  @param timeInterval 若自动滚动，设置时间间隔
 *
 *  @return self
 */
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images delegate:(id<MSScrollViewDelegate>)delegate direction:(MSCycleDirection)direction autoPlay:(BOOL)autoPlay delay:(CGFloat)timeInterval;
@end
