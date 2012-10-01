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

#define SETTINGVIEWTAGROW1 8001
#define SETTINGVIEWTAGROW2 8002
#define SETTINGVIEWTAGROW3 8003

#define BTNNOTIFMODETOGGLE 0x10
#define BTNAPPMODETOGGLE 0x11

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

@synthesize appDelegate, watchDisplay, watchView, barIndicatorView, widgetSettingView, row1Label, row2Label, row3Label, row4Label, widget1SettingView, widget2SettingView, widget3SettingView, liveWidgets, musicApp;

#pragma mark - UI Actions
- (void)rightBarBtnPressed:(id)sender {
    SettingsViewController *VC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)leftBarBtnPressed:(id)sender {
    NSLog(@"leftBarBtnPressed");
    [[MWManager sharedManager] setWatchIdleFullScreen:YES];
    [[MWManager sharedManager] loadTemplate:kMODE_IDLE withTemplate:0x04];
    [[MWManager sharedManager] updateDisplay:kMODE_IDLE];
    return;
    [[MWManager sharedManager] performSelector:@selector(ringPhoneWithMAPData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            @"Yang Mu", @"sender",
                                                                                            @"", @"subject",
                                                                                            @"type", @"type",
                                                                                            @"This is a test notification", @"content",
                                                                                            nil]];
    return;
    if (musicApp == nil) {
        [self startiPodApp];
    } else {
        [[MWManager sharedManager] forceReleaseAccessToAppModeFromApp:[[NSBundle mainBundle] bundleIdentifier]];
    }
}

- (IBAction) infoBtnPressed:(id)sender {
    InfoViewController *VC = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:[NSBundle mainBundle]];
    VC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:VC animated:YES];
}

- (void) startiPodApp {
    // If you are developing a Meta Watch app which will ONLY be accessing the App mode of the Meta Watch,
    // you should use MWMAppManager library instead. Invoking this method directly, will cause issues.
    [[MWManager sharedManager] handle:[NSURL URLWithString:@"mwm://gain"] from:[[NSBundle mainBundle] bundleIdentifier]];
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
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:[widget previewRef]] forMode:kMODE_IDLE inRect:[widget preview].frame linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:NO shouldUpdate:YES buzzWhenDone:NO buzzRepeats:0];
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
    NSLog(@"MWMCheckEvent:%d", (NSInteger)timestamp);
    for (id widget in liveWidgets) {
        if (![widget isEqual:[NSNull null]]) {
            [widget update:timestamp];
        }
    }
    [[MWMNotificationsManager sharedManager] update:timestamp];
}

- (void) MWMBtn:(unsigned char)btnIndex atMode:(unsigned char)mode pressedForType:(unsigned char)type withMsg:(unsigned char)msg {
    NSLog(@"btn pressed:%x mode:%x, type:%x, msg:%x", btnIndex, mode, type, msg);
    if (msg == BTNAPPMODETOGGLE) {
        if (mode == kMODE_IDLE) {
            [[MWManager sharedManager] updateDisplay:kMODE_APPLICATION];
        } else if (mode == kMODE_APPLICATION) {
            [[MWManager sharedManager] updateDisplay:kMODE_IDLE];
        }
    } else if (msg == BTNNOTIFMODETOGGLE && mode == kMODE_NOTIFICATION) {
        [[MWManager sharedManager] updateDisplay:kMODE_IDLE];
    } else if (msg == 0x13 && mode == kMODE_APPLICATION) {
        if (btnIndex == kBUTTON_B) {
            [musicApp nextBtnPressed];
        } else if (btnIndex == kBUTTON_C) {
            [musicApp playBtnPressed];
        } else if (btnIndex == kBUTTON_E) {
            [musicApp previousBtnPressed];
        } else if (btnIndex == kBUTTON_F) {
            [musicApp playlistBtnPressed];
        }
    }
}

- (void) MWMGrantedLocalAppMode {
    [[[UIAlertView alloc] initWithTitle:@"MWM" message:@"iPod App has started." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    self.musicApp = [[MWMMusicControlApp alloc] init];
    [musicApp startAppMode];
}

- (void) MWMReleasedLocalAppMode {
    [[[UIAlertView alloc] initWithTitle:@"MWM" message:@"iPod App has stopped." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [musicApp stopAppMode];
    self.musicApp = nil;
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
        [[MWManager sharedManager] setBuzzWithRepeats:3];
    }
    
    UIImage *imageToSend = [MWManager imageForText:@"Application Mode"];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:imageToSend.CGImage] forMode:kMODE_APPLICATION inRect:CGRectMake(0, (96 - imageToSend.size.height)*0.5, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:NO buzzWhenDone:NO buzzRepeats:0];

    [[MWManager  sharedManager] setButton:kBUTTON_A atMode:kMODE_IDLE forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:BTNAPPMODETOGGLE];
    [[MWManager  sharedManager] setButton:kBUTTON_A atMode:kMODE_APPLICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:BTNAPPMODETOGGLE];
    [[MWManager  sharedManager] setButton:kBUTTON_A atMode:kMODE_NOTIFICATION forType:kBUTTON_TYPE_PRESS_AND_RELEASE withCallbackMsg:BTNNOTIFMODETOGGLE];
    
    [self drawIdleScreen];
}

- (void) watchDisconnected:(NSInteger)errorCode {
    
    [[MWMNotificationsManager sharedManager] setNotificationsEnabled:NO];
    
    [barIndicatorView setConnectable:YES];
    [self slider:nil DidStopAtMode:0];
    
    for (id widget in liveWidgets) {
        if ([widget respondsToSelector:@selector(stopUpdate)]) {
            [widget performSelector:@selector(stopUpdate)];
        }
    }
    
    for (int i = 0; i < liveWidgets.count; i++) {
        [liveWidgets replaceObjectAtIndex:i withObject:[NSNull null]];
    }
    
    row1Label.text = row2Label.text = row3Label.text = @"";
    
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
    } else if (errorCode == DISCONNECTEDBY8880) {
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Meta Watch does not implement the MWM service." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    self.watchDisplay.image = [MWManager imageForText:@"Disconnected\n\nTap the button below\nto connect."];
}
			
#pragma mark - View Controller lifecycle
- (void)viewDidLoad {
    
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
    
//    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"iPod"
//                                                                    style:UIBarButtonItemStyleBordered
//                                                                   target:self
//                                                                   action:@selector(leftBarBtnPressed:)]; 
//    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    
    self.liveWidgets = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];
    
    self.barIndicatorView.delegate = self;
    
    self.watchDisplay.image = [MWManager imageForText:@"Disconnected\n\nTap the button below\nto connect."];
    
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
