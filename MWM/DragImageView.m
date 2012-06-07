/*****************************************************************************
 *  Copyright (c) 2011 Meta Watch Ltd.                                       *
 *  www.MetaWatch.org                                                        *
 *                                                                           *
 =============================================================================
 *                                                                           *
 *  Licensed under the Apache License, Version 2.0 (the "License");          *
 *  you may not use this file except in compliance with the License.         *
 *  You may obtain a copy of the License at                                  *
 *                                                                           *
 *    http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                           *
 *  Unless required by applicable law or agreed to in writing, software      *
 *  distributed under the License is distributed on an "AS IS" BASIS,        *
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 *  See the License for the specific language governing permissions and      *
 *  limitations under the License.                                           *
 *                                                                           *
 *****************************************************************************/

//
//  DragImageView.m
//  MWM
//
//  Created by Siqi Hao on 4/19/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "DragImageView.h"
#import "MWManager.h"

@interface DragImageView ()

@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation DragImageView

#define kBUTTOMWIDTH 134
#define kBUTTOMWIDTHDIS 134

@synthesize connectButton, sliderCanMoveVertically, delegate, maskView;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        connectButton.backgroundColor = [UIColor blackColor];
        [connectButton setTitle:@"Tap to Connect" forState:UIControlStateNormal];
        connectButton.titleLabel.minimumFontSize = 10;
        connectButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [connectButton.titleLabel setLineBreakMode:UILineBreakModeCharacterWrap];
        connectButton.titleLabel.numberOfLines = 1;
        connectButton.titleLabel.textAlignment = UITextAlignmentCenter;
        
        connectButton.titleLabel.contentMode = UIViewContentModeCenter;

        connectButton.contentMode = UIViewContentModeCenter;

        [connectButton addTarget:self action:@selector(connectButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:connectButton];
        
        connectButton.frame = CGRectMake(0, 0, kBUTTOMWIDTH, 42);
        connectButton.center = CGPointMake(160, 32);
        
        
        
        sliderCanMoveVertically = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) connectButtonPressed:(id)sender {
    if ([MWManager sharedManager].statusCode == 0) {
        connectButton.titleLabel.numberOfLines = 2;
        [connectButton setTitle:@"Connecting...\nTap to Cancel" forState:UIControlStateNormal];
        [connectButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    } else {
        connectButton.titleLabel.numberOfLines = 1;
        [connectButton setTitle:@"Tap to Connect" forState:UIControlStateNormal];
        [connectButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    }
    
    [delegate slider:self connectButtonPressed:connectButton];
}

- (void) watchConnected {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:1];
    [UIView setAnimationDuration:2];
    connectButton.frame = CGRectMake(connectButton.center.x, connectButton.frame.origin.y, 0, connectButton.frame.size.height);
    connectButton.titleLabel.numberOfLines = 1;
    [UIView commitAnimations];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (sliderCanMoveVertically) {
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.superview];
        
        if (location.y >= 300) {
            location.y = 300;
        } else if (location.y <= 15) {
            location.y = 15;
        } else if (location.y > 200) {
            connectButton.frame = CGRectMake(connectButton.center.x, connectButton.center.y, kBUTTOMWIDTHDIS * ((location.y - 200)/100), connectButton.frame.size.height);
            [connectButton setTitle:@"Release to disconnect" forState:UIControlStateNormal];
        }
        
        self.center = CGPointMake(self.center.x, location.y);
        
        if (location.y <= 200) {
            connectButton.frame = CGRectMake(connectButton.center.x, connectButton.center.y, 0, connectButton.frame.size.height);
        }
        
        if (location.y >= 300) {
            [connectButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            connectButton.frame = CGRectMake(connectButton.center.x, connectButton.center.y, kBUTTOMWIDTHDIS * ((location.y - 200)/100), connectButton.frame.size.height);
            [connectButton setTitle:@"Release to disconnect" forState:UIControlStateNormal];
        } else {
            [connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        connectButton.center = CGPointMake(160, 32);
        [delegate slider:self DidMoved:self.center.y];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (sliderCanMoveVertically) {
        UITouch *aTouch = [touches anyObject];
        CGPoint location = [aTouch locationInView:self.superview];
        [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
        if (location.y >= 180) {
            
            if (location.y >= 300) {
                connectButton.frame = CGRectMake(0.5*(320 - kBUTTOMWIDTH), 32 - connectButton.frame.size.height*0.5, kBUTTOMWIDTH, connectButton.frame.size.height);
                [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Do you really want to disconnect the MetaWatch?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil] show];
                [UIView commitAnimations];
                return;
            } else {
                connectButton.frame = CGRectMake(160, 32 - connectButton.frame.size.height*0.5, 0, connectButton.frame.size.height);
            }
            
            location.y = 200;
            
            [delegate slider:self DidStopAtMode:0];
            
        } else if (location.y < 52+16) {
            location.y = 52;
            [delegate slider:self DidStopAtMode:3];
        } else if (location.y >= 52 + 16 && location.y < 52+32+16) {
            location.y = 52+32;
            [delegate slider:self DidStopAtMode:2];
        } else if (location.y >= 52+32+16 && location.y < 180) {
            location.y = 52+32+32;
            [delegate slider:self DidStopAtMode:1];
        }
        
        self.center = CGPointMake(self.center.x, location.y);
        [UIView commitAnimations];
    }
    
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [UIView beginAnimations:nil context:nil];
    if (buttonIndex == 0) {
        sliderCanMoveVertically = NO;
        [connectButton setTitle:@"Tap to Connect" forState:UIControlStateNormal];
        [connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        connectButton.center = CGPointMake(160, 32);
        [delegate sliderShouldDisconnect];
    } else {
        
        connectButton.frame = CGRectMake(160, 32 - connectButton.frame.size.height*0.5, 0, connectButton.frame.size.height);

    }
    self.center = CGPointMake(self.center.x, 200);
    [UIView commitAnimations];
}

- (void) setConnectable:(BOOL)conn {
    [UIView beginAnimations:nil context:nil];
    if (conn) {
        sliderCanMoveVertically = NO;
        [connectButton setTitle:@"Tap to Connect" forState:UIControlStateNormal];
        [connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        connectButton.frame = CGRectMake(160 -  kBUTTOMWIDTH*0.5, connectButton.frame.origin.y, kBUTTOMWIDTH, 42);
    } else {
        // Do not use this
        connectButton.frame = CGRectMake(160, 32 - connectButton.frame.size.height*0.5, 0, connectButton.frame.size.height);
    }
    self.center = CGPointMake(self.center.x, 200);
    [UIView commitAnimations];
}

@end
