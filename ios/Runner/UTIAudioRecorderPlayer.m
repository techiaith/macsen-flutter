//
//  UTIRecordingSession.m
//

// gyda diolch i https://github.com/dooboolab/flutter_sound am ddarnau sylweddol
// thanks to https://github.com/dooboolab/flutter_sound for significant portions
// MIT License Copyright (c) 2018 dooboolab (https://github.com/dooboolab/flutter_sound/blob/master/LICENSE)

#import "UTIAudioRecorderPlayer.h"

@implementation UTIAudioRecorderPlayer{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
}

//@synthesize delegate;

-(id) init {
    if ((self = [super init]) != nil){
        self.hasMicrophonePermission=@NO;
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted)
                self.hasMicrophonePermission=@YES;
            else
                self.hasMicrophonePermission=@NO;
        }];
    }
    return self;
}

#define RECORDING_TIMEOUT 20.0

-(BOOL) recordAudio:(NSString*)filename {

    NSLog(@"Started recording. Start talking...");
    
    NSURL* audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:filename]];

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMax] forKey:AVEncoderAudioQualityKey];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];

    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:audioFileURL
                     settings:recordSetting
                     error:nil];

    [audioRecorder prepareToRecord];
    [audioRecorder record];
    
    return TRUE;
    
}


-(NSString*) stopRecording {

    [audioRecorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];

    NSString* audiofilepath=[audioRecorder.url absoluteString];
    return audiofilepath;

}



-(BOOL) playAudioWithDelegate:(NSString*)audiofilepath delegate:(id<AVAudioPlayerDelegate>)playerdelegate {
    NSURL *audiofileurl = [NSURL fileURLWithPath:audiofilepath];
    
    audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:audiofileurl
                                                       error:nil];
    [audioPlayer setDelegate:playerdelegate];
    [audioPlayer play];
    return true;
}

-(BOOL) stopPlaying{
    [audioPlayer stop];
    return true;
}

@end
