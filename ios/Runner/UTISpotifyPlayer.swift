//
//  UTISpotifyPlayer.swift
//  Runner
//
//  Created by Uned Technolegau Iaith on 16.1.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation


@objc class UTISpotifyPlayer : NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    let SpotifyClientID = String("300debafe4ee42a1b1631015796b1681")
    let SpotifyRedirectURL = URL(string: "cymru.techiaith.flutter.macsen://callback")!

    var accessToken = String("");
    var currentArtistUri: String = ""
    
    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )

    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    
    @objc public func connect(_ spotifyUri : String){
        if !(appRemote.isConnected){
            print ("Authorize and Play URI..." + spotifyUri)
            self.appRemote.authorizeAndPlayURI(spotifyUri)
        } else {
            print ("Play URI " + spotifyUri)
            self.appRemote.playerAPI?.play(spotifyUri)
        }
    }
      
    
    @objc func openUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("spotify openUrl...")
        
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            self.appRemote.connectionParameters.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(error_description)
        }
        
        return true
    }
    
    
    @objc func didBecomeActive() {
        print ("App Become Active")
        self.appRemote.connect()
    }
    
    
    @objc func willResignActive() {
        print ("App is resigning active...")
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    
    @objc public func disconnect(){
           print ("Disconnect...")
           self.appRemote.playerAPI?.pause()
           self.appRemote.disconnect()
    }
    
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print ("appRemoteDidEstablishConnection")
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
    }
    
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
           print("failed to connect")
    }
       
       
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
           print("failed to disconnect")
    }
    
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        print("player state changed")
        print("isPaused", playerState.isPaused)
        print("track.uri", playerState.track.uri)
        print("track.name", playerState.track.name)
        print("track.imageIdentifier", playerState.track.imageIdentifier)
        print("track.artist.name", playerState.track.artist.name)
        print("track.album.name", playerState.track.album.name)
        print("track.isSaved", playerState.track.isSaved)
        print("playbackSpeed", playerState.playbackSpeed)
        print("playbackOptions.isShuffling", playerState.playbackOptions.isShuffling)
        print("playbackOptions.repeatMode", playerState.playbackOptions.repeatMode.hashValue)
        print("playbackPosition", playerState.playbackPosition)
    }
    
    
}
