//
//  MSScrollView.m
//  LoopScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//

#import "MSScrollView.h"
#define kPageHeight 30
@interface MSScrollView(){
    UIScrollView    *_scrollView;
    UIPageControl   *_pageControl;
}
@property (nonatomic, strong) NSTimer *AutoTimer;

@end

@implementation MSScrollView
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images delegate:(id<MSScrollViewDelegate>)delegate direction:(MSCycleDirection)direction autoPlay:(BOOL)autoPlay delay:(CGFloat)timeInterval{
    if (self      = [super initWithFrame:frame]) {
    _direction    = direction;
    _isAutoPlay   = autoPlay;
    _timeInterval = timeInterval;
    _delegate     = delegate;

        [self initImages:images];
        [self addScrollView];
        [self addPageControl];
    }
    return self;
}
#pragma mark - 
#pragma mark Private methods
/* 设置图片 */
- (void)initImages:(NSArray *)images{
    _images = [NSMutableArray array];
    [_images addObject:[images lastObject]];
    for (NSString *imageName in images) {
        [_images addObject:imageName];
    }
    [_images addObject:[images firstObject]];
}
- (void)addScrollView{
    _scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate                       = self;
    _scrollView.pagingEnabled                  = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.scrollsToTop                   = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired    = 1;
    tapGestureRecognizer.delegate                = self;
    [_scrollView addGestureRecognizer:tapGestureRecognizer];

    NSInteger count                              = _images.count;
    CGFloat width                                = self.frame.size.width;
    CGFloat height                               = self.frame.size.height;
    
    // add imageView;
    if (self.direction == MSCycleDirectionHorizontal) {
        CGSize size               = CGSizeMake(width * count, height);
        _scrollView.contentSize   = size;
        _scrollView.contentOffset = CGPointMake(width, 0);
        for (int i                = 0; i < count; i++) {
        UIImageView *imageView    = [[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        UIImage *image            = [UIImage imageNamed:self.images[i]];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.image           = image;
            [_scrollView addSubview:imageView];
        }
    }/* 水平滚动 */
    else if (self.direction == MSCycleDirectionVertical){
        CGSize size               = CGSizeMake(width, height * count);
        _scrollView.contentSize   = size;
        _scrollView.contentOffset = CGPointMake(0, height);
        for (int i                = 0; i < count; i++) {
        UIImageView *imageView    = [[UIImageView alloc] initWithFrame:CGRectMake(0, height * i, width, height)];
        UIImage *image            = [UIImage imageNamed:self.images[i]];
        imageView.image           = image;
        imageView.backgroundColor = [UIColor lightGrayColor];
            [_scrollView addSubview:imageView];
        }
    }/* 垂直滚动 */
    else{
        NSLog(@"滚动方向未设置");
    }
    [self addSubview:_scrollView];
    if (_isAutoPlay) {
        [self addTimer];
    }
    
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    if ([self.delegate respondsToSelector:@selector(MSScrollView:didSelectPage:)]) {
        [self.delegate MSScrollView:self didSelectPage:_pageControl.currentPage];
    }
}
/**
 *  下一页
 */
- (void)autoScrollToNextPage{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollToNextPage) object:nil];

    CGFloat targetX = _scrollView.contentOffset.x + self.frame.size.width;
    CGFloat targetY = _scrollView.contentOffset.y + self.frame.size.height;
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    if (self.direction == MSCycleDirectionHorizontal) {
        [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }
    if (self.direction == MSCycleDirectionVertical) {
        [_scrollView setContentOffset:CGPointMake(0, targetY) animated:YES];
    }
}
/**
 *  上一页
 */
- (void)autoScrollToFrontPage{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScrollToFrontPage) object:nil];

    CGFloat targetX = _scrollView.contentOffset.x - self.frame.size.width;
    CGFloat targetY = _scrollView.contentOffset.y - self.frame.size.height;
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    if (self.direction == MSCycleDirectionHorizontal) {
        [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }
    if (self.direction == MSCycleDirectionVertical) {
        [_scrollView setContentOffset:CGPointMake(0, targetY) animated:YES];
    }
}
/**
 *  添加pagcontrol
 */
- (void)addPageControl{
    _pageControl                               = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kPageHeight, self.frame.size.width, kPageHeight)];
    _pageControl.numberOfPages                 = self.images.count - 2;
    _pageControl.pageIndicatorTintColor        = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
    _pageControl.userInteractionEnabled        = NO;
    [self addSubview:_pageControl];
}
#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat targetX = scrollView.contentOffset.x;
    CGFloat targetY = scrollView.contentOffset.y;
    CGFloat width   = self.frame.size.width;
    CGFloat height  = self.frame.size.height;
    NSInteger count = self.images.count;
    if (count >= 3) {
        if (self.direction == MSCycleDirectionHorizontal) {
            if (targetX >= width * (count - 1)) {
            targetX                  = width;
                [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
            }
            if (targetX <= 0) {
            targetX                  = width * (count - 2);
                [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
            }
            _pageControl.currentPage = (targetX / width - 1);
        } /* 水平滚动 */
        else if(self.direction == MSCycleDirectionVertical){
            if (targetY >= height * (count - 1)) {
            targetY                  = height;
                [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
            }
            if (targetY <= 0) {
            targetY                  = height * (count - 2);
                [_scrollView setContentOffset:CGPointMake(0, targetY) animated:NO];
            }
            _pageControl.currentPage = targetY / height - 1;
            
        } /* 垂直滚动 */
        else{
            NSLog(@"滚动方向未设置");
        }
    }
    if ([self.delegate respondsToSelector:@selector(MSScrollViewDidScroll:)]) {
        [self.delegate MSScrollViewDidScroll:_scrollView];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}
- (void)addTimer{
    [self removeTimer];
    self.AutoTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(autoScrollToNextPage) userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.AutoTimer forMode:NSRunLoopCommonModes];

}
- (void)removeTimer{
    [self.AutoTimer invalidate];
    self.AutoTimer = nil;
}
-(void)dealloc{
    [self removeTimer];
}
@end
