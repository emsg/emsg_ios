//
//  QYQChatController.m
//  EmsClientDemo
//
//  Created by 球友圈 on 15/9/23.
//  Copyright (c) 2015年 cyt. All rights reserved.
//

#import "QYQChatController.h"
#import "QYQChatCell.h"
#import "NSString+Message.h"
#import "QYQMessageManagerFaceView.h"
#import "QYQMessageShareMenuView.h"
#import "ZBMessageTextView.h"
#import "DXFaceView.h"
#import "EMsgMessage.h"
#import "EMDEngineManger.h"
#import "MJExtension.h"
#import "UploadFile.h"
#import "NSDate+Category.h"
#import "FMDBManger.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceConverter.h"
#import "DXRecordView.h"
#import "SRRefreshView.h"
#import "UUAVAudioPlayer.h"
#import "UIImage+Extension.h"

@interface QYQChatController () <
UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate,
ZBMessageShareMenuViewDelegate, DXFaceDelegate,SRRefreshDelegate> {
    double animationDuration; //键盘的移动时间
    CGRect keyboardRect;      //键盘的frame
    CGRect sendBeforFrame;
    NSMutableArray *chatArray; //数据源数组
    EMDEngineManger *engine;        // scoket通讯类
    NSInteger playTime;
    NSTimer *playTimer;
    BOOL isFirstIn;
}
@property(nonatomic, strong) EMsgMessage *emsg;
@property(nonatomic, strong) DXRecordView *recorderView;
@property(nonatomic, strong) NSMutableArray *modelArray;
@property(nonatomic, weak) UITableView *mainTab;
@property(nonatomic, strong) ZBMessageTextView *textV;
@property(nonatomic, strong) UIButton *holdDownButton;
@property(nonatomic, strong) UIButton *soundButton;
@property(nonatomic, strong) UIButton *photoButton;
@property(nonatomic, strong) UIButton *MenuButton;
@property(nonatomic, strong) UIImageView *sendView;
@property(nonatomic, assign) CGFloat TextViewContentHeight;

@property(nonatomic, strong) QYQMessageShareMenuView *shareMenuView;
@property(nonatomic, assign) CGFloat previousTextViewContentHeight;
@property(nonatomic, strong) DXFaceView *faceView;
@property(nonatomic, assign) BOOL show;
@property(nonatomic, strong) NSString *chatterID;
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong,nonatomic) NSString * loadMessageIndexString;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) CGRect endFrame;
@property (nonatomic, weak) UITapGestureRecognizer *tap;

/**
 *  文字输入区域最大高度，必须 > KInputTextViewMinHeight(最小高度)并且 <
 * KInputTextViewMaxHeight，否则设置无效
 */
@property(nonatomic) CGFloat maxTextInputViewHeight;

@property(retain, nonatomic) AVAudioRecorder *recorder;
@property(strong, nonatomic) AVAudioPlayer *player;

@property(copy, nonatomic) NSString *originWav; //原wav文件名
@property(nonatomic, copy) NSString *recordFileName;
@property(nonatomic, copy) NSString *recordFilePath;

@end

@implementation QYQChatController
#define With [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self leftNavClick];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)leftNavClick{
    [self updateDB];
   UUAVAudioPlayer * audio = [UUAVAudioPlayer sharedInstance];
    if (audio) {
        [audio stopSound];
    }
}

