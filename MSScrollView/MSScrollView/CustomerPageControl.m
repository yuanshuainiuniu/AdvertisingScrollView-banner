//
//  CustomerPageControl.m
//  lyfen
//
//  Created by laiyifen on 15/11/2.
//  Copyright © 2015年 YU Harry. All rights reserved.
//

#import "CustomerPageControl.h"

@implementation CustomerPageControl


- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    CGFloat width = 5;
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
         UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        subview.layer.cornerRadius = width*0.5;
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, width,width)];
        if (subviewIndex == page) {
           [subview setBackgroundColor:self.currentPageIndicatorTintColor];
        } else {
            [subview setBackgroundColor:self.pageIndicatorTintColor];
        }
    }
}
@end
