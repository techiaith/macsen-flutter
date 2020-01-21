//
//  UTIRecordingSession.h
//  Paldaruo
//
//  Created by Apiau on 04/06/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//
#ifndef UTI_AUDIORECORDERPLAYER_INCLUDED
#define UTI_AUDIORECORDERPLAYER_INCLUDED

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudioTypes/CoreAudioTypes.h>

#define PEAK_UPPER 1.0000
#define PEAK_LOWER 0.5000

@class UTIAudioRecorderPlayer;

@interface UTIAudioRecorderPlayer : NSObject

    @property (nonatomic, assign) id delegate;

    @property (strong, nonatomic) NSNumber *hasMicrophonePermission;

    -(BOOL) recordAudio:(NSString*)filename;
    -(NSString*) stopRecording;
    -(BOOL) playAudioWithDelegate:(NSString*)filepath delegate:(id<AVAudioPlayerDelegate>)playdelegate;
    -(BOOL) stopPlaying;

@end

#endif
