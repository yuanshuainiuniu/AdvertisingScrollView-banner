//
//  CustomerPageControl.m
//  lyfen
//
//  Created by laiyifen on 15/11/2.
//  Copyright © 2015年 YU Harry. All rights reserved.
//

#import "CustomerPageControl.h"
#define pageBackColor [UIColor colorWithWhite:1.0 alpha:0.5]
@implementation CustomerPageControl
{
    UIView *_currentPageView;
}
static const CGFloat margin = 5.0f;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}
- (void)setNumberOfPages:(NSInteger)numberOfPages{
    _numberOfPages = numberOfPages;
    CGRect frame = self.frame;
    frame.size.width = (numberOfPages+1)*margin + frame.size.height *numberOfPages;
    self.frame = frame;

    for (UIView *sub in self.subviews) {
        [sub removeFromSuperview];
    }
    
    for (int i = 0; i<numberOfPages; i++) {
        UIView *page = [[UIView alloc] init];
        page.layer.masksToBounds = YES;
        page.layer.borderColor = (self.pageIndicatorTintColor?self.pageIndicatorTintColor:[UIColor lightGrayColor]).CGColor;
        page.layer.borderWidth = 0.8;
        page.backgroundColor = pageBackColor;
        [self addSubview:page];
        if (i == 0) {
            _currentPageView = page;
            _currentPageView.backgroundColor = self.currentPageIndicatorTintColor?self.currentPageIndicatorTintColor:[UIColor purpleColor];
        }
    }
}
- (void)setCurrentPage:(NSInteger)currentPage{
    [self setCurrentPage:currentPage withAnimation:NO];
}
- (void)updateCurrentPageDisplay{
    
}
- (void)setCurrentPage:(NSInteger)currentPage withAnimation:(BOOL)animation{
    if (animation) {
        CATransition *transition = [[CATransition alloc]init];
        transition.type = kCATransitionPush;
        transition.duration = 0.2f;
        transition.removedOnCompletion = YES;
        transition.subtype = currentPage<_currentPage? kCATransitionFromRight:kCATransitionFromLeft;
        [_currentPageView.layer addAnimation:transition forKey:@"transition"];
    }
    _currentPage = currentPage;
    if (_currentPage < self.subviews.count) {
        
        _currentPageView.backgroundColor = pageBackColor;
        _currentPageView.layer.borderColor = (self.pageIndicatorTintColor?self.pageIndicatorTintColor:[UIColor lightGrayColor]).CGColor;
        _currentPageView.layer.borderWidth = 0.8;
        
        UIView *page = self.subviews[_currentPage];
        page.backgroundColor = self.currentPageIndicatorTintColor?self.currentPageIndicatorTintColor:[UIColor purpleColor];
        page.layer.borderWidth = 0.0f;
        _currentPageView = page;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSInteger count = self.subviews.count;
    
    CGFloat height = self.frame.size.height;
    
    CGFloat width = height;
    
    for (int i = 0; i < count; i++) {
        UIView *page = self.subviews[i];
        CGFloat x = i*width + (i+1)*margin;
        page.frame = CGRectMake(x, page.frame.origin.y, width, height);
        page.layer.cornerRadius = MIN(width/2, height/2);
    }
}
@end
