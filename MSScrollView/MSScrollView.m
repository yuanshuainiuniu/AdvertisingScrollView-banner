//
//  MSScrollView.m
//  MSScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//

#import "MSScrollView.h"
#define kPageHeight 30
@interface MSScrollView(){
    UIScrollView    *_scrollView;
    UIPageControl   *_pageControl;
    int _currentPage;
}
@property (nonatomic, strong) NSTimer *AutoTimer;
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *threeImageView;
@end

@implementation MSScrollView

- (UIImageView *)firstImageView{
    if (!_firstImageView) {
        _firstImageView = [[UIImageView alloc] init];
    }
    return _firstImageView;
}
- (UIImageView *)secondImageView{
    if (!_secondImageView) {
        _secondImageView = [[UIImageView alloc] init];
    }
    return _secondImageView;
}
- (UIImageView *)threeImageView{
    if (!_threeImageView) {
        _threeImageView = [[UIImageView alloc] init];
    }
    return _threeImageView;
}
- (id)initWithFrame:(CGRect)frame images:(NSArray *)images delegate:(id<MSScrollViewDelegate>)delegate direction:(MSCycleDirection)direction autoPlay:(BOOL)autoPlay delay:(CGFloat)timeInterval{
    if (self      = [super initWithFrame:frame]) {
    _direction    = direction;
    _isAutoPlay   = autoPlay;
    _timeInterval = timeInterval;
    _delegate     = delegate;
    _currentPage = 0;
        [self initImages:images];
        [self addScrollView];
        [self addPageControl];
        [self reloadData];

    }
    return self;
}
#pragma mark- 
#pragma markPrivate methods
/* 设置图片 */
- (void)initImages:(NSArray *)images{
    _images = [NSMutableArray arrayWithCapacity:images.count];
    for (NSString *imageName in images) {
        [_images addObject:[UIImage imageNamed:imageName]];
    }
}
- (void)addScrollView{
    _scrollView                                = [[UIScrollView alloc] initWithFrame:self.bounds];
    if (self.direction == MSCycleDirectionHorizontal) {
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    }else{
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);
    }
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate                       = self;
    _scrollView.pagingEnabled                  = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;
    _scrollView.scrollsToTop                   = NO;
    _scrollView.bounces = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired    = 1;
    tapGestureRecognizer.delegate                = self;
    [_scrollView addGestureRecognizer:tapGestureRecognizer];

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
 *  添加pagcontrol
 */
- (void)addPageControl{
    _pageControl                               = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kPageHeight, self.frame.size.width, kPageHeight)];
    _pageControl.numberOfPages                 = self.images.count;
    _pageControl.pageIndicatorTintColor        = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
    _pageControl.userInteractionEnabled        = NO;
    [self addSubview:_pageControl];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(MSScrollViewDidScroll:)]) {
        [self.delegate MSScrollViewDidScroll:_scrollView];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (self.direction == MSCycleDirectionHorizontal) {
        float x = _scrollView.contentOffset.x;

        //往前翻
        if (x<=0 ) {
            if (_currentPage-1<0) {
                _currentPage = (int)self.images.count-1;
            }else{
                _currentPage --;
            }
        }
        
        //往后翻
        if (x>=self.frame.size.width*2 ) {
            if (_currentPage==self.images.count-1) {
                _currentPage = 0;
            }else{
                _currentPage ++;
            }
        }
    }else{
        float y = _scrollView.contentOffset.y;
        //up
        if (y>self.frame.size.height ) {
            
            if (_currentPage==self.images.count-1) {
                _currentPage = 0;
            }else{
                _currentPage ++;
            }
        }
        //down
        if (y<self.frame.size.height) {
            if (_currentPage-1<0) {
                _currentPage = (int)self.images.count-1;
            }else{
                _currentPage --;
            }
        }
    }
    [self reloadData];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_isAutoPlay) {
        [self addTimer];
    }
}
- (void)addTimer{
    [self removeTimer];
    self.AutoTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(autoShowNextImage) userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.AutoTimer forMode:NSRunLoopCommonModes];

}
- (void)removeTimer{
    [self.AutoTimer invalidate];
    self.AutoTimer = nil;
}
-(void)dealloc{
    [self removeTimer];
}

-(void)reloadData
{
    if (_currentPage==0) {
        NSLog(@"----第一页");
        self.firstImageView.image = [self.images lastObject];
        self.secondImageView.image = self.images[_currentPage];
        self.threeImageView.image = self.images[_currentPage+1];
    }
    else if (_currentPage == self.images.count-1)
    {
        NSLog(@"----最后一页");
        self.firstImageView.image = self.images[_currentPage-1];
        self.secondImageView.image = self.images[_currentPage];
        self.threeImageView.image = [self.images firstObject];
    }
    else
    {
        NSLog(@"----");
        self.firstImageView.image = self.images[_currentPage-1];
        self.secondImageView.image = self.images[_currentPage];
        self.threeImageView.image = self.images[_currentPage+1];
    }
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    [_scrollView addSubview:self.firstImageView];
    [_scrollView addSubview:self.secondImageView];
    [_scrollView addSubview:self.threeImageView];
    
    _pageControl.currentPage = _currentPage;
    
    if(self.direction == MSCycleDirectionHorizontal){
        self.firstImageView.frame = self.frame;
        self.secondImageView.frame = CGRectMake(width, 0, width, height);
        self.threeImageView.frame = CGRectMake(width*2, 0, width, height);
        _scrollView.contentOffset = CGPointMake(width, 0);
    }else{
        self.firstImageView.frame = self.frame;
        self.secondImageView.frame = CGRectMake(0, height, width, height);
        self.threeImageView.frame = CGRectMake(0, height*2, width, height);
        _scrollView.contentOffset = CGPointMake(0, height);
    }
}


#pragma mark 展示下一页
-(void)autoShowNextImage
{
    if (_currentPage == self.images.count-1) {
        _currentPage = 0;
    }else{
        _currentPage ++;
    }
    
    [self reloadData];
}

@end
