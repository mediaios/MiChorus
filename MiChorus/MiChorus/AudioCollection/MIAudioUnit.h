//
//  MIAudioUnit.h
//  MIDaChongGouIosDemo
//
//  Created by ADMIN on 2021/11/30.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MIAudioUnit;

@protocol MIAudioCollectionDelegate<NSObject>

@optional
- (void)collectionAudioData:(MIAudioUnit *)audioUnit
                  audioData:(NSData *)data
                    samples:(NSUInteger)samples;

@end

@interface MIAudioUnit : NSObject
{
@public
    AudioStreamBasicDescription     dataFormat;
    AudioUnit                       m_audioUnit;
    AudioBufferList                 *m_audioBufferList;
}

@property (nonatomic,strong) AgoraRtcEngineKit  *agoraEngine;
@property (nonatomic,weak) id<MIAudioCollectionDelegate> delegate;

@property (nonatomic,assign) BOOL m_isRunning;

+ (instancetype)shareInstance;
- (void)startAudioUnitRecorder;  // start recorder
- (void)stopAudioUnitRecorder;   // stop recorder
@end

NS_ASSUME_NONNULL_END
