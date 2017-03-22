/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "DXRecordView.h"

@interface DXRecordView ()

@end

@implementation DXRecordView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
//        bgView.backgroundColor = [UIColor grayColor];
        bgView.layer.cornerRadius = 5;
        bgView.layer.masksToBounds = YES;
        bgView.alpha = 0.6;
        [self addSubview:bgView];
        
        self.recordAnimationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.recordAnimationView.image = [UIImage imageNamed:@"icon_yuyin01"];
        [self addSubview:self.recordAnimationView];
        
        self.deleView = [[UIImageView alloc] initWithFrame:self.recordAnimationView.bounds];
        self.deleView.image = [UIImage imageNamed:@"icon_fanhui"];
        self.deleView.hidden = 1;
        [self addSubview:self.deleView];
        
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                               self.bounds.size.height - 30,
                                                               self.bounds.size.width - 10,
                                                               25)];
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.text = @"手指上滑，取消发送";
        [self addSubview:self.textLabel];
        self.textLabel.font = [UIFont systemFontOfSize:13];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.layer.cornerRadius = 5;
        self.textLabel.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor;
        self.textLabel.layer.masksToBounds = YES;
    }
    return self;
}

// 录音按钮按下
-(void)recordButtonTouchDown
{
    // 需要根据声音大小切换recordView动画
    self.textLabel.text = NSLocalizedString(@"message.toolBar.record.upCancel", @"Fingers up slide, cancel sending");
    self.textLabel.backgroundColor = [UIColor clearColor];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(setVoiceImage)
                                            userInfo:nil
                                             repeats:YES];
    
}
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside
{
    [_timer invalidate];
}
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside
{
    [_timer invalidate];
}
// 手指移动到录音按钮内部
-(void)recordButtonDragInside
{
    self.textLabel.text = NSLocalizedString(@"message.toolBar.record.upCancel", @"Fingers up slide, cancel sending");
    self.textLabel.backgroundColor = [UIColor clearColor];
}

// 手指移动到录音按钮外部
-(void)recordButtonDragOutside
{
    self.textLabel.text = NSLocalizedString(@"message.toolBar.record.loosenCancel", @"loosen the fingers, to cancel sending");
    self.textLabel.backgroundColor = [UIColor redColor];
}
- (void)setVoiceImageWith:(double)sound
{
    self.recordAnimationView.image = [UIImage imageNamed:@"VoiceSearchFeedback001"];
    double voiceSound = sound;
    //    voiceSound = [[EaseMob sharedInstance].deviceManager peekRecorderVoiceMeter];
    if (0 < voiceSound <= 0.05) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin00"]];
    }else if (0.05<voiceSound<=0.10) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin00"]];
    }else if (0.10<voiceSound<=0.15) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin01"]];
    }else if (0.15<voiceSound<=0.20) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin01"]];
    }else if (0.20<voiceSound<=0.25) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin02"]];
    }else if (0.25<voiceSound<=0.30) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin02"]];
    }else if (0.30<voiceSound<=0.35) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin03"]];
    }else if (0.35<voiceSound<=0.40) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin03"]];
    }else if (0.40<voiceSound<=0.45) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin04"]];
    }else if (0.45<voiceSound<=0.50) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin04"]];
    }else if (0.50<voiceSound<=0.55) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin05"]];
    }else if (0.55<voiceSound<=0.60) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin05"]];
    }else if (0.60<voiceSound<=0.65) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin06"]];
    }else if (0.65<voiceSound<=0.70) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin06"]];
    }else if (0.70<voiceSound<=0.75) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin07"]];
    }else if (0.75<voiceSound<=0.80) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin07"]];
    }else if (0.80<voiceSound<=0.85) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin08"]];
    }else if (0.85<voiceSound<=0.90) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin08"]];
    }else if (0.90<voiceSound<=0.95) {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin09"]];
    }else {
        [self.recordAnimationView setImage:[UIImage imageNamed:@"icon_yuyin09"]];
    }

}

@end
