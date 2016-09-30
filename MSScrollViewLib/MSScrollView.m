//
//  MSScrollView.m
//  MSScrollView
//
//  Created by Marshal on 3/18/15.
//  Copyright (c) 2015 Gobeta. All rights reserved.
//

#import "MSScrollView.h"
#import <CommonCrypto/CommonDigest.h>
#define kPageHeight 8

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
@interface MSScrollView()
{
    UIScrollView    *_scrollView;
    int _currentPage;
}
@property (nonatomic, strong) NSTimer *AutoTimer;
@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *threeImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDownloadTask *> *downloadTaskArray;
@end

@implementation MSScrollView

- (NSMutableArray<NSURLSessionDownloadTask *> *)downloadTaskArray{
    if (!_downloadTaskArray) {
        _downloadTaskArray = [NSMutableArray array];
    }
    return _downloadTaskArray;
}

- (UIImageView *)firstImageView{
    if (!_firstImageView) {
        _firstImageView = [self ImageView];
    }
    return _firstImageView;
}
- (UIImageView *)secondImageView{
    if (!_secondImageView) {
        _secondImageView = [self ImageView];
    }
    return _secondImageView;
}
- (UIImageView *)threeImageView{
    if (!_threeImageView) {
        _threeImageView = [self ImageView];
    }
    return _threeImageView;
}
- (UIImageView *)ImageView{
    
    UIImageView *imagv = [[UIImageView alloc] init];
    imagv.contentMode = UIViewContentModeScaleAspectFill;
    if(self.contentModel){
        imagv.contentMode = self.contentMode;
    }
    imagv.userInteractionEnabled = YES;
    imagv.layer.masksToBounds = YES;
    return imagv;
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
        sessionConfiguration.timeoutIntervalForRequest = 15;
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 6;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
        __block NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *toPath = [path stringByAppendingPathComponent:[self stringFromMD5:url.absoluteString]];
                
                [fileManager moveItemAtPath:location.path toPath:toPath error:nil];
                UIImage *image = [UIImage imageWithContentsOfFile:toPath];
                if (self.shouldCompressImage){
                    NSData *fData = UIImageJPEGRepresentation(image, 1.0);
                    while(fData.length>1024*1024*1) {//大于2m
                        image = [self imageCompressForWidth:image targetWidth:image.size.width*0.8];
                        fData = UIImageJPEGRepresentation(image, 1.0);
                    }
                }
                
                completced(image,response.URL);
                [self.downloadTaskArray removeObject:downloadTask];
                downloadTask = nil;
                
            }
        }];
        [downloadTask resume];
        [self.downloadTaskArray addObject:downloadTask];
    }
    
}
#pragma mark - 压缩图片
- (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)cancleAllTask{
    for (NSURLSessionDownloadTask *task in self.downloadTaskArray) {
        [task cancel];
    }
    
    [self.downloadTaskArray removeAllObjects];
}
- (void)dealloc{
    [self cancleAllTask];
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
    _images = [tempArr mutableCopy];
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
    dispatch_main_async_safe(^{
        
        if (self.images == nil) {
            self.images = [NSMutableArray arrayWithCapacity:images.count];
        }
        [self.images removeAllObjects];
        [self cancleAllTask];
        
        if (fromUrl) {
            for (int i= 0; i < images.count; i++) {
                UIImage *placeHold = [UIImage imageNamed:(self.placeholderImage == nil?@"MSSource.bundle/def.jpg":self.placeholderImage)];
                [self.images addObject:placeHold != nil?placeHold:@""];
            }
            
            [images enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                __weak __typeof(self)weakSelf = self;
                [weakSelf downLoadImageWithURL:[NSURL URLWithString:(NSString *)obj] success:^(UIImage *image, NSURL *url) {
                    if (image )
                    {
                        [weakSelf.images replaceObjectAtIndex:idx withObject:image];
                        dispatch_main_async_safe(^{
                            [weakSelf commoninit];
                        });
                    }
                }];
                
            }];
            
        }else{
            for (NSString *imageName in images) {
                [self.images addObject:[UIImage imageNamed:imageName]];
            }
        }
    });
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
        _pageControl.pageIndicatorTintColor        = [UIColor colorWithWhite:0.7 alpha:0.5];
        _pageControl.currentPageIndicatorTintColor = [UIColor purpleColor];
        _pageControl.userInteractionEnabled        = NO;
    }
    _pageControl.numberOfPages                 = _images.count;
    if (!self.pageControlDir || self.pageControlDir == MSPageControl_Center) {
        
        _pageControl.frame = CGRectMake((self.frame.size.width-_pageControl.frame.size.width)/2, self.frame.size.height-kPageHeight-_pageControlOffset.vertical-1, self.frame.size.width-_pageControlOffset.horizontal, kPageHeight);
        
    }else if (self.pageControlDir == MSPageControl_Left){
        _pageControl.frame = CGRectMake(_pageControlOffset.horizontal, self.frame.size.height-kPageHeight-_pageControlOffset.vertical-1, self.frame.size.width-_pageControlOffset.horizontal, kPageHeight);
        
    }else if (self.pageControlDir == MSPageControl_Right){
        _pageControl.frame = CGRectMake(_pageControlOffset.horizontal+self.frame.size.width-_pageControl.frame.size.width, self.frame.size.height-kPageHeight-_pageControlOffset.vertical-1, self.frame.size.width-_pageControlOffset.horizontal, kPageHeight);
    }
    
    
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
        [_scrollView setContentOffset:CGPointMake(self.frame.size.width, 0) animated:NO];
        
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
