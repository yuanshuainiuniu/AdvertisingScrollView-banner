//
//  CustomerPageControl.h
//  lyfen
//
//  Created by laiyifen on 15/11/2.
//  Copyright © 2015年 YU Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerPageControl : UIView

@property(nonatomic) NSInteger numberOfPages;          // default is 0

@property(nonatomic) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1


@property(nullable, nonatomic,strong) UIColor *pageIndicatorTintColor;

@property(nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor;

@property (nonatomic, assign) CGFloat pageWidth;

- (void)setCurrentPage: (NSInteger)currentPage withAnimation:(BOOL)animation;
- (void)updateCurrentPageDisplay;                      // update page display to match the currentPage. ignored if defersCurrentPageDisplay is NO. setting the page value directly will update immediately

//- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;   // returns minimum size required to display dots for given page count. can be used to size control if page count could change

@end
