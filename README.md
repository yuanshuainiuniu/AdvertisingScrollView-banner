# AdvertisingScrollView
a AdvertisingScrollView,can scroll auto,or by yourself.
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


![image](https://github.com/yuanshuainiuniu/AdvertisingScrollView/blob/master/shot.png)
![image](https://github.com/yuanshuainiuniu/MSTableViewCell/blob/master/shot.png)
