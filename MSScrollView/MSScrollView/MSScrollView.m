//
//  MSScrollView.m
//  MSScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//

#import "MSScrollView.h"
//#import "SDWebImageManager.h"
#import "CustomerPageControl.h"
#import <CommonCrypto/CommonDigest.h>
#define kPageHeight 10

@interface MSScrollView()
{
    UIScrollView    *_scrollView;
    CustomerPageControl   *_pageControl;
    int _currentPage;
}
@property (nonatomic, strong) NSTimer *AutoTimer;
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *threeImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation MSScrollView



- (UIImageView *)firstImageView{
    if (!_firstImageView) {
        _firstImageView = [[UIImageView alloc] init];
//        _firstImageView.contentMode = UIViewContentModeScaleAspectFill;
        _firstImageView.userInteractionEnabled = YES;
    }
    return _firstImageView;
}
- (UIImageView *)secondImageView{
    if (!_secondImageView) {
        _secondImageView = [[UIImageView alloc] init];
//        _secondImageView.contentMode = UIViewContentModeScaleAspectFill;
        _secondImageView.userInteractionEnabled = YES;
    }
    return _secondImageView;
}
- (UIImageView *)threeImageView{
    if (!_threeImageView) {
        _threeImageView = [[UIImageView alloc] init];
//        _threeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _threeImageView.userInteractionEnabled = YES;
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
- (void)downLoadImageWithURL:(NSURL *)url success:(void(^)(UIImage* image,NSURL* url))completced{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MSCache",[[NSBundle mainBundle].infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path];
    if (!existed) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cachePatch = [path stringByAppendingPathComponent:[self stringFromMD5:url.absoluteString]];
    
    if ([fileManager fileExistsAtPath:cachePatch]) {
        UIImage *image = [UIImage imageWithContentsOfFile:cachePatch];
        if (image) {
            completced(image,url);
        }
        
    }else{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
       __block NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *toPath = [path stringByAppendingPathComponent:[self stringFromMD5:url.absoluteString]];
                
                [fileManager moveItemAtPath:location.path toPath:toPath error:nil];
                UIImage *image = [UIImage imageWithContentsOfFile:toPath];
                completced(image,response.URL);
                downloadTask = nil;
            }
        }];
        [downloadTask resume];
    }
    
}
- (NSString *) stringFromMD5:(NSString *)str{
    
    if(self == nil || [str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
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
    [images enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        UIImage *image = [UIImage imageNamed:(NSString *)obj];
        [tempArr addObject:image];
    }];
    _images = [tempArr copy];
    [self commoninit];
}
- (void)setUrlImages:(NSMutableArray *)urlImages{
    
    [self initImages:urlImages fromUrl:YES];
    
}

- (void)setPageControlOffset:(UIOffset)pageControlOffset{
    _pageControlOffset = pageControlOffset;
    [self addPageControl];
}
#pragma mark-
#pragma markPrivate methods
/* 设置图片 */
- (void)initImages:(NSArray *)images fromUrl:(BOOL)fromUrl{
    if (!_images) {
        _images = [NSMutableArray arrayWithCapacity:images.count];
    }
    [_images removeAllObjects];

    if (fromUrl) {
        for (int i= 0; i < images.count; i++) {
            [_images addObject:[UIImage imageNamed:(_placeholderImage == nil?@"MSSource.bundle/def.jpg":_placeholderImage)]];
        }
        [images enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
            
            [self downLoadImageWithURL:[NSURL URLWithString:(NSString *)obj] success:^(UIImage *image, NSURL *url) {
                if (image )
                {
                    NSInteger index = [images indexOfObject:url.absoluteString];
                    [_images replaceObjectAtIndex:index withObject:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self commoninit];
                        
                    });
                }
            }];
            
//            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:(NSString *)obj] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                
//                if (image && finished)
//                {
//                    NSInteger index = [images indexOfObject:imageURL.absoluteString];
//                    [_images replaceObjectAtIndex:index withObject:image];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self commoninit];
//                        
//                    });
//                }else{
////                    [_images addObject:[UIImage imageNamed:(_placeholderImage == nil?@"MSSource.bundle/def.jpg":_placeholderImage)]];
////                    dispatch_async(dispatch_get_main_queue(), ^{
////                        [self commoninit];
////                        
////                    });
//                }
//            }];
        
        }];
        
    }else{
        for (NSString *imageName in images) {
            [_images addObject:[UIImage imageNamed:imageName]];
        }
    }
}
- (void)addScrollView{
    if (_scrollView == nil) {
        _scrollView                                = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.delegate                       = self;
        _scrollView.pagingEnabled                  = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.scrollsToTop                   = NO;
        _scrollView.bounces = NO;

    }
    _scrollView.frame = self.bounds;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    [_scrollView addSubview:self.firstImageView];
    [_scrollView addSubview:self.secondImageView];
    [_scrollView addSubview:self.threeImageView];
    
    if (self.direction == MSCycleDirectionHorizontal) {
        self.firstImageView.frame = self.frame;
        self.secondImageView.frame = CGRectMake(width, 0, width, height);
        self.threeImageView.frame = CGRectMake(width*2, 0, width, height);
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    }else{
        self.firstImageView.frame = self.frame;
        self.secondImageView.frame = CGRectMake(0, height, width, height);
        self.threeImageView.frame = CGRectMake(0, height*2, width, height);
        _scrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);
    }
   
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
        _tapGestureRecognizer.numberOfTapsRequired    = 1;
        _tapGestureRecognizer.delegate                = self;
    }
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];

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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

