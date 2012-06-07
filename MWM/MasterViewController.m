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
//  MasterViewController.m
//  MWM
//
//  Created by Siqi Hao on 4/18/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "MasterViewController.h"
#import "WidgetsSelectionViewController.h"

#import "SettingsViewController.h"
#import "InfoViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#define SETTINGVIEWTAGROW1 8001
#define SETTINGVIEWTAGROW2 8002
#define SETTINGVIEWTAGROW3 8003

@interface MasterViewController ()

@property (nonatomic, strong) UIView *watchView;
@property (nonatomic, strong) NSMutableArray *liveWidgets;

@property (nonatomic, strong) IBOutlet UILabel *row1Label;
@property (nonatomic, strong) IBOutlet UILabel *row2Label;
@property (nonatomic, strong) IBOutlet UILabel *row3Label;
@property (nonatomic, strong) IBOutlet UILabel *row4Label;

@property (nonatomic, strong) UIView *widget1SettingView;
@property (nonatomic, strong) UIView *widget2SettingView;
@property (nonatomic, strong) UIView *widget3SettingView;


- (IBAction) infoBtnPressed:(id)sender;


@end


@implementation MasterViewController

@synthesize appDelegate, watchDisplay, watchView, barIndicatorView, widgetSettingView, row1Label, row2Label, row3Label, row4Label, widget1SettingView, widget2SettingView, widget3SettingView, liveWidgets;

#pragma mark - UI Actions
- (void)rightBarBtnPressed:(id)sender {
    SettingsViewController *VC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)leftBarBtnPressed:(id)sender {
    [[MWManager sharedManager] getDeviceType];
    //[[MWManager sharedManager] setTimerWith:15 andID:0 andCounts:255];
}

- (IBAction) infoBtnPressed:(id)sender {
    InfoViewController *VC = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
    VC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:VC animated:YES];
}

#pragma mark - WidgetSelection Delegate
- (void) widget:(NSString *)widgetClassName configuredAtRow:(NSInteger)rowIndex {
    
    [self setupWidget:widgetClassName withRow:rowIndex];
    [self refreshWidgetsAtRow:rowIndex];
}

#pragma mark - MWMWidget Delegate
- (void) widgetViewCreated:(id)widget {
    [self.watchView addSubview:[widget preview]];
}

- (void) widgetViewShoudRemove:(id)widget {
    [[widget preview] removeFromSuperview];
    [[widgetSettingView viewWithTag:SETTINGVIEWTAGROW1] removeFromSuperview];
}


- (void) widget:(id)widget updatedWithError:(NSError*)error {
    [[MWManager sharedManager] writeImage:[AppDelegate imageDataForCGImage:[widget previewRef]] forMode:kMODE_IDLE inRect:[widget preview].frame linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:NO buzzWhenDone:NO];
}

#pragma mark - MWManagerProtocol
- (void) MWM:(MWManager*)mwm willConnectServices:(NSArray *)services {
    
}

- (void) MWM:(MWManager*)mwm didConnectPeripheral:(CBPeripheral *)peripheral {

}

- (void) MWM:(MWManager *)mwm didDisconnectPeripheral:(CBPeripheral *)peripheral withError:(NSError *)err {
    [self watchDisconnected:err.code];
}

- (void) MWMDidDiscoveredWritePort {
    [self watchConnected];
}

- (void) MWMCheckEvent:(NSTimeInterval)timestamp {
    NSInteger roundedTimeStamp = (NSInteger)timestamp;
    NSLog(@"MWMCheckEvent:%d", roundedTimeStamp);
    for (id widget in liveWidgets) {
        if (![widget isEqual:[NSNull null]]) {
            [widget update:timestamp];
        }
    }
}

#pragma mark - DragSliderView Delegate

- (void) slider:(DragImageView *)dragView connectButtonPressed:(UIButton *)connectBtn {
    if ([MWManager sharedManager].statusCode == 0) {
        [[MWManager sharedManager] startScan];
    } else if ([MWManager sharedManager].statusCode == 1) {
        [[MWManager sharedManager] stopScan];
    } else {
        [[MWManager sharedManager] stopScan];
    }
}

