//
//  QYQChatCell.m
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "QYQChatCell.h"
#import "NSString+SizeFont.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Category.h"
#import <AVFoundation/AVFoundation.h>
#import "UUAVAudioPlayer.h"
#import "VoiceConverter.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "HawkPhotoBrowser.h"



@interface QYQChatCell ()<UUAVAudioPlayerDelegate>
{
    UUAVAudioPlayer *audio;
    NSData *wavData;
}
@property(nonatomic, weak) UILabel *timeView;
@property(nonatomic, weak) UIButton *textView;
@property(nonatomic, weak) UIImageView *iconView;
@property(nonatomic, weak) UIImageView *pickImage;
@property(nonatomic, weak) UILabel *nameLab;
@property(nonatomic, copy) NSString *timeSpt;

@property(nonatomic, strong) UIView *voiceBackView;
@property(nonatomic, strong) UILabel *second;
@property(nonatomic, strong) UIImageView *voice;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

@property(nonatomic, copy) NSString *tempSt;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, assign) BOOL contentVoiceIsPlaying;
@end
@implementation QYQChatCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //时间
        UILabel *timeView = [[UILabel alloc] init];
        timeView.textAlignment = NSTextAlignmentCenter; //字体居中
        timeView.textColor = [UIColor grayColor];
        timeView.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:timeView]; // 添加到contenView里
        self.timeView = timeView;
        //头像
        UIImageView *iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconView];
        iconView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headClick)];
        [iconView addGestureRecognizer:tap];
        self.iconView = iconView;
        self.iconView.contentMode = UIViewContentModeScaleAspectFill;
        //剪裁多余的像素
        iconView.clipsToBounds = YES;
        //昵称
        UILabel *nameLab = [[UILabel alloc] init];
        nameLab.textAlignment = NSTextAlignmentCenter;
        nameLab.font = [UIFont systemFontOfSize:13];
