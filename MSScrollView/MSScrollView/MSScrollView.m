//
//  MSScrollView.m
//  MSScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//

#import "MSScrollView.h"
#import "SDWebImageManager.h"
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
    _autoPlay   = autoPlay;
    _timeInterval = timeInterval;
    _delegate     = delegate;
    [self initImages:images fromUrl:NO];
    
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame imageUrls:(NSArray *)imageUrls placeholderImage:(NSString *)placeholderImage delegate:(id<MSScrollViewDelegate>)delegate direction:(MSCycleDirection)direction autoPlay:(BOOL)autoPlay delay:(CGFloat)timeInterval{
    if (self      = [super initWithFrame:frame]) {
        _direction    = direction;
        _autoPlay   = autoPlay;
        _timeInterval = timeInterval;
        _delegate     = delegate;
        _placeholderImage = placeholderImage;
        [self initImages:imageUrls fromUrl:YES];
        [self commoninit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commoninit];
    }
    return self;
}
- (void)commoninit{
    _currentPage = 0;
    [self addScrollView];
    [self addPageControl];
    [self reloadData];
}
- (void)setTimeInterval:(CGFloat)timeInterval{
    _timeInterval = timeInterval;
    [self commoninit];
}
- (void)setDirection:(MSCycleDirection)direction{
    _direction = direction;
    [self commoninit];
}
- (void)setAutoPlay:(BOOL)autoPlay{
    _autoPlay = autoPlay;
    [self commoninit];
}
- (void)setImages:(NSMutableArray *)images{
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:images.count];
    [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *image = [UIImage imageNamed:(NSString *)obj];
        [tempArr addObject:image];
    }];
    _images = [tempArr copy];
    [self commoninit];
}
#pragma mark-
#pragma markPrivate methods
/* 设置图片 */
- (void)initImages:(NSArray *)images fromUrl:(BOOL)fromUrl{
    _images = [NSMutableArray arrayWithCapacity:images.count];

    if (fromUrl) {
        [images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:(NSString *)obj] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished)
                {
                    [_images addObject:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self commoninit];
                    });
                }else{
                    [_images addObject:[UIImage imageNamed:(_placeholderImage == nil?@"MSSource.bundle/def.jpg":_placeholderImage)]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self commoninit];
                    });
                }
            }];
        
        }];
        
    }else{
        for (NSString *imageName in images) {
            [_images addObject:[UIImage imageNamed:imageName]];
        }
    }
}

static UITapGestureRecognizer *tapGestureRecognizer;
- (void)addScrollView{
    if (_scrollView == nil) {
        _scrollView                                = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.delegate                       = self;
        _scrollView.pagingEnabled                  = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.scrollsToTop                   = NO;
        _scrollView.bounces = NO;
    }
    _scrollView.frame = self.bounds;
    if (self.direction == MSCycleDirectionHorizontal) {
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    }else{
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);
    }
   
    if (tapGestureRecognizer == nil) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
        tapGestureRecognizer.numberOfTapsRequired    = 1;
        tapGestureRecognizer.delegate                = self;
    }
    [_scrollView addGestureRecognizer:tapGestureRecognizer];

    [self addSubview:_scrollView];
    if (self.isAutoPlay) {
        [self addTimer];
    }else{
        [self removeTimer];
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
    if (_pageControl == nil) {
        _pageControl                               = [[UIPageControl alloc] init];
        _pageControl.pageIndicatorTintColor        = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
        _pageControl.userInteractionEnabled        = NO;
    }
   _pageControl.frame = CGRectMake(0, self.frame.size.height - kPageHeight, self.frame.size.width, kPageHeight);
    _pageControl.numberOfPages                 = _images.count;
    
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
                _currentPage = (int)_images.count-1;
            }else{
                _currentPage --;
            }
        }
        
        //往后翻
        if (x>=self.frame.size.width*2 ) {
            if (_currentPage==_images.count-1) {
                _currentPage = 0;
            }else{
                _currentPage ++;
            }
        }
    }else{
        float y = _scrollView.contentOffset.y;
        //up
        if (y>self.frame.size.height ) {
            
            if (_currentPage==_images.count-1) {
                _currentPage = 0;
            }else{
                _currentPage ++;
            }
        }
        //down
        if (y<self.frame.size.height) {
            if (_currentPage-1<0) {
                _currentPage = (int)_images.count-1;
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
    if (self.isAutoPlay) {
        [self addTimer];
    }
}
- (void)addTimer{
    [self removeTimer];
    self.AutoTimer = [NSTimer scheduledTimerWithTimeInterval:(_timeInterval>0?_timeInterval:2.5) target:self selector:@selector(autoShowNextImage) userInfo:nil repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.AutoTimer forMode:NSRunLoopCommonModes];

}
- (void)removeTimer{
    
    if (_AutoTimer != nil) {
        [_AutoTimer invalidate];
        _AutoTimer = nil;
    }
}
-(void)dealloc{
    [self removeTimer];
}

-(void)reloadData
{
    if (_images.count<3) {
        return;
    }
    if (_currentPage==0) {
        self.firstImageView.image = [_images lastObject];
        self.secondImageView.image =_images[_currentPage];
        self.threeImageView.image = _images[_currentPage+1];
    }
    else if (_currentPage == _images.count-1)
    {
        self.firstImageView.image = _images[_currentPage-1];
        self.secondImageView.image = _images[_currentPage];
        self.threeImageView.image = [_images firstObject];
    }
    else
    {
        self.firstImageView.image = _images[_currentPage-1];
        self.secondImageView.image = _images[_currentPage];
        self.threeImageView.image = _images[_currentPage+1];
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
    if (_currentPage == _images.count-1) {
        _currentPage = 0;
    }else{
        _currentPage ++;
    }
    [UIView animateWithDuration:.3 animations:^{
        
        if (self.direction == MSCycleDirectionHorizontal) {
            _scrollView.contentOffset = CGPointMake(self.frame.size.width*2, 0);

        }else{
            _scrollView.contentOffset = CGPointMake(0, self.frame.size.height*2);
        }
    } completion:^(BOOL finished) {
        [self reloadData];
    }];
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self commoninit];
}

@end