- (void)updateDB{
    if (chatArray.count > 0) {
        EMsgMessage * lastMessage = [chatArray lastObject];
        lastMessage.unReadCountStr = @"0";
        
        EMsgMessage * storeMessage = lastMessage;
        if (lastMessage.isMe == YES) {
            storeMessage.envelope.from = lastMessage.envelope.to;
            storeMessage.envelope.to = lastMessage.envelope.from;
            EMsgAttrs *attrs = [[EMsgAttrs alloc] init];
            if(self.infoDic[@"toAge"])
            {
                attrs.messageFromAge = self.infoDic[@"toAge"];
            }if(self.infoDic[@"toSex"])
            {
                attrs.messageFromSex = self.infoDic[@"toSex"];
            }if(self.infoDic[@"toName"])
            {
                attrs.messageFromNickName = self.infoDic[@"toName"];
            }if(self.infoDic[@"toPhoto"])
            {
                attrs.messageFromHeaderUrl = self.infoDic[@"toPhoto"];
            }
            if (self.isGroup == YES) {
                if (self.infoDic[@"groupUrl"]) {
                    attrs.messageGroupUrl = self.infoDic[@"groupUrl"];
                }
                if (self.infoDic[@"groupNickName"]) {
                    attrs.messageGroupName = self.infoDic[@"groupNickName"];
                }
                storeMessage.envelope.from = [NSString stringWithFormat:@"%@@",_kChatter];
            }

            attrs.messageType = lastMessage.payload.attrs.messageType;
            storeMessage.payload.attrs = attrs;
        }
        
        [self storeSingleMessage:storeMessage];
    }
    //通知刷新tabbarBadge
    
    NSNotification *notification =
    [NSNotification notificationWithName:UPDATE_BADGE
                                  object:nil
                                userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/*存储单条消息*/
- (void)storeSingleMessage:(EMsgMessage *)storeMessage{
    
    ZXUser * userInfo = [ZXCommens fetchUser];
    if (userInfo.uid) {
        //把消息存入数据库
        NSRange checkStrRange = [storeMessage.envelope.from rangeOfString:@"@"];
            NSString * chatterId = [storeMessage.envelope.from substringToIndex:checkStrRange.location];
            if (self.isGroup == YES) {
                chatterId = self.kChatter;
           }
            //如果不是系统消息，执行下面的操作
            NSMutableArray * resultArray = [[NSMutableArray alloc] init];
            resultArray = [[FMDBManger shareInstance] fetchAllSelReslult];
            //判断临时会话列表数据表中是否有这条数据
            BOOL isExitInChatList = NO;
            //存在的消息，更新
            for (EMsgMessage * msg in resultArray) {
                if ([msg.chatId isEqualToString:[NSString stringWithFormat:@"%@%@",userInfo.uid,chatterId]]) {
                    isExitInChatList = YES;
                    break;
                }
            }
            //如果数据库查询不到，说明也是首次
            if (resultArray.count == 0) {
                isExitInChatList = NO;
            }
            //如果存在，在消息数据表里插入一条数据
            if (isExitInChatList) {
                [[FMDBManger shareInstance] updateOneChatListMessageWithChatter:chatterId andMessage:storeMessage];
            }
            //如果不存在
            else{
                [[FMDBManger shareInstance] insertOneChatList:storeMessage withChatter:chatterId];
            }
    }
}

- (void)keyBoardHide {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sendView.frame =
                         CGRectMake(0, self.view.height - self.sendView.height,
                                    self.sendView.width, self.sendView.height);
                         self.mainTab.frame = CGRectMake(0, 0, self.view.width, self.sendView.y);
                         self.faceView.frame = CGRectMake(0, self.view.height, self.view.width,
                                                          self.faceView.height);
                         
                         self.shareMenuView.frame = CGRectMake(
                                                               0, self.view.height, self.view.width, self.shareMenuView.height);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.recorderView == nil)
    {
        self.recorderView = [[DXRecordView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-150)*0.5, SCREEN_HEIGHT*0.5 - 150,150, 150)];
        self.recorderView.hidden = 1;
        [self.view addSubview:self.recorderView];
    }
    //键盘的变化通知
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardChange:)
     name:UIKeyboardDidChangeFrameNotification
     object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)dealloc {
    
    _slimeView.delegate = nil;
    _slimeView = nil;
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardWillHideNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIKeyboardDidChangeFrameNotification
     object:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    isFirstIn = NO;
    _loadMessageIndexString = @"0";
    chatArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataFromDB) name:NEW_MESSAGE object:nil];
    engine = [EMDEngineManger sharedInstance];
    self.player = [[AVAudioPlayer alloc] init];
    [self makeChatter];
    [self setupViews];
    if (!isFirstIn) {
        isFirstIn = YES;
        [self firstReloadDateFromeDb1];
    }
}

