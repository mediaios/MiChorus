//
//  ChrousVC.m
//  MIDaChongGouIosDemo
//
//  Created by ADMIN on 2021/11/30.
//


#import "ChrousVC.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "MIAudioUnit.h"
#import "MIConst.h"

@interface MIMediaPlayer : NSObject<AgoraRtcMediaPlayerProtocol>

@end

@interface ChrousVC ()<AgoraRtcEngineDelegate,AgoraRtcMediaPlayerDelegate,MIAudioCollectionDelegate>
@property (nonatomic,strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic,strong) MIMediaPlayer *miPlayer;
@property (nonatomic,strong) MIAudioUnit *miAudioUnit;
@property (nonatomic,assign) BOOL isDirect;
@end

@implementation ChrousVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initAgoraEngine];
    self.miPlayer = [self.agoraKit createMediaPlayerWithDelegate:self];
}

#pragma mark --Agora SDK相关
- (void)initAgoraEngine
{
    AgoraRtcEngineConfig *config = [[AgoraRtcEngineConfig alloc] init];
    // 传入 App ID。
    config.appId = MIAgoraAppID;
    // 设置频道场景为直播。
    config.channelProfile = AgoraChannelProfileLiveBroadcasting;
    // 创建并初始化 AgoraRtcEngineKit 实例。
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithConfig:config delegate:self];
    
    [self.agoraKit setExternalAudioSource:YES sampleRate:48000 channels:1];

    [self.agoraKit enableDirectExternalAudioSource:YES]; // 设置支持direct push;
}


#pragma mark --SDK采集

- (IBAction)onPressedBtnLeaderSingerSdkCollection:(id)sender {
    
    
    /**
         1.  uid1加入频道发送人的干声；
         2.  uid2加入频道发送BGM
     */
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:101 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    AgoraRtcChannelMediaOptions *exMediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    exMediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:NO];
    exMediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
//    exMediaOptions.publishCustomAudioTrack = [AgoraRtcBoolOptional of:YES];
    exMediaOptions.publishMediaPlayerId = [AgoraRtcIntOptional of:[self.miPlayer getMediaPlayerId]];
    exMediaOptions.publishMediaPlayerAudioTrack = [AgoraRtcBoolOptional of:YES];
    exMediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    
    AgoraRtcConnection *rtcConn = [[AgoraRtcConnection alloc] init];
    rtcConn.localUid = 102;
    rtcConn.channelId = @"qitest";
    int joinExRes = [self.agoraKit joinChannelExByToken:nil connection:rtcConn delegate:self mediaOptions:exMediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channelEx res: %d",joinExRes);
    
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
}

- (IBAction)onPressedBtnSecondSingerSdkCollection:(id)sender {
    
    /**
         1.  uid3加入频道发送人的干声；
         2. MPK本地播放BGM
     */
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:103 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
}

#pragma mark --自采集

- (IBAction)onPressedBtnLeanderSingerNoSdk:(id)sender {
    
    self.isDirect = NO;
    
    [[MIAudioUnit shareInstance] startAudioUnitRecorder];  // 启动AudioUnit录制
    [MIAudioUnit shareInstance].delegate = self;
    
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishCustomAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishCustomAudioSourceId = [AgoraRtcIntOptional of:0];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:101 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    
    AgoraRtcChannelMediaOptions *exMediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    exMediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:NO];
    exMediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    exMediaOptions.publishMediaPlayerId = [AgoraRtcIntOptional of:[self.miPlayer getMediaPlayerId]];
    exMediaOptions.publishMediaPlayerAudioTrack = [AgoraRtcBoolOptional of:YES];
    exMediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色

    AgoraRtcConnection *rtcConn = [[AgoraRtcConnection alloc] init];
    rtcConn.localUid = 102;
    rtcConn.channelId = @"qitest";
    int joinExRes = [self.agoraKit joinChannelExByToken:nil connection:rtcConn delegate:self mediaOptions:exMediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channelEx res: %d",joinExRes);
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
}

- (IBAction)onPressedBtnSecondSingerNoSdk:(id)sender {
    [[MIAudioUnit shareInstance] startAudioUnitRecorder];  // 启动AudioUnit录制
    [MIAudioUnit shareInstance].delegate = self;
    
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishCustomAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishCustomAudioSourceId = [AgoraRtcIntOptional of:0];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:103 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
    
}