//        [self.contentView addSubview:nameLab];
        self.nameLab = nameLab;
        //正文
        UIButton *textView = [[UIButton alloc] init];
        textView.titleLabel.numberOfLines = 0;
        textView.titleLabel.font = [UIFont systemFontOfSize:16];
        [textView setTitleColor:BASE_3_COLOR forState:UIControlStateNormal];
        [textView addTarget:self
                     action:@selector(textViewClick)
           forControlEvents:UIControlEventTouchUpInside];
        //在按钮里的内边距
        textView.contentEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        [self.contentView addSubview:textView];
        [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.textView = textView;
        textView.adjustsImageWhenHighlighted = NO;
        
        //发送的图片
        UIImageView *pickImage = [[UIImageView alloc] init];
        [textView addSubview:pickImage];
        self.pickImage = pickImage;
        //发送的语音
        self.voiceBackView = [[UIView alloc] init];
        [textView addSubview:self.voiceBackView];
        self.second = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.second.textAlignment = NSTextAlignmentCenter;
        self.second.font = [UIFont systemFontOfSize:14];
        self.voice = [[UIImageView alloc] initWithFrame:CGRectMake(80, 5, 20, 20)];
        
        self.voice.animationDuration = 1;
        self.voice.animationRepeatCount = 0;
        self.indicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicator.center = CGPointMake(80, 15);
        self.voiceBackView.userInteractionEnabled = NO;
        self.second.userInteractionEnabled = NO;
        self.voice.userInteractionEnabled = NO;
        [self.voiceBackView addSubview:self.indicator];
        [self.voiceBackView addSubview:self.voice];
        [self.voiceBackView addSubview:self.second];
        // cell的背景色
        self.backgroundColor = [UIColor clearColor];
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        self.contentVoiceIsPlaying = NO;
    }
    return self;
}
- (void)headClick
{
    if(self.headBolck)
    {
    }
}
#define LHtextFont [UIFont systemFontOfSize:16]
- (void)setKMssage:(EMsgMessage *)kMssage {
    _kMssage = kMssage;
    ZXUser *userModel = [ZXCommens fetchUser];
    
    //间距
    CGFloat padding = 10;
    //屏幕的宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat timeX = 0;
    CGFloat timeY = 0;
    CGFloat timeW = screenW;
    CGFloat timeH = 40;
    self.timeView.frame = CGRectMake(timeX, timeY, timeW, timeH);
    
    //头像的frame
    CGFloat iconW = 60;
    CGFloat iconH = 60;
    CGFloat iconY;
    CGFloat iconX;
    if(kMssage.payload.attrs.isShowTimelabel)
    {
        self.timeView.hidden = 0;
        iconY = CGRectGetMaxY(self.timeView.frame);
    }else
    {
        self.timeView.hidden = 1;
        iconY = 10;
    }
    self.timeSpt = kMssage.envelope.ct;
    UIImage *normalIm;
    if (kMssage.isMe) { //我
        iconX = screenW - padding - iconW;
        //头像
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:userModel.icon]
                         placeholderImage:[UIImage imageNamed:@"120"]];
        //昵称
        self.nameLab.text = userModel.nickname;
        //时间戳的转换时间
        //判断显示的时间
        NSString * showTitleTime = @"0";
        if (kMssage.envelope.ct.length == 13) {
            showTitleTime = [kMssage.envelope.ct substringToIndex:10];
        }
        else{
            showTitleTime = kMssage.envelope.ct;
        }
        NSDate *confromTimesp = [NSDate
                                 dateWithTimeIntervalSince1970:[showTitleTime longLongValue]];
        //判断显示的时间
        self.timeView.text = [confromTimesp formattedTime];
        
        normalIm = [self imageWithName:@"chat_自己"];
        [self.textView setBackgroundImage:normalIm forState:UIControlStateNormal];
        
        self.textView.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 15);
        self.pickImage.frame = CGRectMake(5, 5, 220, 220);
        self.voiceBackView.frame = CGRectMake(15, 10, 130, 35);
        self.voice.image = [UIImage imageNamed:@"chat_animation_white3"];
        self.voice.animationImages = [NSArray
                                      arrayWithObjects:[UIImage imageNamed:@"chat_animation_white1"],
                                      [UIImage imageNamed:@"chat_animation_white2"],
                                      [UIImage imageNamed:@"chat_animation_white3"], nil];
    } else {
        iconX = padding;
        [self.iconView
         sd_setImageWithURL:[NSURL URLWithString:kMssage.payload.attrs
                             .messageFromHeaderUrl]
         placeholderImage:[UIImage imageNamed:@"120"]];
        self.nameLab.text = kMssage.payload.attrs.messageFromNickName;
        NSDate *date = [NSDate
                        dateWithTimeIntervalSince1970:[kMssage.envelope.ct doubleValue] / 1000];
        self.timeView.text = [date minuteDescription];
        normalIm = [self imageWithName:@"chat_别人"];
        [self.textView setBackgroundImage:normalIm forState:UIControlStateNormal];
        self.textView.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 10);
        self.pickImage.frame = CGRectMake(15, 5, 220, 220);
        self.voiceBackView.frame = CGRectMake(25, 10, 130, 35);
        self.voice.image = [UIImage imageNamed:@"chat_animation3"];
        self.voice.animationImages =
        [NSArray arrayWithObjects:[UIImage imageNamed:@"chat_animation1"],
         [UIImage imageNamed:@"chat_animation2"],
         [UIImage imageNamed:@"chat_animation3"], nil];
    }
    if ([kMssage.envelope.from isEqualToString:@"qyqRobot@qiuyouzone.com/qiuyouzone"]) {
        [self.iconView setImage:[UIImage imageNamed:@"APP_Normal"]];
        
    }
    self.iconView.frame = CGRectMake(iconX, iconY, iconW, iconH);
    self.nameLab.frame =
    CGRectMake(iconX, CGRectGetMaxY(self.iconView.frame) + 5, iconW, 20);
    
    self.voiceBackView.hidden = YES;
    self.pickImage.hidden = YES;
    [self.textView setAttributedTitle:[[NSAttributedString alloc] initWithString:@""] forState:UIControlStateNormal];
    //正文的frame
    CGFloat textY = iconY;
    CGFloat textX;
    CGFloat bgBtnW;
    CGFloat bgBtnH;
    if (kMssage.payload.attrs.messageType != nil &&
        [kMssage.payload.attrs.messageType isEqualToString:@"text"]) {
        //文本
//        [self.textView setTitle:[ConvertToCommonEmoticonsHelper convertToSystemEmoticons:kMssage.payload.content]
//                       forState:UIControlStateNormal];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;// 字体的行间距
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:16],
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        [self.textView setAttributedTitle: [[NSAttributedString alloc] initWithString:[ConvertToCommonEmoticonsHelper convertToSystemEmoticons:kMssage.payload.content] attributes:attributes] forState:UIControlStateNormal];
        
        //真实的文字size
        CGSize textMaxSize = CGSizeMake(SCREEN_WIDTH - 2 * iconW - padding * 5, MAXFLOAT);
        CGSize textSize =
        [kMssage.payload.content sizeWithFont:LHtextFont andLineSpacing:5 maxSize:textMaxSize];
        //真实的按钮size
        
        CGSize btnSize = CGSizeMake(textSize.width + 25, textSize.height + 20);
        bgBtnW = btnSize.width;
        bgBtnH = btnSize.height;
        
    } else if (kMssage.payload.attrs.messageType != nil &&
               [kMssage.payload.attrs.messageType isEqualToString:@"image"]) {
        //图片
        //    bgBtnW = W(56);
        bgBtnW = 100 + 40;
        //    bgBtnH = H(80);
        bgBtnH = 100 + 30;
        self.pickImage.hidden = 0;
        self.pickImage.image = [self stringToImage:kMssage.payload.content];
        self.pickImage.layer.cornerRadius = 5;
        self.pickImage.layer.masksToBounds = YES;
        self.pickImage.contentMode = UIViewContentModeScaleAspectFill;
        self.pickImage.frame = CGRectMake(0, 0, bgBtnW, bgBtnH);
        [self makeMaskView:self.pickImage withImage:normalIm];
        
    } else if (kMssage.payload.attrs.messageType != nil &&
               [kMssage.payload.attrs.messageType isEqualToString:@"audio"]) {
        //语音
        bgBtnW = 120 + 40;
        bgBtnH = 20 + 30;
        self.voiceBackView.hidden = 0;
        self.second.text = [NSString stringWithFormat:@"%@''",kMssage.payload.attrs.messageAudioTime];
        if(!kMssage.isMe)
        {
            NSString *urlString = _kMssage.payload.attrs.messageImageUrlId;
            NSURL *audioUrl = [NSURL URLWithString:urlString];
            
            [[[NSURLSession sharedSession] downloadTaskWithURL:audioUrl completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                NSString *amrpath = [self GetPathByFileName:response.suggestedFilename ofType:@"amr"];
                NSString *wavpath = [self GetPathByFileName:response.suggestedFilename ofType:@"wav"];
                [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:amrpath error:NULL];
                if([VoiceConverter ConvertAmrToWav:amrpath wavSavePath:wavpath])
                {
                    wavData = [NSData dataWithContentsOfFile:wavpath];
                }
                
            }] resume];
        }else if(kMssage.isMe)
        {
            NSString *urlString = _kMssage.payload.attrs.messageImageUrlId;
            //          [NSString stringWithFormat:@"%@%@", Server_File_Host,_kMssage.payload.attrs.messageImageUrlId];
            NSURL *audioUrl = [NSURL URLWithString:urlString];
            
            [[[NSURLSession sharedSession] downloadTaskWithURL:audioUrl completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                
                
                NSString *amrpath = [self GetPathByFileName:response.suggestedFilename ofType:@"amr"];
                NSString *wavpath = [self GetPathByFileName:response.suggestedFilename ofType:@"wav"];
                [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:amrpath error:NULL];
                if([VoiceConverter ConvertAmrToWav:amrpath wavSavePath:wavpath])
                {
                    wavData = [NSData dataWithContentsOfFile:wavpath];
                }
                
            }] resume];
        }
    } else {
        //位置
        bgBtnW = 100;
        bgBtnH = 100;
        self.pickImage.hidden = 0;
        self.pickImage.frame = CGRectMake(15, 15, bgBtnW - 30, bgBtnH - 30);
        self.pickImage.contentMode = UIViewContentModeScaleAspectFit;
        self.pickImage.image = [UIImage imageNamed:@"map_located"];
    }
    if (kMssage.isMe) {
        textX = iconX - padding - bgBtnW;
    } else {
        textX = CGRectGetMaxX(self.iconView.frame) + padding;
    }
    self.textView.frame = CGRectMake(textX, self.iconView.centerY - 16, bgBtnW, bgBtnH);
    
    // cell的高度
    CGFloat textMaxY = CGRectGetMaxY(self.textView.frame);
    CGFloat iconMaxY = CGRectGetMaxY(self.nameLab.frame);
    self.cellH = MAX(textMaxY, iconMaxY) + padding + 14;
}
- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image {
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}
#pragma mark - 生成文件路径
- (NSString *)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(
                                                               NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileDirectory =
    [[[directory stringByAppendingPathComponent:_fileName]
      stringByAppendingPathExtension:_type]
     stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}

- (void)textViewClick {
    if (_kMssage.payload.attrs.messageType != nil &&
        [_kMssage.payload.attrs.messageType isEqualToString:@"geo"]) {
        _tapLocalImage(_kMssage.payload.attrs.messageGeoLat,
                       _kMssage.payload.attrs.messageGeoLng);
        return;
    } else if (_kMssage.payload.attrs.messageType != nil &&
               [_kMssage.payload.attrs.messageType isEqualToString:@"audio"]) {
        
        if(!self.contentVoiceIsPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            self.contentVoiceIsPlaying = YES;
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            //[audio playSongWithUrl:audioPath];
            
            [audio playSongWithData:wavData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
        
    } else if (_kMssage.payload.attrs.messageType != nil &&
               [_kMssage.payload.attrs.messageType isEqualToString:@"image"]) {
        NSMutableArray *photos = [NSMutableArray array];
        [photos addObject:_kMssage.payload.attrs.messageImageUrlId];
        HawkPhotoBrowser *hp = [[HawkPhotoBrowser alloc] init];
        hp.imageArray = photos;
        hp.currentIndex = 0;
        [hp show];
    }
}
//把图像缩放封装在一个方法里或分类里
- (UIImage *)imageWithName:(NSString *)name;
{
    UIImage *nam = [UIImage imageNamed:name];
    CGFloat w = nam.size.width * 0.5;
    CGFloat h = nam.size.height * 0.8;
    //图像放大
    return [nam resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w)];
}
- (UIImage *)stringToImage:(NSString *)imageString {
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:imageString
                                      options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:nsdataFromBase64String];
    
    return decodedImage;
}
- (void)UUAVAudioPlayerBeiginLoadVoice
{
    [self benginLoadVoice];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self didLoadVoice];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    self.contentVoiceIsPlaying = NO;
    [self stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}
- (void)benginLoadVoice
{
    self.voice.hidden = YES;
    [self.indicator startAnimating];
}
- (void)didLoadVoice
{
    self.voice.hidden = NO;
    [self.indicator stopAnimating];
    [self.voice startAnimating];
}
-(void)stopPlay
{
    //    if(self.voice.isAnimating){
    [self.voice stopAnimating];
    //    }
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        // NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        // NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