- (void)setupViews{
    //主视图
    UITableView *mainTab = [[UITableView alloc]
                            initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 64)
                            style:UITableViewStylePlain];
    mainTab.delegate = self;
    mainTab.dataSource = self;
    mainTab.tableFooterView = [[UIView alloc] init];
    //表格设置
    mainTab.backgroundColor = BASE_VC_COLOR;
    mainTab.separatorStyle = UITableViewCellSeparatorStyleNone; //去除分割线
    mainTab.allowsSelection = NO;                               //不允许选中
    self.mainTab = mainTab;
    //添加刷新
    [self.mainTab addSubview:self.slimeView];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(keyBoardHide)];
    [mainTab addGestureRecognizer:tap];
    self.tap = tap;
    [self.view addSubview:mainTab];
    
    //底部发送消息
    UIImageView *sendView = [[UIImageView alloc] init];
    sendView.userInteractionEnabled = YES;
    sendView.frame = CGRectMake(0, CGRectGetMaxY(mainTab.frame), SCREEN_WIDTH, 40);
    sendView.image = [UIImage imageNamed:@"chat_bottom_bg"];
    self.sendView = sendView;
    sendBeforFrame = sendView.frame;
    
    if (self.isSystemMessage == NO) {
        [self.view addSubview:sendView];
    }
    
    //录音按钮
    UIButton *soundButton = [[UIButton alloc] init];
    soundButton.frame = CGRectMake(5, (sendView.height - 30) * 0.5, 30, 30);
    [soundButton addTarget:self
                    action:@selector(soundClick:)
          forControlEvents:UIControlEventTouchUpInside];
    [soundButton setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboard"]
                           forState:UIControlStateNormal];
    [soundButton
     setBackgroundImage:[UIImage imageNamed:@"ToolViewInputVoice"]
     forState:UIControlStateSelected];
    [soundButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    self.soundButton = soundButton;
    [sendView addSubview:soundButton];
    
    //文本编辑框
    ZBMessageTextView *textV = [[ZBMessageTextView alloc] init];
    textV.frame = CGRectMake(CGRectGetMaxX(soundButton.frame) + 5,
                             (sendView.height - 30) * 0.5,
                             SCREEN_WIDTH - 125, 30);
    self.TextViewContentHeight = textV.contentSize.height;
    textV.font = [UIFont systemFontOfSize:15];
    textV.returnKeyType = UIReturnKeySend;
    textV.layer.borderWidth = 1;
    textV.layer.cornerRadius = 5;
    textV.layer.borderColor = RGBACOLOR(179, 181, 186,1).CGColor;
    textV.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    textV.placeHolder = @"";
    textV.delegate = self;
    self.textV = textV;
    textV.hidden = 1;
    [sendView addSubview:textV];
    
    //发语音按钮RGBACOLOR
    UIButton *holdDownButton = [[UIButton alloc] init];
    holdDownButton.frame =
    CGRectMake(CGRectGetMaxX(soundButton.frame) + 5, 5, SCREEN_WIDTH - 125,30);
    [holdDownButton setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(242, 242, 245,1)]
                              forState:UIControlStateNormal];
    [holdDownButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [holdDownButton setTitleColor:QYQCOLOR(68, 68, 68) forState:UIControlStateNormal];
    [holdDownButton setBackgroundImage:[UIImage imageWithColor:QYQCOLOR(195, 196, 199)] forState:UIControlStateHighlighted];
    holdDownButton.layer.borderWidth = 1;
    holdDownButton.layer.cornerRadius = 5;
    holdDownButton.layer.borderColor = QYQCOLOR(179, 181, 186).CGColor;
    holdDownButton.adjustsImageWhenHighlighted = NO;
    holdDownButton.layer.masksToBounds = YES;
    
    self.holdDownButton = holdDownButton;
    [holdDownButton addTarget:self
                       action:@selector(beginRecordVoice:)
             forControlEvents:UIControlEventTouchDown];
    [holdDownButton addTarget:self
                       action:@selector(endRecordVoice:)
             forControlEvents:UIControlEventTouchUpInside];
    [holdDownButton addTarget:self
                       action:@selector(cancelRecordVoice:)
             forControlEvents:UIControlEventTouchUpOutside |
     UIControlEventTouchCancel];
    [holdDownButton addTarget:self
                       action:@selector(RemindDragExit:)
             forControlEvents:UIControlEventTouchDragExit];
    [holdDownButton addTarget:self
                       action:@selector(RemindDragEnter:)
             forControlEvents:UIControlEventTouchDragEnter];
    [sendView addSubview:holdDownButton];
    
    //表情
    UIButton *photoButton = [[UIButton alloc] init];
    photoButton.frame = CGRectMake(CGRectGetMaxX(textV.frame) + 10,
                                   (sendView.height -30) * 0.5, 30, 30);
    [photoButton setBackgroundImage:[UIImage imageNamed:@"ToolViewEmotion"]
                           forState:UIControlStateNormal];
    [photoButton setBackgroundImage:[UIImage imageNamed:@"ToolViewKeyboard"]
                           forState:UIControlStateSelected];
    [photoButton setTitleColor:[UIColor blackColor]
                      forState:UIControlStateNormal];
    [photoButton addTarget:self
                    action:@selector(photoClick:)
          forControlEvents:UIControlEventTouchUpInside];
    self.photoButton = photoButton;
    [sendView addSubview:photoButton];
    
    //菜单按钮
    UIButton *MenuButton = [[UIButton alloc] init];
    MenuButton.frame = CGRectMake(CGRectGetMaxX(photoButton.frame) + 10,
                                  (sendView.height - 30) * 0.5, 30, 30);
    [MenuButton
     setBackgroundImage:[UIImage imageNamed:@"TypeSelectorBtn_Black_ios7"]
     forState:UIControlStateNormal];
    [MenuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [MenuButton addTarget:self
                   action:@selector(showMenuClick:)
         forControlEvents:UIControlEventTouchUpInside];
    self.MenuButton = MenuButton;
    [sendView addSubview:MenuButton];
    
    //表情视图
    self.faceView = [[DXFaceView alloc]
                     initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                              CGRectGetWidth(self.view.frame), 196)];
    self.faceView.delegate = self;
    [self.view addSubview:self.faceView];
    
    //菜单视图
    self.shareMenuView = [[QYQMessageShareMenuView alloc]
                          initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                                   CGRectGetWidth(self.view.frame), 196)];
    [self.view addSubview:self.shareMenuView];
    self.shareMenuView.delegate = self;
    ZBMessageShareMenuItem *sharePicItem = [[ZBMessageShareMenuItem alloc]
                                            initWithNormalIconImage:[UIImage imageNamed:@"sharemore_pic_ios7"]
                                            title:@"照片"];
    ZBMessageShareMenuItem *shareVideoItem = [[ZBMessageShareMenuItem alloc]
                                              initWithNormalIconImage:[UIImage imageNamed:@"sharemore_video_ios7"]
                                              title:@"拍摄"];
    ZBMessageShareMenuItem *shareLocItem = [[ZBMessageShareMenuItem alloc]
                                            initWithNormalIconImage:[UIImage imageNamed:@"sharemore_location_ios7"]
                                            title:@"位置"];

    self.shareMenuView.shareMenuItems =
    [NSArray arrayWithObjects:sharePicItem, shareVideoItem, shareLocItem, nil];
    [self.shareMenuView reloadData];

}



#pragma mark ==
#pragma mark === 刷新数据库的数据

