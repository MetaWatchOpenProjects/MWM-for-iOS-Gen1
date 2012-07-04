//
//  MWMMusicControlApp.h
//  MWM
//
//  Created by Siqi Hao on 6/28/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWManager.h"
#import "AppDelegate.h"

#import <MediaPlayer/MediaPlayer.h>

@interface MWMMusicControlApp : NSObject

- (void) startAppMode;
- (void) stopAppMode;
- (void) nextBtnPressed;
- (void) previousBtnPressed;
- (void) playBtnPressed;
- (void) playlistBtnPressed;

@end