- (IBAction)onPressedBtnLeanderSingerPushDirect:(id)sender {
    
    [[MIAudioUnit shareInstance] startAudioUnitRecorder];  // 启动AudioUnit录制
    [MIAudioUnit shareInstance].delegate = self;
    
    self.isDirect = YES;
    
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishCustomAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishDirectCustomAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishCustomAudioSourceId = [AgoraRtcIntOptional of:0];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:101 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    
    AgoraRtcChannelMediaOptions *exMediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    exMediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:NO];
    exMediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    exMediaOptions.publishMediaPlayerId = [AgoraRtcIntOptional of:[self.miPlayer getMediaPlayerId]];
    exMediaOptions.publishMediaPlayerAudioTrack = [AgoraRtcBoolOptional of:YES];
    exMediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色

    AgoraRtcConnection *rtcConn = [[AgoraRtcConnection alloc] init];
    rtcConn.localUid = 102;
    rtcConn.channelId = @"qitest";
    int joinExRes = [self.agoraKit joinChannelExByToken:nil connection:rtcConn delegate:self mediaOptions:exMediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channelEx res: %d",joinExRes);

    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
}

- (IBAction)onPressedBtnSecondSingerPushDirect:(id)sender {
    [[MIAudioUnit shareInstance] startAudioUnitRecorder];  // 启动AudioUnit录制
    [MIAudioUnit shareInstance].delegate = self;
    
    self.isDirect = YES;
    
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishCustomAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.publishDirectCustomAudioTrack = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishCustomAudioSourceId = [AgoraRtcIntOptional of:0];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:1];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:103 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
    
    // MPK相关
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"ChmFDlpzR5yAX1arABux65e_tAY786" ofType:@"mp3"];
//    [self.miPlayer setAudioDualMonoMode:AgoraAudioMixingDuraMonoL];
    [self.miPlayer open:musicPath startPos:0];
}



- (IBAction)onPressedBtnLeaveChannel:(id)sender {
    [self.agoraKit leaveChannel:nil];
}


#pragma mark --观众
- (IBAction)onPressedBtnAudienceJoin:(id)sender {
    [self.agoraKit setParameters:@"{\"rtc.audio_resend\":false}"];
    [self.agoraKit setParameters:@"{\"rtc.audio_fec\":[3,2]}"];
    [self.agoraKit setAudioProfile:AgoraAudioProfileMusicHighQuality scenario:AgoraAudioScenarioChorus];
    
    AgoraRtcChannelMediaOptions *mediaOptions = [[AgoraRtcChannelMediaOptions alloc] init];
    mediaOptions.autoSubscribeAudio = [AgoraRtcBoolOptional of:YES];
    mediaOptions.publishAudioTrack = [AgoraRtcBoolOptional of:NO];
    mediaOptions.clientRoleType = [AgoraRtcIntOptional of:2];  // 设置为主播角色
    int joinRes = [self.agoraKit joinChannelByToken:nil channelId:@"qitest" uid:0 mediaOptions:mediaOptions joinSuccess:nil];
    NSLog(@"QiDebug, join channel res: %d",joinRes);
}

#pragma mark --MPK回调
- (void)AgoraRtcMediaPlayer:(id<AgoraRtcMediaPlayerProtocol> _Nonnull)playerKit
          didChangedToState:(AgoraMediaPlayerState)state
                      error:(AgoraMediaPlayerError)error
{
    NSLog(@"QiDebug, %s,state:%d, error:%d",__func__,(int)state,(int)error);
    if (state == AgoraMediaPlayerStateOpenCompleted) {
        [self.miPlayer play];
    }
}


#pragma mark --声网SDK回调
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    NSLog(@"QiDebug, join channel success, uid:%lu\n",uid);
    if ([channel isEqualToString:@"qitest"] && uid == 101) {
        [self.agoraKit muteRemoteAudioStream:102 mute:YES];   // 频道中主唱的干声uid mute BGM uid
    }else if([channel isEqualToString:@"qitest"] && uid == 103){
        [self.agoraKit muteRemoteAudioStream:102 mute:YES];   // 频道中副唱 mute BGM uid
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    NSLog(@"QiDebug, remote user joined channel, uid:%lu\n",uid);
//    [self setupRemoteVideo:uid];
}

#pragma mark --音频自采集回调
- (void)collectionAudioData:(MIAudioUnit *)audioUnit audioData:(NSData *)data samples:(NSUInteger)samples
{
    if (self.isDirect) {
        [self.agoraKit pushDirectSendAudioFrameNSData:data];
        return;
    }
    [self.agoraKit pushExternalAudioFrameNSData:data sourceId:0 timestamp:0];
}
@end