/**
 *  添加pagcontrol
 */
- (void)addPageControl{
    if (_pageControl == nil) {
        _pageControl                               = [[CustomerPageControl alloc] init];
        _pageControl.pageIndicatorTintColor        = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.userInteractionEnabled        = NO;
    }
   _pageControl.frame = CGRectMake(_pageControlOffset.horizontal, self.frame.size.height-kPageHeight-_pageControlOffset.vertical, self.frame.size.width-_pageControlOffset.horizontal, kPageHeight);
    _pageControl.numberOfPages                 = _images.count;
    
    [self addSubview:_pageControl];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(MSScrollViewDidScroll:)]) {
        [self.delegate MSScrollViewDidScroll:_scrollView];
    }
    [self playImages];
}
- (void)playImages{
    if (self.direction == MSCycleDirectionHorizontal) {
        float x = _scrollView.contentOffset.x;
        
        //往前翻
        if (x<=0 ) {
            if (_currentPage-1<0) {
                _currentPage = (int)_images.count-1;
            }else{
                _currentPage --;
            }
            [self reloadData];
        }
        
        //往后翻
        if (x>=self.frame.size.width*2 ) {
            if (_currentPage==_images.count-1) {
                _currentPage = 0;
            }else{
                _currentPage ++;
            }
            [self reloadData];
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
            [self reloadData];
        }
        //down
        if (y<self.frame.size.height) {
            if (_currentPage-1<0) {
                _currentPage = (int)_images.count-1;
            }else{
                _currentPage --;
            }
            [self reloadData];
        }
    }
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
    if (_images.count<=0) {
        return;
    }
    if (_currentPage==0) {
        self.firstImageView.image = [_images lastObject];
        self.secondImageView.image =_images[_currentPage];
        if (_images.count == 1) {
            self.threeImageView.image = [_images lastObject];
        }else{
            self.threeImageView.image = _images[_currentPage+1];
        }
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
    _pageControl.currentPage = _currentPage;
    if(self.direction == MSCycleDirectionHorizontal){
        _scrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
        
    }else{
        
        _scrollView.contentOffset = CGPointMake(0, self.frame.size.height);
    }
    
    
}
#pragma mark 展示下一页
-(void)autoShowNextImage
{
    if (self.direction == MSCycleDirectionHorizontal) {
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width*2, 0) animated:YES];

    }else{
        [_scrollView setContentOffset:CGPointMake(0, self.frame.size.height*2) animated:YES];
    }
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self commoninit];
}
- (void)clearCache{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MSCache",[[NSBundle mainBundle].infoDictionary objectForKey:(__bridge NSString *)kCFBundleIdentifierKey]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path];
    if (existed) {
        [fileManager removeItemAtPath:path error:nil];
    }
}
@end
