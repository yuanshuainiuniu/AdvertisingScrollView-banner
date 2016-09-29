//
//  MSScrollView.h
//  MSScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "CustomerPageControl.h"

@class MSScrollView;

typedef enum{
    MSCycleDirectionHorizontal = 0,
    MSCycleDirectionVertical
} MSCycleDirection;

typedef NS_ENUM(NSInteger, MSPageControlDirection) {
    MSPageControl_Center = 0,
    MSPageControl_Left,
    MSPageControl_Right,
};

@protocol MSScrollViewDelegate <NSObject>

@optional
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

/**
 pageControl偏移量
 */
@property (nonatomic, assign) UIOffset pageControlOffset;
/**
 *  delegate
 */
@property (nonatomic,weak) id<MSScrollViewDelegate> delegate;
/**
 *  时间间隔
 */
@property (nonatomic,assign) CGFloat timeInterval;
/**
 *  是否要自动播放
 */
@property (nonatomic,assign,getter=isAutoPlay) BOOL autoPlay;
/**
 *  需要播放的图片名
 */
@property (nonatomic,copy) NSMutableArray *images;
/**
 *  需要播放的网络图片
 */
@property (nonatomic,copy) NSMutableArray *urlImages;
/**
 *  滚动方向(上下,左右)
 */
@property (nonatomic,assign) MSCycleDirection direction;

/**
 pageControl方向
 */
@property (nonatomic, assign) MSPageControlDirection pageControlDir;

/**
 自定义pagControl
 */
@property (nonatomic, strong) CustomerPageControl   *pageControl;

/**
 图片的填充方式
 */
@property (nonatomic, assign) UIViewContentMode *contentModel;

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

/**
 *  支持网络图片
 */
- (id)initWithFrame:(CGRect)frame imageUrls:(NSArray *)imageUrls placeholderImage:(NSString *)placeholderImage delegate:(id<MSScrollViewDelegate>)delegate direction:(MSCycleDirection)direction autoPlay:(BOOL)autoPlay delay:(CGFloat)timeInterval;

/**
 占位图
 */
@property (nonatomic, copy) NSString *placeholderImage;
/**
 *  @author Marshal, 16-01-07 17:01:19
 *
 *  @brief 清除缓存
 */
- (void)clearCache;
@end
