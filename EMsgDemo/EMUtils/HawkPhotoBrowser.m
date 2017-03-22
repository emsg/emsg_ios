//
//  HawkPhotoBrowser.m
//  qiuyouquan
//
//  Created by QYQ-Hawk on 15/12/22.
//  Copyright © 2015年 QYQ-Hawk. All rights reserved.
//
#import "HawkPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "BrowserUIImageView.h"
#import "MBProgressHUD+Add.h"

const CGFloat TITLE_FONT_SIZE = 17.0f;
const CGFloat COVER_VC_ALPHA = 1.0f;
const CGFloat SHOW_DURATION = 0.1;
const CGFloat HIDE_DURATION = 0.3;
static NSString * PLACEHOLDER_PHOTO = @"无图_cycle";

@interface HawkPhotoBrowser ()

{
    UIView *_black_view;
    UIScrollView *_scroll_view;
    UILabel *_title;
    UIButton * _saveImageBtn;
    NSMutableArray * _imageViewsArray;
}
@end

@implementation HawkPhotoBrowser



- (id)init
{
    self = [super init];
    if (self) {
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = window.bounds;
        
        _imageViewsArray = [NSMutableArray array];
        
        _black_view = [[UIView alloc]initWithFrame:self.bounds];
        _black_view.backgroundColor = [UIColor blackColor];
        _black_view.alpha = COVER_VC_ALPHA;
        [self addSubview:_black_view];
        
        _scroll_view = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scroll_view.pagingEnabled = YES;
        _scroll_view.delegate = self;
        _scroll_view.showsHorizontalScrollIndicator = NO;
        _scroll_view.showsVerticalScrollIndicator = NO;
        [self addSubview:_scroll_view];
        
        _title = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.frame.size.width, 15)];
        _title.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = [UIColor whiteColor];
        [self addSubview:_title];
        
        [self setupSaveButton];

    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setCurrentIndex:(int)currentIndex
{
    _title.text = [NSString stringWithFormat:@"%d/%d",currentIndex+1,(int)self.imageArray.count];
    _currentIndex = currentIndex;
    _scroll_view.contentOffset = CGPointMake(currentIndex*_scroll_view.frame.size.width, 0);
}
- (void)setImageArray:(NSArray *)imgaeArray
{
    _imageArray = imgaeArray;
    _title.text = [NSString stringWithFormat:@"%d/%d",self.currentIndex+1,(int)imgaeArray.count];
    for (int i =0; i<imgaeArray.count; i++) {
        
        UIScrollView *inScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(i*_scroll_view.frame.size.width, 0, _scroll_view.frame.size.width, _scroll_view.frame.size.height)];
        //        inScroll.showsHorizontalScrollIndicator = NO;
        //        inScroll.showsVerticalScrollIndicator = NO;
        inScroll.bounces = NO;
        inScroll.delegate = self;
        inScroll.tag = i*100+1*100;
        inScroll.minimumZoomScale = 1.0;
        inScroll.maximumZoomScale = 2.0;
        [_scroll_view addSubview:inScroll];
        
        BrowserUIImageView *imgView = [[BrowserUIImageView alloc]initWithFrame:CGRectMake(0, 0, _scroll_view.frame.size.width, _scroll_view.frame.size.height)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:imgaeArray[i]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_PHOTO]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.multipleTouchEnabled = YES;
        imgView.isSaved = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTap:)];
        tap.numberOfTapsRequired = 1;
        [imgView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [imgView addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        [inScroll addSubview:imgView];
        
        [_imageViewsArray addObject:imgView];
    }
    _scroll_view.bounces = NO;
    _scroll_view.contentSize = CGSizeMake(imgaeArray.count*_scroll_view.frame.size.width, _scroll_view.frame.size.height);
    
}