- (void)firstReloadDateFromeDb{
    //取2100年时间戳
    NSMutableArray * request = [[FMDBManger shareInstance] loadOneChatMessage:@"4102419661000" withChatter:_kChatter limite:10];
    NSMutableArray * arr = [ZXCommens sortArray:request];
    if (arr.count > 0) {
        EMsgMessage * message = [arr lastObject];
        _loadMessageIndexString = message.storeId;
    }
    chatArray = request;
    [self.mainTab reloadData];
    [self scrollToEndrow];
    
}

- (void)firstReloadDateFromeDb1{
    [[FMDBManger shareInstance] loadOneChatMessage:@"4102419661000" withChatter:_kChatter limite:10 withResult:^(NSMutableArray *resultArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray * arr = [ZXCommens sortArray:resultArray];
        if (arr.count > 0) {
            EMsgMessage * message = [arr lastObject];
            _loadMessageIndexString = message.storeId;
        }
        chatArray = resultArray;
        [self.mainTab reloadData];
            [self scrollToEndrow];
        });
    }];
}

- (void)reloadDataFromDB{
    if ([_loadMessageIndexString isEqualToString:@"0"]) {
        [self firstReloadDateFromeDb1];
        return;
    }
    NSMutableArray * request = [[FMDBManger shareInstance] fetchOneChatMessage:_loadMessageIndexString withChatter:_kChatter];
    chatArray = request;
    
    [self.mainTab reloadData];
    [self scrollToEndrow];
    
}

- (void)loadDbMessage{
    NSInteger oldCount = chatArray.count;
    NSInteger newCount = 0;
    
    
    NSMutableArray * request = [[FMDBManger shareInstance] loadOneChatMessage:_loadMessageIndexString withChatter:_kChatter limite:10];
    
    if (request.count <= 0) {
        return;
    }
    
    NSMutableArray * loadIndexArray = [ZXCommens sortArray:request];
    EMsgMessage * message = [loadIndexArray lastObject];
    _loadMessageIndexString = message.storeId;
    
    [request addObjectsFromArray:chatArray];
    [chatArray removeAllObjects];
    chatArray = request;
    newCount = chatArray.count;
    
    
    [self.mainTab reloadData];
    [self.mainTab
     scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:newCount - oldCount
                                               inSection:0]
     atScrollPosition:UITableViewScrollPositionTop
     animated:NO];
}


- (void)startRecord {
    //根据当前时间生成文件名
    self.recordFileName = [self GetCurrentTimeString];
    //获取路径
    self.recordFilePath =
    [self GetPathByFileName:self.recordFileName ofType:@"wav"];
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]
                     initWithURL:[NSURL fileURLWithPath:self.recordFilePath]
                     settings:[VoiceConverter GetAudioRecorderSettingDict]
                     error:nil];
    self.recorder.meteringEnabled = YES;
    
    //准备录音
    if ([self.recorder prepareToRecord]) {
        
        NSError *sessionError;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self.recorder record];
    }
}
#pragma mark - 生成当前时间字符串
- (NSString *)GetCurrentTimeString {
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
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

- (void)beginRecordVoice:(UIButton *)button {
    //开始录音
    [self startRecord];
    //显示录音界面
    self.recorderView.hidden = 0;
    //开起定时器
    playTime = 0;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(updateMeters)
                                               userInfo:nil
                                                repeats:YES];
}
#pragma mark - 更新音频峰值
- (void)updateMeters{
    if (self.recorder.isRecording){
        
        //更新峰值
        [self.recorder updateMeters];
        double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
        [self.recorderView setVoiceImageWith:lowPassResults];
        //        NSLog(@"峰值:%f",lowPassResults);
        //倒计时
        //        if (playTime >= 50 && playTime < 60) {
        //            //剩下10秒
        //            self.recorderView.textLabel.text = [NSString stringWithFormat:@"录音剩下:%d秒",(int)(60-playTime)];
        //        }else if (playTime >= 60){
        //            //时间到
        //            [self endRecordVoice:nil];
        //        }
        playTime += 1.0f;
    }
}

- (void)stopRecord {
    double cTime = self.recorder.currentTime;
    [self.recorder stop];
    if (cTime > 1) {
        //      self.recorderView.textLabel.text = @"手指上滑，取消发送";
        [self audio_WAVtoAMR];
    } else {
        [self.recorder deleteRecording];
        self.recorderView.textLabel.text = @"说话时间太短";
    }
    self.recorderView.hidden = 1;
}
- (void)audio_WAVtoAMR {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.recordFilePath forKey:@"voicePath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //开始转换格式
    NSString *amrPath =
    [self GetPathByFileName:self.recordFileName ofType:@"amr"];
    if ([VoiceConverter ConvertWavToAmr:self.recordFilePath
                            amrSavePath:amrPath]) {
        [[UploadFile sharedUploadFile] uploadAudio:amrPath block:^(NSDictionary *audioDict) {
            if([audioDict[@"success"] intValue] == 1)
            {
                [self sendVoiceWithAudioId:audioDict[@"entity"][@"id"] time:[NSString stringWithFormat:@"%ld",playTime/10+1]];
            }
        }];
    }
}

#pragma mark -- 发送语音

