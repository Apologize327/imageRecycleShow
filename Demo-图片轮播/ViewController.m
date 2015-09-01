//
//  ViewController.m
//  Demo-图片轮播
//
//  Created by Suning on 15/8/31.
//  Copyright (c) 2015年 Suning. All rights reserved.
//

#import "ViewController.h"

#define imgCount    5

@interface ViewController ()<UIScrollViewDelegate>

/** 图片展示区 */
@property(nonatomic,strong) UIScrollView *imgShowView;
/** 图片切换按钮,UIPageControl提供一行点来指示当前显示的是多页面中的哪一页 */
@property(nonatomic,strong) UIPageControl *pageControl;
/** 定时器 */
@property(nonatomic,strong) NSTimer *imgTimer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下面这两行代码顺序不能调换，否则代理方法不执行。因为setUpBackGroundView是实例化了一个imgShowView，
    //若先执行self.imgShowView.delegate = self那么imgShowView是nil，空对象是不能执行方法的
    [self setUpBackGroundView];
    
    self.imgShowView.delegate = self;
    
    [self setUpTimer];
    
    [self setUpPageControl];
}

-(void)setUpBackGroundView{
    //图片展示区域
    CGFloat scrollViewW = self.view.frame.size.width - 100;
    CGFloat scrollViewH = 300;
    CGFloat scrollViewX = (self.view.frame.size.width - scrollViewW)/2;
    CGFloat scrollViewY = 90;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewW, scrollViewH)];
    self.imgShowView = scrollView;
    [self.view addSubview:self.imgShowView];
    
    //图片区
    CGFloat imgViewW = scrollViewW;
    CGFloat imgViewH = scrollViewH;
    CGFloat imgViewY = 0;
    for (int i=0; i<imgCount; i++) {
        CGFloat imgViewX = i*imgViewW;
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(imgViewX, imgViewY, imgViewW, imgViewH)];
        
        NSString *imgName = [NSString stringWithFormat:@"img_0%d",i+1];
        imgView.image = [UIImage imageNamed:imgName];
        [self.imgShowView addSubview:imgView];
    }
    
    //设置混动区域scrollView宽度
    CGFloat contentW = imgCount * imgViewW;
    self.imgShowView.contentSize = CGSizeMake(contentW, 0);
    //水平滚动条
    self.imgShowView.showsHorizontalScrollIndicator = NO;
    //根据scrollView的宽度来分页
    self.imgShowView.pagingEnabled = YES;
//    self.imgShowView.clipsToBounds = NO;
}

-(void)setUpTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(showNextImage) userInfo:nil repeats:YES];
    self.imgTimer = timer;
    //将定时器添加到当前线程,NSRunLoopCommonModes表示始终坚挺滚动事件
    [[NSRunLoop currentRunLoop] addTimer:self.imgTimer forMode:NSRunLoopCommonModes];
}

//设置分页显示
-(void)setUpPageControl{
    CGFloat pageControlW = 100;
    CGFloat pageControlH = 80;
    CGFloat pageControlX = (self.view.frame.size.width - pageControlW)/2;
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(pageControlX, 320, pageControlW, pageControlH)];
    pageControl.numberOfPages = imgCount;
    pageControl.currentPage = 0;
    //当前页小圆点颜色
    pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    //其余点的颜色
    pageControl.pageIndicatorTintColor = [UIColor blueColor];
    self.pageControl = pageControl;
    [self.view addSubview:self.pageControl];
}

//销毁定时器
-(void)delImgTimer{
    [self.imgTimer invalidate];
    self.imgTimer = nil;
}
                      
-(void)showNextImage{
   //默认当前页码为0，若为最后一页，那么当前页变为第1页；若不是，则页码加1
    NSInteger pageIndexNum = 0;
    if (self.pageControl.currentPage == imgCount-1) {
        pageIndexNum = 0;
    } else {
        pageIndexNum = self.pageControl.currentPage + 1;
    }
    
    //计算scrollView滚动位置
    CGFloat offsetX = pageIndexNum * self.imgShowView.frame.size.width;
    CGPoint offset = CGPointMake(offsetX, 0);
    [self.imgShowView setContentOffset:offset animated:YES];
}

#pragma mark 代理方法
//开始拖拽scrollView调用
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self delImgTimer];
}

//停止拖拽scrollView调用
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self setUpTimer];
}

//当scrollView滚动时调用
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat theScrollViewW = scrollView.frame.size.width;
    CGFloat a = scrollView.contentOffset.x;
//    NSLog(@"偏移的x方向距离为%f",a);
    NSInteger pageIndex = (scrollView.contentOffset.x + theScrollViewW * 0.5)/theScrollViewW;
    self.pageControl.currentPage = pageIndex;
}

@end
