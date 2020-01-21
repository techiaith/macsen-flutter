//
//  FlutterMascenMainActivity.h
//  Runner
//
//  Created by Uned Technolegau Iaith on 21.11.2019.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
#ifndef FlutterMascenMainActivity_h
#define FlutterMascenMainActivity_h

#import <Flutter/Flutter.h>
#import "UTIAudioRecorderPlayer.h"



@class UTISpotifyPlayer;

@interface FlutterMacsenMainActivity : NSObject <AVAudioPlayerDelegate>

@property (strong, nonatomic) UTIAudioRecorderPlayer *audio;
@property (strong, nonatomic) UTISpotifyPlayer *spotify;

-(instancetype) initWithController:(FlutterViewController*)controller;

-(BOOL) openUrl:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

-(void) didBecomeActive;
-(void) willResignActive;


// delegates
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                      successfully:(BOOL)flag;


@end

#endif /* FlutterMascenMainActivity_h */
