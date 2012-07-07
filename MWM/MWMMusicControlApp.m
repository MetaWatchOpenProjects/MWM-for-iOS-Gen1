//
//  MWMMusicControlApp.m
//  MWM
//
//  Created by Siqi Hao on 6/28/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "MWMMusicControlApp.h"

@interface MWMMusicControlApp ()

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong) NSArray *playlistsArray;
@property (nonatomic) NSInteger currentPlayList;

@end

@implementation MWMMusicControlApp

@synthesize musicPlayer, playlistsArray, currentPlayList;

- (id)init
{
    self = [super init];
    if (self) {
        self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        //Create a query that will return all songs by The Beatles grouped by album
        MPMediaQuery* query = [MPMediaQuery songsQuery];
        MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
        self.playlistsArray = [playlistsQuery collections];
        currentPlayList = 0;
        
        //Pass the query to the player
        [musicPlayer setQueueWithQuery:query];
        musicPlayer.repeatMode = MPMusicRepeatModeAll;
        
    }
    return self;
}

- (void) startAppMode {
    [[MWManager sharedManager] loadTemplate:kMODE_APPLICATION];
    
    [[MWManager sharedManager] setButton:kBUTTON_B atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    [[MWManager sharedManager] setButton:kBUTTON_E atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    [[MWManager sharedManager] setButton:kBUTTON_C atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    [[MWManager sharedManager] setButton:kBUTTON_F atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:0x13];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector:@selector (handle_NowPlayingItemChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    [musicPlayer beginGeneratingPlaybackNotifications];
    [self drawPlayplist:NO];
    
    [[MWManager sharedManager] updateDisplay:kMODE_APPLICATION];
}

- (void) stopAppMode {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) handle_NowPlayingItemChanged:(id)obj {
    [self drawCurrentSong:YES];
}

- (void) drawPlayplist:(BOOL)update {
    UIImage *imageToSend = [MWManager imageForText:[NSString stringWithFormat:@"Playlist:\n%@", [[playlistsArray objectAtIndex:currentPlayList] valueForProperty: MPMediaPlaylistPropertyName]]];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:imageToSend.CGImage] forMode:kMODE_APPLICATION inRect:CGRectMake(3, 10, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:NO shouldUpdate:update buzzWhenDone:NO buzzRepeats:NO];
}

- (void) drawCurrentSong:(BOOL)update {
    NSString *songTitle = [self.musicPlayer.nowPlayingItem valueForProperty: MPMediaItemPropertyTitle];
    UIImage *imageToSend = [MWManager imageForText:[NSString stringWithFormat:@"Song:\n%@", songTitle]];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:imageToSend.CGImage] forMode:kMODE_APPLICATION inRect:CGRectMake(3, 40, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:NO shouldUpdate:update buzzWhenDone:NO buzzRepeats:NO];
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

- (void) playlistBtnPressed {
    currentPlayList++;
    if (playlistsArray.count <= currentPlayList) {
        currentPlayList = 0;
    }
    [self.musicPlayer setQueueWithItemCollection:[playlistsArray objectAtIndex:currentPlayList]];
    [self drawPlayplist:YES];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
