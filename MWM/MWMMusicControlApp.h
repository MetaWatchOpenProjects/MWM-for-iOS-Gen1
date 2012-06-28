//
//  MWMMusicControlApp.h
//  MWM
//
//  Created by Siqi Hao on 6/28/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWManager.h"

#import <MediaPlayer/MediaPlayer.h>

@interface MWMMusicControlApp : NSObject

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

- (void) startAppMode;
- (void) nextBtnPressed;
- (void) previousBtnPressed;
- (void) playBtnPressed;

@end