- (void)sendVoiceWithAudioId:(NSString *)audioId time:(NSString *)audioTime
{
    
    if ([engine isAuthed]) {
        EMsgMessage *msg = [[EMsgMessage alloc] init];
        msg.isMe = YES;
        EMsgPayload *payload = [[EMsgPayload alloc] init];
        EMsgEnvelope *envelope = [[EMsgEnvelope alloc] init];
        
        NSString *timeSp = [NSString
                            stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        
        envelope.ct = timeSp;
        
        EMsgAttrs *attrs = [[EMsgAttrs alloc] init];
        attrs.messageType = MSG_TYPE_AUDIO;
        if (self.isGroup) {
            attrs.messageGroupName = self.infoDic[@"groupNickName"];
            attrs.messageGroupUrl = self.infoDic[@"groupUrl"];
        }
        attrs.messageImageUrlId = [NSString stringWithFormat:@"%@%@",Server_File_Host,audioId];
        attrs.messageAudioTime = audioTime;
        payload.attrs = attrs;
        msg.payload = payload;
        msg.envelope = envelope;
        [self isShowDateLabelWithMsg:msg timeSp:timeSp];
        [engine sendMessageWithToId:_chatterID
                     withTargetType:self.isGroup == YES ? GROUPCHAT : SINGLECHAT
                              isAck:YES
                        withContent:[NSString stringWithFormat:@"%@%@",Server_File_Host,audioId]
                          withAttrs:[attrs mj_keyValues]
                    withMessageMark:arc4random()];
        
        [self reloadDataFromDB];
    }else{
        [self showHint:@"连接断开,正在重连"];
        [self autoLoginMsgCilent];
    }
}
- (void)endRecordVoice:(UIButton *)button {
    if (playTimer) {
        [self stopRecord];
        [playTimer invalidate];
        playTimer = nil;
    }
}

- (void)cancelRecordVoice:(UIButton *)button {
    if (playTimer) {
        [self.recorder stop];
        self.recorderView.hidden = 1;
        [self.recorder deleteRecording];
        [playTimer invalidate];
        playTimer = nil;
    }
    //    [UUProgressHUD dismissWithError:@"Cancel"];
    self.recorderView.recordAnimationView.hidden = 0;
    self.recorderView.deleView.hidden = 1;
    self.recorderView.textLabel.text = @"手指上滑，取消发送";
}

- (void)RemindDragExit:(UIButton *)button {
    self.recorderView.recordAnimationView.hidden = 1;
    self.recorderView.deleView.hidden = 0;
    self.recorderView.textLabel.text = @"松开手指，取消发送";
    //    [UUProgressHUD changeSubTitle:@"Release to cancel"];
}

- (void)RemindDragEnter:(UIButton *)button {
    //    [UUProgressHUD changeSubTitle:@"Slide up to cancel"];
    self.recorderView.recordAnimationView.hidden = 0;
    self.recorderView.deleView.hidden = 1;
    self.recorderView.textLabel.text = @"手指上滑，取消发送";
}

- (void)makeChatter {
    
    //单聊
    if (self.isGroup == NO) {
        ZXUser *userInfoModel = [ZXCommens fetchUser];
        _chatterID = [NSString
                      stringWithFormat:@"%@@%@", _kChatter, userInfoModel.domain];
    }
    //群聊
    else{
        _chatterID = [_kChatter substringFromIndex:5];
    }

}

#pragma mark - textViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    self.endFrame = self.sendView.frame;
    //    NSString *newStr = self.textV.text;
    //    NSString *temp = nil;
    //    for(int i =0; i < [newStr length]; i++)
    //    {
    //        temp = [newStr substringWithRange:NSMakeRange(i, 1)];
    //        NSLog(@"第%d个字是:%@",i,temp);
    //    }
    UIFont *font=[UIFont systemFontOfSize:13];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    //文本区域的宽度
    float extraHeight=0;
    float textWidth=self.textV.width - 2                                                                                                                                                                                                                                                                                                                ;
    
    CGRect rect=[self.textV.text boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil];
    extraHeight=rect.size.height;
    extraHeight+=18;//文本框的实际需要的高度
    if(extraHeight>=130) return;
    if(self.previousTextViewContentHeight == extraHeight) return;
    
    self.textV.frame=CGRectMake(self.textV.frame.origin.x, self.textV.frame.origin.y, self.textV.frame.size.width, extraHeight);
    CGRect inputViewFrame = self.sendView.frame;
    if(self.previousTextViewContentHeight)
    {
        if(self.previousTextViewContentHeight<=extraHeight)
        {
            self.sendView.frame =
            CGRectMake(0.0f, inputViewFrame.origin.y-19,
                       inputViewFrame.size.width,
                       extraHeight + 10);
        }else
        {
            self.sendView.frame =
            CGRectMake(0.0f, inputViewFrame.origin.y+19,
                       inputViewFrame.size.width,
                       extraHeight + 10);
        }
        
        self.mainTab.transform =
        CGAffineTransformMakeTranslation(0, -(self.sendView.height - 40));
    }
    
    self.previousTextViewContentHeight = extraHeight;
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [textView becomeFirstResponder];
    [self messageViewAnimationWithMessageRect:keyboardRect
                     withMessageInputViewRect:self.sendView.frame
                                  andDuration:animationDuration
                                     andState:ZBMessageViewStateShowNone];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendFace];
        return NO;
    }
    return YES;
}
#pragma mark - 菜单视图按钮的回调
- (void)didSelecteShareMenuItem:(ZBMessageShareMenuItem *)shareMenuItem
                        atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self sendImage]; //发图片
            break;
        case 1:
            [self takePhoto]; //拍照
            break;
        case 2:
            [self sendGeoMessage]; //发位置
            break;
        case 3:
            //
            break;
            
        default:
            break;
    }
}
#pragma mark - 表情视图按钮的回调
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete {
    NSString *chatText = self.textV.text;
    
    if (!isDelete && str.length > 0) {
        self.textV.text = [NSString stringWithFormat:@"%@%@", chatText, str];
        if (self.textV.text.length == 2) {
            //            self.previousTextViewContentHeight = 36;
        }
    } else {
        if (chatText.length >= 2) {
            NSString *subStr = [chatText substringFromIndex:chatText.length - 2];
            if ([(DXFaceView *)self.faceView stringIsFace:subStr]) {
                self.textV.text = [chatText substringToIndex:chatText.length - 2];
                [self textViewDidChange:self.textV];
                return;
            }
        }
        
        if (chatText.length > 0) {
            self.textV.text = [chatText substringToIndex:chatText.length - 1];
        }
    }
    
    [self textViewDidChange:self.textV];
}
- (void)isShowDateLabelWithMsg:(EMsgMessage *)msg timeSp:(NSString *)timeSp
{
    if(chatArray.count>0)
    {
        EMsgMessage *lastEM = [chatArray lastObject];
        NSDate *startDate;
        if(lastEM.isMe)
        {
            
            //时间戳的转换时间
            startDate = [NSDate
                         dateWithTimeIntervalSince1970:[lastEM.envelope.ct longLongValue] / 1000];
            
        }else
        {
            //时间戳的转换时间
            startDate = [NSDate
                         dateWithTimeIntervalSince1970:[lastEM.envelope.ct doubleValue] / 1000];
        }
        NSDate *endDate = [NSDate
                           dateWithTimeIntervalSince1970:[timeSp longLongValue]];
        
        //这个是相隔的秒数
        NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:startDate];
        NSLog(@"sj%f",timeInterval);
        //相距5分钟显示时间Label
        if (fabs (timeInterval) > 1*60) {
            msg.payload.attrs.isShowTimelabel = YES;
            msg.showDateLabel = YES;
        }else{
            msg.payload.attrs.isShowTimelabel = NO;
            msg.showDateLabel = NO;
        }
    }else
    {
        msg.payload.attrs.isShowTimelabel = YES;
        msg.showDateLabel = YES;
    }
    
}