- (void)setDownImageArray:(NSArray *)imgaeArray
{
    _imageArray = imgaeArray;
    _title.text = [NSString stringWithFormat:@"%d/%d",self.currentIndex+1,(int)imgaeArray.count];
    for (int i =0; i<imgaeArray.count; i++) {
        
        UIScrollView *inScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(i*_scroll_view.frame.size.width, 0, _scroll_view.frame.size.width, _scroll_view.frame.size.height)];
        //        inScroll.showsHorizontalScrollIndicator = NO;
        //        inScroll.showsVerticalScrollIndicator = NO;
        inScroll.bounces = NO;
        inScroll.delegate = self;
        inScroll.tag = i*100+1*100;
        inScroll.minimumZoomScale = 1.0;
        inScroll.maximumZoomScale = 2.0;
        [_scroll_view addSubview:inScroll];
        
        BrowserUIImageView *imgView = [[BrowserUIImageView alloc]initWithFrame:CGRectMake(0, 0, _scroll_view.frame.size.width, _scroll_view.frame.size.height)];
        imgView.image = [imgaeArray objectAtIndex:i];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.multipleTouchEnabled = YES;
        imgView.isSaved = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTap:)];
        tap.numberOfTapsRequired = 1;
        [imgView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [imgView addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        [inScroll addSubview:imgView];
        
        [_imageViewsArray addObject:imgView];
    }
    _scroll_view.bounces = NO;
    _scroll_view.contentSize = CGSizeMake(imgaeArray.count*_scroll_view.frame.size.width, _scroll_view.frame.size.height);
    
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self exChangeScale:self dur:SHOW_DURATION];
}

- (void)setupSaveButton{
    // 保存图片按钮
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.frame = CGRectMake(20, self.frame.size.height - 88, 44, 44);
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveImageBtn];
}

#pragma mark -- Save Picture


- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BrowserUIImageView *photo = _imageViewsArray[_currentIndex];
        if (!photo.isSaved) {
            UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        BrowserUIImageView *photo = _imageViewsArray[_currentIndex];
        photo.isSaved = YES;
        _saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}


#pragma mark --ButtonClick -
- (void)imgTap:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:HIDE_DURATION animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)imgDoubleTap:(UITapGestureRecognizer *)tap
{
    UIScrollView *inScroll = (UIScrollView *)tap.view.superview;
    if (inScroll.zoomScale != 1) {
        [inScroll setZoomScale:1.0 animated:YES];
    } else {
        [inScroll setZoomScale:2.0 animated:YES];
    }
}
- (void) scaleImage:(UIPinchGestureRecognizer*)gesture
{
    UIImageView *imgView = (UIImageView *)gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        imgView.transform = CGAffineTransformScale(imgView.transform, gesture.scale, gesture.scale);
        gesture.scale = 1;
        UIScrollView *scroll = (UIScrollView *)[gesture.view superview];
        scroll.contentSize = CGSizeMake(imgView.image.size.width, imgView.image.size.height);
    }
}
#pragma mark --ScrollViewDelegate -
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView == _scroll_view) {
//
//        int x = scrollView.contentOffset.x/scrollView.frame.size.width;
//        _title.text = [NSString stringWithFormat:@"%d/%d",_currentIndex+1,(int)self.imageArray.count];
//        if (x != _currentIndex) {
//            for (UIScrollView *inScroll in _scroll_view.subviews) {
//                [inScroll setZoomScale:1.0 animated:YES];
//                _currentIndex = x;
//            }
//        }
//
//    }
//}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scroll_view) {
        int x = scrollView.contentOffset.x/scrollView.frame.size.width;
        _title.text = [NSString stringWithFormat:@"%d/%d",_currentIndex+1,(int)self.imageArray.count];
        if (x != _currentIndex) {
            for (UIScrollView *inScroll in _scroll_view.subviews) {
                [inScroll setZoomScale:1.0 animated:YES];
                _currentIndex = x;
                BrowserUIImageView *photo = _imageViewsArray[_currentIndex];
                if (photo.isSaved) {
                    _saveImageBtn.enabled = NO;
                }
                else{
                    _saveImageBtn.enabled = YES;
                }
            }
        }
        
    }
}
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    self.currentIndex = _scroll_view.contentOffset.x/_scroll_view.frame.size.width;
    UIScrollView *inScroll = (UIScrollView *)[_scroll_view viewWithTag:(_currentIndex+1)*100];
    UIImageView *imgView = [inScroll.subviews firstObject];
    return imgView;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != _scroll_view) {
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
    }
}
#pragma mark --弹出效果 -
- (void)exChangeScale:(UIView *)changeOutView dur:(CFTimeInterval)dur
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [changeOutView.layer addAnimation:animation forKey:nil];
}

@end
