//
//  FalseChrousVC.m
//  MIDaChongGouIosDemo
//
//  Created by ADMIN on 2021/11/14.
//

#import "FalseChrousVC.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "MIConst.h"

//@interface


@interface MIMediaPlayer : NSObject<AgoraRtcMediaPlayerProtocol>

@end

@interface FalseChrousVC ()<AgoraRtcEngineDelegate,AgoraRtcMediaPlayerDelegate,AgoraAudioFrameDelegate>
@property (nonatomic,strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic,strong) MIMediaPlayer *miPlayer;
@end

@implementation FalseChrousVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initAgoraEngine];
}


- (void)initAgoraEngine
{
    AgoraRtcEngineConfig *config = [[AgoraRtcEngineConfig alloc] init];
    // 传入 App ID。
    config.appId = MIAgoraAppID;
    // 设置频道场景为直播。
    config.channelProfile = AgoraChannelProfileLiveBroadcasting;
    // 创建并初始化 AgoraRtcEngineKit 实例。
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithConfig:config delegate:self];
    
    [self.agoraKit setExternalAudioSource:YES sampleRate:48000 channels:2 sourceNumber:3 localPlayback:NO publish:YES];
    [self.agoraKit setPlaybackAudioFrameBeforeMixingParametersWithSampleRate:48000
                                                                     channel:2];
    [self.agoraKit setAudioFrameDelegate:self];

}


- (IBAction)onPressedBtnLeadSinger:(id)sender {
    self.miPlayer = [self.agoraKit createMediaPlayerWithDelegate:self];
    
    AgoraRtcChannelMediaOptions *options = [[AgoraRtcChannelMediaOptions alloc] init];
    options.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES]; // 取消订阅频道中的音频流
    options.autoSubscribeVideo = [AgoraRtcBoolOptional of:NO]; // 取消订阅频道中的视频流
    options.publishAudioTrack = [AgoraRtcBoolOptional of:YES];   // 关闭SDK采集
    options.publishCustomAudioTrack = [AgoraRtcBoolOptional of:YES];   // 关闭SDK采集
    options.publishCameraTrack = [AgoraRtcBoolOptional of:NO];  // 关闭本地Camera
    options.publishMediaPlayerAudioTrack = [AgoraRtcBoolOptional of:YES];  // 启用自采集
    options.publishMediaPlayerId = [AgoraRtcIntOptional of:[self.miPlayer getMediaPlayerId]];
    options.clientRoleType = [AgoraRtcIntOptional of:1]; // 设置角色为主播
//    [self.agoraKit updateChannelWithMediaOptions:options];
    
    AgoraRtcConnection *conn = [[AgoraRtcConnection alloc] init];
    conn.localUid = 123;
    conn.channelId = @"qitest-ex";
    
    int joinRes = [self.agoraKit joinChannelExByToken:nil connection:conn delegate:self mediaOptions:options joinSuccess:nil];
    
//    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:0 mediaOptions:options joinSuccess:nil];
    
//    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" info:nil uid:0 joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
    
}

- (IBAction)onPressedBtnAssistantSinger:(id)sender {
    
    // 加入主频道
    AgoraRtcChannelMediaOptions *options2 = [[AgoraRtcChannelMediaOptions alloc] init];
    options2.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES]; // 订阅频道中的音频流
    options2.autoSubscribeVideo = [AgoraRtcBoolOptional of:NO]; // 取消订阅频道中的视频流
    options2.publishAudioTrack = [AgoraRtcBoolOptional of:YES];   // 开启SDK采集
    options2.publishCameraTrack = [AgoraRtcBoolOptional of:NO];  // 关闭本地Camera
    options2.publishCustomAudioTrack = [AgoraRtcBoolOptional of:YES];  // 开启自采集
    options2.publishCustomAudioSourceId = [AgoraRtcIntOptional of:2];
    options2.clientRoleType = [AgoraRtcIntOptional of:1]; // 设置角色为主播
//    [self.agoraKit updateChannelWithMediaOptions:options];
    
    int joinRes2 = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:11111 mediaOptions:options2 joinSuccess:nil];
    
    
    
    AgoraRtcChannelMediaOptions *options = [[AgoraRtcChannelMediaOptions alloc] init];
    options.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES]; // 取消订阅频道中的音频流
    options.autoSubscribeVideo = [AgoraRtcBoolOptional of:NO]; // 取消订阅频道中的视频流
    options.publishAudioTrack = [AgoraRtcBoolOptional of:NO];   // 关闭SDK采集
    options.publishCameraTrack = [AgoraRtcBoolOptional of:NO];  // 关闭本地Camera
    options.publishMediaPlayerAudioTrack = [AgoraRtcBoolOptional of:NO];  // 关闭自采集
    options.clientRoleType = [AgoraRtcIntOptional of:2]; // 设置角色为观众
//    [self.agoraKit updateChannelWithMediaOptions:options];
    
    AgoraRtcConnection *conn = [[AgoraRtcConnection alloc] init];
    conn.localUid = 456;
    conn.channelId = @"qitest-ex";
    
    int joinRes = [self.agoraKit joinChannelExByToken:nil connection:conn delegate:self mediaOptions:options joinSuccess:nil];
    
    
}


- (void)AgoraRtcMediaPlayer:(id<AgoraRtcMediaPlayerProtocol> _Nonnull)playerKit
          didChangedToState:(AgoraMediaPlayerState)state
                      error:(AgoraMediaPlayerError)error
{
    NSLog(@"QiDebug, %s,state:%d, error:%d",__func__,(int)state,(int)error);
    if (state == AgoraMediaPlayerStateOpenCompleted) {
        [self.miPlayer play];
    }
}



- (BOOL)onPlaybackAudioFrame:(AgoraAudioFrame * _Nonnull)frame channelId:(NSString * _Nonnull)channelId {
    return NO;
}

- (BOOL)onPlaybackAudioFrameBeforeMixing:(AgoraAudioFrame * _Nonnull)frame channelId:(NSString * _Nonnull)channelId uid:(NSUInteger)uid {
    
    NSLog(@"QiDebug, uid= %lu",(unsigned long)uid);
    if (uid == 123) {
//        NSTimeInterval mTime = [frame.renderTimeMs ]
        int res = [self.agoraKit pushExternalAudioFrameNSData:frame.buffer sourceId:2 timestamp:frame.renderTimeMs];
        NSLog(@"QiDebug, push res = %d",res);
    }
    return NO;
}


@end
