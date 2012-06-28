//
//  MWMMusicControlApp.m
//  MWM
//
//  Created by Siqi Hao on 6/28/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "MWMMusicControlApp.h"

@implementation MWMMusicControlApp

@synthesize musicPlayer;

- (id)init
{
    self = [super init];
    if (self) {
        self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        //Create a query that will return all songs by The Beatles grouped by album
        MPMediaQuery* query = [MPMediaQuery songsQuery];
        
        //Pass the query to the player
        [musicPlayer setQueueWithQuery:query];
        musicPlayer.repeatMode = MPMusicRepeatModeAll;
        [self startAppMode];
    }
    return self;
}

- (void) startAppMode {
    [[MWManager sharedManager] setButton:kBUTTON_B atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    [[MWManager sharedManager] setButton:kBUTTON_E atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    [[MWManager sharedManager] setButton:kBUTTON_C atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
}

- (void) nextBtnPressed {
    [self.musicPlayer skipToNextItem];
}

- (void) previousBtnPressed {
    [self.musicPlayer skipToPreviousItem];
}

- (void) playBtnPressed {
    MPMusicPlaybackState playbackState = self.musicPlayer.playbackState;
    if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[self.musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
		[self.musicPlayer pause];
	}
}

@end
