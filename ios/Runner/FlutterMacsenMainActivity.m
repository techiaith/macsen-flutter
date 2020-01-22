//
//  FlutterMacsenMainActivity.m
//  Runner
//
//  Created by Uned Technolegau Iaith on 21.11.2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlutterMascenMainActivity.h"

#import "Runner-Swift.h"


@implementation FlutterMacsenMainActivity

FlutterMethodChannel* wavRecorderChannel;
FlutterMethodChannel* wavPlayerChannel;
FlutterMethodChannel* spotifyChannel;


-(instancetype) initWithController:(FlutterViewController *)controller
{
    
    self = [super init];
     
    if (self)
    {
        //
        self.audio = [[UTIAudioRecorderPlayer alloc] init];
        self.audio.delegate = self;

        //
        self.spotify = [[UTISpotifyPlayer alloc] init];
        
        //
        wavRecorderChannel = [FlutterMethodChannel methodChannelWithName:@"cymru.techiaith.flutter.macsen/wavrecorder"
                                                         binaryMessenger:controller.binaryMessenger];

        [wavRecorderChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            
            if ([@"checkMicrophonePermissions" isEqualToString:call.method])
            {
                NSLog(@"Asking for microphone permission");
                result(self.audio.hasMicrophonePermission);
            }
            else if ([@"startRecording" isEqualToString:call.method])
            {
                NSLog(@"Start Recording....");
                NSString* filename = (NSString *)call.arguments[@"filename"];
                if ([self.audio recordAudio:filename]){
                    result(@"OK");
                } else {
                    result(@"FAIL");
                }
            }
            else if ([@"stopRecording" isEqualToString:call.method])
            {
                NSLog(@"Stop Recording....");
                NSString *recordingAbsoluteFilePath = [self.audio stopRecording];
                recordingAbsoluteFilePath=
                    [recordingAbsoluteFilePath stringByReplacingOccurrencesOfString:@"file://"
                                                                         withString:@""];
                result(recordingAbsoluteFilePath);
            }
            else
            {
                NSLog(@"%@", call.method);
                result(FlutterMethodNotImplemented);
            }
            
        }];

        
        //
        wavPlayerChannel = [FlutterMethodChannel methodChannelWithName:@"cymru.techiaith.flutter.macsen/wavplayer"
                                                       binaryMessenger:controller.binaryMessenger];

        [wavPlayerChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            
            if ([@"playRecording" isEqualToString:call.method])
            {
                NSString* filename = (NSString *)call.arguments[@"filepath"];
                if ([self.audio playAudioWithDelegate:filename delegate:self]){
                    result(@"OK");
                } else {
                    result(@"FAIL");
                }
            }
            else if ([@"stopPlayingRecording" isEqualToString:call.method])
            {
                if ([self.audio stopPlaying]){
                    result(@"OK");
                } else {
                    result(@"FAIL");
                }
            }
            else
            {
                NSLog(@"%@", call.method);
                result(FlutterMethodNotImplemented);
            }
        }];

        //
        spotifyChannel = [FlutterMethodChannel methodChannelWithName:@"cymru.techiaith.flutter.macsen/spotify"
                                                     binaryMessenger:controller.binaryMessenger];

        
        [spotifyChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            if ([@"checkIsSpotifyInstalled" isEqualToString:call.method])
            {
                BOOL isInstalledBool=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"spotify:"]];
                if (isInstalledBool)
                    NSLog(@"Spotify is installed");
                else
                    NSLog(@"Spotify is not installed");
                
                result([NSNumber numberWithBool:isInstalledBool]);
            }
            else if ([@"spotifyPlayArtistOrBand" isEqualToString:call.method])
            {
                NSString* artist_uri = (NSString *)call.arguments[@"artist_uri"];
                [self.spotify connect:artist_uri];
                result(@"OK");
            }
            else if ([@"spotifyStopPlayArtistOrBand" isEqualToString:call.method])
            {
                [self.spotify disconnect];
                result(@"OK");
            }
            else
            {
                NSLog(@"%@", call.method);
                result(FlutterMethodNotImplemented);
            }
        }];

     }
     
     return self;
     
}


-(BOOL) openUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [self.spotify openUrl:url options:options];
}


-(void) didBecomeActive{
    [self.spotify didBecomeActive];
}


-(void) willResignActive{
    [self.spotify willResignActive];
}


-(void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                       successfully: (BOOL) flag {
    NSLog(@"Audio finished playing");
    NSString* audiofilepath=[player.url absoluteString];
    audiofilepath=[audiofilepath stringByReplacingOccurrencesOfString:@"file://"
                                                           withString:@""];
    [wavPlayerChannel invokeMethod:@"audioPlayCompleted" arguments:audiofilepath];
}

@end