- (void) sliderShouldDisconnect {
    [[MWManager sharedManager] disconnect:DISCONNECTEDBYUSER];
}

- (void) slider:(DragImageView *)dragView DidStopAtMode:(NSInteger)position {
    NSLog(@"SliderStoppedAt:%d", position);
    [UIView beginAnimations:nil context:NULL];
    if (position < 1) {
        widgetSettingView.alpha = 0;
    } else {
        row4Label.alpha = 0;
        widgetSettingView.alpha = 1;
        
        if (position == 3) {
            // Row 1
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW1].alpha = 1;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW2].alpha = 0;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW3].alpha = 0;
        } else if (position == 2) {
            // Row 2
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW1].alpha = 0;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW2].alpha = 1;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW3].alpha = 0;
        } else if (position == 1) {
            // Row 3
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW1].alpha = 0;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW2].alpha = 0;
            [widgetSettingView viewWithTag:SETTINGVIEWTAGROW3].alpha = 1;
        }
    }
    [UIView commitAnimations];
}

- (void) slider:(DragImageView *)dragView DidMoved:(CGFloat)center {
    //NSLog(@"slider is at:%f", center);
    
    [dragView becomeFirstResponder];
    
    if (center > 117) {
        [UIView beginAnimations:nil context:NULL];
        [widgetSettingView viewWithTag:SETTINGVIEWTAGROW1].alpha = [widgetSettingView viewWithTag:SETTINGVIEWTAGROW2].alpha = [widgetSettingView viewWithTag:SETTINGVIEWTAGROW3].alpha = 0;
        row4Label.alpha = 1;
        [UIView commitAnimations];
    }
}

#pragma mark - Watch callbacks

- (void) watchConnected {
    
    [self setupWidgets];
    
    [[MWMNotificationsManager sharedManager] setNotificationsEnabled:YES];
    
    [barIndicatorView watchConnected];
    barIndicatorView.sliderCanMoveVertically = YES;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"buzzOnConnect"] boolValue]) {
        [[MWManager sharedManager] setBuzz];
    }
    
    [[MWManager sharedManager] setTimerWith:TIMERVALUE andID:0 andCounts:255]; 
    
    [self drawIdleScreen];
}

- (void) watchDisconnected:(NSInteger)errorCode {
    
    [[MWMNotificationsManager sharedManager] setNotificationsEnabled:NO];
    
    [barIndicatorView setConnectable:YES];
    [self slider:nil DidStopAtMode:0];
    
    [MWManager sharedManager].statusCode = 0;
    
    for (id widget in liveWidgets) {
        if ([widget respondsToSelector:@selector(stopUpdate)]) {
            [widget performSelector:@selector(stopUpdate)];
        }
    }
    
    [self drawDisconnectedScreen];
    
    if (errorCode == DISCONNECTEDUNKNOWN ) {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = @"Watch disconnected";
        notif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoReconnect"] boolValue]) {
            [barIndicatorView connectButtonPressed:nil];
        }
    } else if (errorCode == DISCONNECTEDBY8882) {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Meta Watch failed to handshake with MWM." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (errorCode == DISCONNECTEDBYBLENOTIF) {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"MWM failed to register notifications with Meta Watch." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (errorCode == DISCONNECTEDBYBLEPOWER) {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"The Bluetooth has been turned off. To reconnect, please turn on the Bluetooth from iPhone Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - Watch Drawing stuff

- (void) drawIdleScreen {
    UIImageView *idle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"idle_bg.png"]];
    
    [self.watchView addSubview:idle];
    [self.watchView sendSubviewToBack:idle];
    [self.view addSubview:watchView];
    
    [[MWManager sharedManager] drawIdleLines:[[[NSUserDefaults standardUserDefaults] objectForKey:@"drawDashLines"] boolValue]];
    
    for (id widget in liveWidgets) {
        if (![widget isEqual:[NSNull null]]) {
            [widget update:-1];
        }
    }
    
}

