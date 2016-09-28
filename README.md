# AdvertisingScrollView
![image](https://github.com/yuanshuainiuniu/AdvertisingScrollView/blob/master/shot.gif)

做了一些优化,用3个imageView复用创建,支持横屏和竖屏播放(3imageView for reuse)


支持从网上下载图片(support load images from url)

后续会添加文字描述

a AdvertisingScrollView,can scroll auto,or by yourself.

Installation with CocoaPods：pod 'MSScrollView'

Drag`MSScrollView.h` `MSScrollView.m` to your project<br>
init：
```Objective-c
NSArray *array = @[@"1.jpg",@"2.jpg",@"3.jpg"];
CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 105);
MSScrollView *scrollView = [[MSScrollView alloc] initWithFrame:frame
                                                        images:array
                                                      delegate:self
                                                     direction:MSCycleDirectionHorizontal
                                                      autoPlay:YES
                                                         delay:5.0];
[self.view addSubview:scrollView];
/*
 frame:set MSScrollView frame
 images:your imagenames
 delegate:
 direciton:MSCycleDirectionHorizontal or MSCycleDirectionVertical
 autoPlay:or play auto
 delay:tmer
*/
```
### MSScrollViewDelegate
```Objective-c
- (void)MSScrollView:(MSScrollView *)MSScrollView didSelectPage:(NSInteger)index;

- (void)MSScrollViewDidScroll:(UIScrollView *)scrollView;