#pragma mark 重链接服务器
- (void)autoLoginMsgCilent {
    ZXUser *userInfoModel = [ZXCommens fetchUser];
    if (userInfoModel.token) {
        //异步登陆账号
        if (![engine isAuthed]) {
            NSString *username =
            [NSString stringWithFormat:@"%@@%@/%@", userInfoModel.uid,
             userInfoModel.domain,
             [ZXCommens creatMSTimastmap]];
            
            BOOL successed =
            [engine auth:username
            withPassword:userInfoModel.token
                withHost:userInfoModel.host
                withPort:[userInfoModel.port integerValue]];
            
            if (successed) //连接成功
            {
                
            }
            else { //连接失败
                [engine autoReconnect];
            }
        }
    }
}

#pragma mark - 发送文本
- (void)sendFace {
    self.textV.height = 30;
    self.sendView.transform = CGAffineTransformMakeTranslation(0, self.previousTextViewContentHeight - 30);
    self.sendView.height = 40;
    self.mainTab.transform =
    CGAffineTransformMakeTranslation(0, -(self.sendView.height - 43));
    
    if ([engine isAuthed]) {
        if ([self.textV.text isEqualToString:@""]) {
            [self showHint:@"输入内容不能为空"];
            return;
        }
        
        EMsgMessage *msg = [[EMsgMessage alloc] init];
        msg.isMe = YES;
        EMsgEnvelope *envelope = [[EMsgEnvelope alloc] init];
        
        NSString *timeSp = [NSString
                            stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        
        envelope.ct = timeSp;
        
        EMsgPayload *payload = [[EMsgPayload alloc] init];
        payload.content = self.textV.text;
        EMsgAttrs *attrs = [[EMsgAttrs alloc] init];
        
        attrs.messageType = MSG_TYPE_TEXT;
        
        if (self.isGroup) {
            attrs.messageGroupName = self.infoDic[@"groupNickName"];
            attrs.messageGroupUrl = self.infoDic[@"groupUrl"];
        }
        
        payload.attrs = attrs;
        msg.payload = payload;
        msg.envelope = envelope;
        [self scrollToEndrow];
        [self isShowDateLabelWithMsg:msg timeSp:timeSp];

        
        NSMutableDictionary * attrsDic = [[NSMutableDictionary alloc] initWithDictionary:[msg.payload.attrs mj_keyValues]];
        [engine sendMessageWithToId:_chatterID
                     withTargetType:self.isGroup == YES ? GROUPCHAT : SINGLECHAT
                              isAck:YES
                        withContent:self.textV.text
                          withAttrs:attrsDic
                    withMessageMark:arc4random()];
        [self reloadDataFromDB];
        self.textV.text = @"";
        
    } else {
        [self showHint:@"连接断开,正在重连"];
        [self autoLoginMsgCilent];
    }
}
#pragma mark - 发送位置
- (void)sendGeoMessage {

    if ([engine isAuthed]) {
        EMsgMessage *msg = [[EMsgMessage alloc] init];
        msg.isMe = YES;
        EMsgPayload *payload = [[EMsgPayload alloc] init];
        payload.content = @"你收到一条位置消息";
        EMsgAttrs *attrs = [[EMsgAttrs alloc] init];
        attrs.messageType = MSG_TYPE_GEO;
        if (self.isGroup) {
            attrs.messageGroupName = self.infoDic[@"groupNickName"];
            attrs.messageGroupUrl = self.infoDic[@"groupUrl"];
        }

        attrs.messageGeoLat = [NSString stringWithFormat:@"%f",35.f];
        attrs.messageGeoLng = [NSString stringWithFormat:@"%f",118.f];
        
        
        payload.attrs = attrs;
        msg.payload = payload;
        NSString *timeSp = [NSString
                            stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        [self isShowDateLabelWithMsg:msg timeSp:timeSp];

        [engine sendMessageWithToId:_chatterID
                     withTargetType:self.isGroup == YES ? GROUPCHAT : SINGLECHAT
                              isAck:YES
                        withContent:payload.content
                          withAttrs:[attrs mj_keyValues]
                    withMessageMark:arc4random()];
        [self reloadDataFromDB];
    }
    else{
        [self showHint:@"连接断开,正在重连"];
        [self autoLoginMsgCilent];
    }
}
#pragma mark - 发送图片
- (void)sendImage {
    //图片选择器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePicker.allowsEditing = YES;
    [self.navigationController presentViewController:imagePicker
                                            animated:YES
                                          completion:^{
                                          }];
}
- (void)takePhoto {
    UIImagePickerControllerSourceType souceType =
    UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;    //拍照后的照片可以呗编辑
        picker.sourceType = souceType; //相机类型
        [self presentViewController:picker
                           animated:YES
                         completion:^{
                         }];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}
- (NSString *)imageDataToString:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data
                                 base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodedImageStr;
}
- (void)sendImageMessage:(UIImage *)image withImageId:(NSString *)urlId {

    
    if ([engine isAuthed]) {
        EMsgMessage *msg = [[EMsgMessage alloc] init];
        msg.isMe = YES;
        EMsgPayload *payload = [[EMsgPayload alloc] init];
        payload.content = [self imageDataToString:image];
        EMsgEnvelope *envelope = [[EMsgEnvelope alloc] init];
        
        NSString *timeSp = [NSString
                            stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        
        envelope.ct = timeSp;
        
        EMsgAttrs *attrs = [[EMsgAttrs alloc] init];
        attrs.messageType = MSG_TYPE_IMG;
        if (self.isGroup) {
            attrs.messageGroupName = self.infoDic[@"groupNickName"];
            attrs.messageGroupUrl = self.infoDic[@"groupUrl"];
        }
        attrs.messageImageUrlId = urlId;
        payload.attrs = attrs;
        msg.payload = payload;
        msg.envelope = envelope;

        [self isShowDateLabelWithMsg:msg timeSp:timeSp];
        [engine sendMessageWithToId:_chatterID
                     withTargetType:self.isGroup == YES ? GROUPCHAT : SINGLECHAT
                              isAck:YES
                        withContent:[self imageDataToString:image]
                          withAttrs:[attrs mj_keyValues]
                    withMessageMark:arc4random()];
        [self reloadDataFromDB];
    }
    else{
        [self showHint:@"连接断开,正在重连"];
        [self autoLoginMsgCilent];
    }
}
/**
 *  实现图片压缩，改变了图片的size。
 *  @param srcImage   需要压缩的图片
 *  @param imageScale 压缩比例
 *
 *  @return
 */
- (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage
                              scale:(double)imageScale {
    UIImage *thumbnail = nil;
    CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale,
                                  srcImage.size.height * imageScale);
    if (srcImage.size.width != imageSize.width ||
        srcImage.size.height != imageSize.height) {
        UIGraphicsBeginImageContext(imageSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [srcImage drawInRect:imageRect];
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        thumbnail = srcImage;
    }
    return thumbnail;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block UIImage *image =
    [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *uploadToServerImage = [self makeThumbnailFromImage:image scale:0.2];
    
    [[UploadFile sharedUploadFile] uploadImage:image
                                   resultBlock:^(NSDictionary *result) {
                                       if ([result[@"success"] intValue] == 1) {
                                           NSString *imageId =
                                           [NSString stringWithFormat:@"%@%@", Server_File_Host,
                                            result[@"entity"][@"id"]];
                                           [self sendImageMessage:uploadToServerImage withImageId:imageId];
                                       }
                                   }
                                    upProgress:^(float progress) {
                                        
                                    }];
    
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                               }];
    
    
}

#pragma mark - 键盘通知事件
- (void)keyboardWillHide:(NSNotification *)notification {
    
    keyboardRect = [[notification.userInfo
                     objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo
                          objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sendView.frame =
                         CGRectMake(0, self.view.height - self.sendView.height,
                                    self.sendView.width, self.sendView.height);
                         self.mainTab.frame = CGRectMake(0, 0, self.view.width, self.sendView.y);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    keyboardRect = [[notification.userInfo
                     objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    animationDuration = [[notification.userInfo
                          objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (void)keyboardChange:(NSNotification *)notification {
      if ([[notification.userInfo
               objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
              .origin.y < CGRectGetHeight(self.view.frame)) {
    
        [self messageViewAnimationWithMessageRect:
                  [[notification.userInfo
                      objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:0.25
                                         andState:ZBMessageViewStateShowNone];
      }
}

#pragma mark - 动画事件统一处理
- (void)messageViewAnimationWithMessageRect:(CGRect)rect
                   withMessageInputViewRect:(CGRect)inputViewRect
                                andDuration:(double)duration
                                   andState:(ZBMessageViewState)state {
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.sendView.frame = CGRectMake(
                                                          0, self.view.height - CGRectGetHeight(rect) -
                                                          CGRectGetHeight(inputViewRect),
                                                          CGRectGetWidth(self.view.frame), CGRectGetHeight(inputViewRect));
                         
                         switch (state) {
                             case ZBMessageViewStateShowFace: {
                                 self.faceView.frame = CGRectMake(
                                                                  0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect),
                                                                  CGRectGetWidth(self.view.frame), CGRectGetHeight(rect));
                                 
                                 self.shareMenuView.frame =
                                 CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                            CGRectGetWidth(self.view.frame),
                                            CGRectGetHeight(self.shareMenuView.frame));
                             } break;
                             case ZBMessageViewStateShowNone: {
                                 self.faceView.frame =
                                 CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                            CGRectGetWidth(self.view.frame),
                                            CGRectGetHeight(self.faceView.frame));
                                 
                                 self.shareMenuView.frame =
                                 CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                            CGRectGetWidth(self.view.frame),
                                            CGRectGetHeight(self.shareMenuView.frame));
                             } break;
                             case ZBMessageViewStateShowShare: {
                                 self.shareMenuView.frame = CGRectMake(
                                                                       0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect),
                                                                       CGRectGetWidth(self.view.frame), CGRectGetHeight(rect));
                                 
                                 self.faceView.frame =
                                 CGRectMake(0.0f, CGRectGetHeight(self.view.frame),
                                            CGRectGetWidth(self.view.frame),
                                            CGRectGetHeight(self.faceView.frame));
                             } break;
                                 
                             default:
                                 break;
                         }
                         self.mainTab.frame =
                         CGRectMake(0, 0, self.view.width, self.sendView.frame.origin.y);
                         [self scrollToEndrow];
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
- (void)scrollToEndrow {
    if (chatArray.count > 0) {
        [self.mainTab
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:chatArray.count - 1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom
         animated:NO];
    }
}
#pragma mark - 声音按钮被点击
- (void)soundClick:(UIButton *)soundBtn {
    self.photoButton.selected = NO;
    self.MenuButton.selected = NO;
    soundBtn.selected = !soundBtn.selected;
    //键盘的弹出跟收回
    soundBtn.selected ? [self.textV becomeFirstResponder]
    : [self.textV resignFirstResponder];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.holdDownButton.hidden = soundBtn.selected;
                         self.textV.hidden = !soundBtn.selected;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    self.show = !self.show;
    if (soundBtn.selected) {
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    } else {
        [self messageViewAnimationWithMessageRect:CGRectZero
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}
#pragma mark - 表情按钮被点击
- (void)photoClick:(UIButton *)photoBtn {
    self.MenuButton.selected = NO;
    self.soundButton.selected = YES;
    photoBtn.selected = !photoBtn.selected;
    photoBtn.selected ? [self.textV resignFirstResponder]
    : [self.textV becomeFirstResponder];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.holdDownButton.hidden = YES;
                         self.textV.hidden = NO;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    if (photoBtn.selected) {
        [self messageViewAnimationWithMessageRect:self.faceView.frame
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowFace];
    } else {
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}
#pragma mark - 菜单按钮被点击
- (void)showMenuClick:(UIButton *)menuBtn {
    
    self.photoButton.selected = NO;
    self.soundButton.selected = YES;
    menuBtn.selected = !menuBtn.selected;
    menuBtn.selected ? [self.textV resignFirstResponder]
    : [self.textV becomeFirstResponder];
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.holdDownButton.hidden = YES;
                         self.textV.hidden = NO;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    if (menuBtn.selected) {
        [self messageViewAnimationWithMessageRect:self.shareMenuView.frame
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowShare];
    } else {
        [self messageViewAnimationWithMessageRect:keyboardRect
                         withMessageInputViewRect:self.sendView.frame
                                      andDuration:animationDuration
                                         andState:ZBMessageViewStateShowNone];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return chatArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *ID = @"QYQChatCell";
        QYQChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (cell == nil) {
            cell = [[QYQChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:ID];
        }
        cell.kMssage = chatArray[indexPath.row];
        cell.tapLocalImage = ^(NSString *lat, NSString *lng) {
           
        };
        cell.headBolck = ^(NSString *qiuNum){
        };
        return cell;
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    QYQChatCell *cell =
    (QYQChatCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.cellH;
    
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}


#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self  loadDbMessage];
    
    [_slimeView endRefresh];
}

@end
