//
//  QYQMessageShareMenuView.m
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/24.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "QYQMessageShareMenuView.h"

// 每行有4个
#define kZBMessageShareMenuPerRowItemCount 4
#define kZBMessageShareMenuPerColum 2

#define kZBShareMenuItemIconSize 60
#define KZBShareMenuItemHeight 80

@interface ZBMessageShareMenuItemView : UIView

@property (nonatomic, weak) UIButton *shareMenuItemButton;
@property (nonatomic, weak) UILabel *shareMenuItemTitleLabel;

@end

@implementation ZBMessageShareMenuItemView

- (void)setup {
    if (!_shareMenuItemButton) {
        UIButton *shareMenuItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareMenuItemButton.frame = CGRectMake(0, 0,kZBShareMenuItemIconSize, kZBShareMenuItemIconSize);
        shareMenuItemButton.backgroundColor = [UIColor clearColor];
        [self addSubview:shareMenuItemButton];
        
        self.shareMenuItemButton = shareMenuItemButton;
    }
    
    if (!_shareMenuItemTitleLabel) {
        UILabel *shareMenuItemTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuItemButton.frame), kZBShareMenuItemIconSize, KZBShareMenuItemHeight - kZBShareMenuItemIconSize)];
        shareMenuItemTitleLabel.backgroundColor = [UIColor clearColor];
        shareMenuItemTitleLabel.textColor = [UIColor blackColor];
        shareMenuItemTitleLabel.font = [UIFont systemFontOfSize:12];
        shareMenuItemTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:shareMenuItemTitleLabel];
        
        
        self.shareMenuItemTitleLabel = shareMenuItemTitleLabel;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

@end

@interface QYQMessageShareMenuView ()<UIScrollViewDelegate>

/**
 *  这是背景滚动视图
 */
@property (nonatomic, weak) UIScrollView *shareMenuScrollView;
@property (nonatomic, weak) UIPageControl *shareMenuPageControl;

@end

@implementation QYQMessageShareMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)shareMenuItemButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelecteShareMenuItem:atIndex:)]) {
        NSInteger index = sender.tag;
        if (index < self.shareMenuItems.count) {
            [self.delegate didSelecteShareMenuItem:[self.shareMenuItems objectAtIndex:index] atIndex:index];
        }
    }
}

- (void)setup{
    self.backgroundColor = [UIColor colorWithRed:248.0f/255 green:248.0f/255 blue:255.0f/255 alpha:1.0];
    
    if (!_shareMenuScrollView) {
        UIScrollView *shareMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kZBMessageShareMenuPageControlHeight)];
        shareMenuScrollView.delegate = self;
        shareMenuScrollView.canCancelContentTouches = NO;
        shareMenuScrollView.delaysContentTouches = YES;
        shareMenuScrollView.backgroundColor = self.backgroundColor;
        shareMenuScrollView.showsHorizontalScrollIndicator = NO;
        shareMenuScrollView.showsVerticalScrollIndicator = NO;
        [shareMenuScrollView setScrollsToTop:NO];
        shareMenuScrollView.pagingEnabled = YES;
        [self addSubview:shareMenuScrollView];
        
        self.shareMenuScrollView = shareMenuScrollView;
    }
    
    if (!_shareMenuPageControl) {
        UIPageControl *shareMenuPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareMenuScrollView.frame), CGRectGetWidth(self.bounds), kZBMessageShareMenuPageControlHeight)];
        shareMenuPageControl.backgroundColor = self.backgroundColor;
        shareMenuPageControl.hidesForSinglePage = YES;
        shareMenuPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:shareMenuPageControl];
        
        self.shareMenuPageControl = shareMenuPageControl;
    }
    [self reloadData];
}

- (void)reloadData {
    if (!_shareMenuItems.count)
        return;
    
    [self.shareMenuScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat paddingX = 16;
    CGFloat paddingY = 10;
    for (ZBMessageShareMenuItem *shareMenuItem in self.shareMenuItems) {
        NSInteger index = [self.shareMenuItems indexOfObject:shareMenuItem];
        NSInteger page = index / (kZBMessageShareMenuPerRowItemCount * 2);
        CGRect shareMenuItemViewFrame = CGRectMake((index % kZBMessageShareMenuPerRowItemCount) * (kZBShareMenuItemIconSize + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / kZBMessageShareMenuPerRowItemCount) - kZBMessageShareMenuPerColum * page) * (KZBShareMenuItemHeight + paddingY) + paddingY, kZBShareMenuItemIconSize, KZBShareMenuItemHeight);
        ZBMessageShareMenuItemView *shareMenuItemView = [[ZBMessageShareMenuItemView alloc] initWithFrame:shareMenuItemViewFrame];
        
        shareMenuItemView.shareMenuItemButton.tag = index;
        [shareMenuItemView.shareMenuItemButton addTarget:self action:@selector(shareMenuItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [shareMenuItemView.shareMenuItemButton setImage:shareMenuItem.normalIconImage forState:UIControlStateNormal];
        shareMenuItemView.shareMenuItemTitleLabel.text = shareMenuItem.title;
        
        [self.shareMenuScrollView addSubview:shareMenuItemView];
    }
    
    self.shareMenuPageControl.numberOfPages = (self.shareMenuItems.count / (kZBMessageShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kZBMessageShareMenuPerRowItemCount * 2) ? 1 : 0));
    [self.shareMenuScrollView setContentSize:CGSizeMake(((self.shareMenuItems.count / (kZBMessageShareMenuPerRowItemCount * 2) + (self.shareMenuItems.count % (kZBMessageShareMenuPerRowItemCount * 2) ? 1 : 0)) * CGRectGetWidth(self.bounds)), CGRectGetHeight(self.shareMenuScrollView.bounds))];
}

- (void)dealloc {
    self.shareMenuItems = nil;
//    self.shareMenuScrollView.delegate = self;
    self.shareMenuScrollView = nil;
    self.shareMenuPageControl = nil;
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.shareMenuPageControl setCurrentPage:currentPage];
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