- (void) drawDisconnectedScreen {
    [watchView removeFromSuperview];
    self.watchDisplay.image = [AppDelegate imageForText:@"Disconnected\n\nTap the button below\nto connect."];
}
			
#pragma mark - View Controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"META WATCH";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"site-background.jpg"]];
    
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
    [settingBtn sizeToFit];
    [settingBtn addTarget:self action:@selector(rightBarBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:settingBtn]; 
    rightBarBtn.width = 30;
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
//    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Change"
//                                                                    style:UIBarButtonItemStyleBordered
//                                                                   target:self
//                                                                   action:@selector(leftBarBtnPressed:)]; 
//    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
    self.liveWidgets = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];
    
    self.barIndicatorView.delegate = self;
    
    self.watchDisplay.image = [AppDelegate imageForText:@"Disconnected\n\nTap the button below\nto connect."];
    
    watchView = [[UIView alloc] initWithFrame:watchDisplay.frame];
    watchView.backgroundColor = [UIColor clearColor];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"autoConnect"] boolValue]) {
        if ([MWManager sharedManager].statusCode == 0) {
            [self.barIndicatorView connectButtonPressed:nil];
        }
    }
}

- (void) setupWidgets {
    NSDictionary *layoutDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"watchLayout"];
    NSLog(@"%@", layoutDict);
    [self setupWidget:[layoutDict objectForKey:@"03"] withRow:0];
    [self setupWidget:[layoutDict objectForKey:@"13"] withRow:1];
    [self setupWidget:[layoutDict objectForKey:@"23"] withRow:2];

}

- (BOOL) setupWidget:(NSString*)widgetClassName withRow:(NSInteger)row {
    if (![widgetClassName hasPrefix:@"Widget"]) {
        return NO;
    } else {
        NSLog(@"Setup: %@", widgetClassName);
    }
    
    Class widgetClass = NSClassFromString(widgetClassName);
    id widget = [[widgetClass alloc] init];

    if ([widget respondsToSelector:@selector(setDelegate:)]) {
        [widget setDelegate:self];
    }

    switch (row) {
        case 0:
            row1Label.text = [widget widgetName];
            [widget preview].frame = CGRectMake(0, 0, [widget widgetSize].width, [widget widgetSize].height);
            [[widget settingView] setTag:SETTINGVIEWTAGROW1];
            [[widgetSettingView viewWithTag:SETTINGVIEWTAGROW1] removeFromSuperview];
            break;
        case 1:
            row2Label.text = [widget widgetName];
            [widget preview].frame = CGRectMake(0, 31, [widget widgetSize].width, [widget widgetSize].height);
            [[widget settingView] setTag:SETTINGVIEWTAGROW2];
            [[widgetSettingView viewWithTag:SETTINGVIEWTAGROW2] removeFromSuperview];
            break;
        case 2:
            row3Label.text = [widget widgetName];
            [widget preview].frame = CGRectMake(0, 64, [widget widgetSize].width, [widget widgetSize].height);
            [[widget settingView] setTag:SETTINGVIEWTAGROW3];
            [[widgetSettingView viewWithTag:SETTINGVIEWTAGROW3] removeFromSuperview];
            break;
        default:
            return NO;
    }
    
    [widgetSettingView addSubview:[widget settingView]];
    if ([widget respondsToSelector:@selector(prepareToUpdate)]) {
        [widget performSelector:@selector(prepareToUpdate)];
    }
    
    if (![[liveWidgets objectAtIndex:row] isKindOfClass:[NSNull class]]) {
        [[liveWidgets objectAtIndex:row] stopUpdate];
    }
    [liveWidgets replaceObjectAtIndex:row withObject:widget];
    
    return YES;
}

- (void) refreshWidgetsAtRow:(NSInteger)rowIndex {
    [[liveWidgets objectAtIndex:rowIndex] update:-1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
