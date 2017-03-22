//
//  QYQMessageManagerFaceView.m
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/24.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "QYQMessageManagerFaceView.h"

#define FaceSectionBarHeight  36   // 表情下面控件
#define FacePageControlHeight 30  // 表情pagecontrol

#define Pages 3

@implementation QYQMessageManagerFaceView
{
    UIPageControl *pageControl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.backgroundColor = [UIColor colorWithRed:248.0f/255 green:248.0f/255 blue:255.0f/255 alpha:1.0];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-FacePageControlHeight-FaceSectionBarHeight)];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setContentSize:CGSizeMake(CGRectGetWidth(scrollView.frame)*Pages,CGRectGetHeight(scrollView.frame))];
    
    for (int i= 0;i<Pages;i++) {
        ZBFaceView *faceView = [[ZBFaceView alloc]initWithFrame:CGRectMake(i*CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(scrollView.bounds)) forIndexPath:i];
        [scrollView addSubview:faceView];
        faceView.delegate = self;
    }
    
    pageControl = [[UIPageControl alloc]init];
    [pageControl setFrame:CGRectMake(0,CGRectGetMaxY(scrollView.frame),CGRectGetWidth(self.bounds),FacePageControlHeight)];
    [self addSubview:pageControl];
    [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    pageControl.numberOfPages = Pages;
    pageControl.currentPage   = 0;
    
    
    UIView *sectionBar = [[UIView alloc]initWithFrame:CGRectMake(0.0f,CGRectGetMaxY(pageControl.frame),CGRectGetWidth(self.bounds), FaceSectionBarHeight)];
    sectionBar.backgroundColor = [UIColor colorWithRed:255.0f/255 green:250.0f/255 blue:240.0f/255 alpha:1];
    [self addSubview:sectionBar];
}

#pragma mark  scrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x/320;
    pageControl.currentPage = page;
    
}

#pragma mark ZBFaceView Delegate
- (void)didSelecteFace:(NSString *)faceName andIsSelecteDelete:(BOOL)del{
    if ([self.delegate respondsToSelector:@selector(SendTheFaceStr:isDelete:) ]) {
        [self.delegate SendTheFaceStr:faceName isDelete:del];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

