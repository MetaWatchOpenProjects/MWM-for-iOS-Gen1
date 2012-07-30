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
//  TestViewController.m
//  MWM
//
//  Created by Siqi Hao on 6/5/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "TestViewController.h"

#import "MWManager.h"

@interface TestViewController ()

@property (nonatomic, strong) IBOutlet UISegmentedControl *responseSegCtrl;
@property (nonatomic, strong) IBOutlet UILabel *appIDLabel;

- (IBAction) responseSegCtrlValueChanged:(id)sender;
- (IBAction) clearBtnPressed:(id)sender;
- (IBAction) sendBtnPressed:(id)sender;
- (IBAction) nvalBtnPressed:(id)sender;
- (IBAction) row1BtnPressed:(id)sender;
- (IBAction) row48BtnPressed:(id)sender;
- (IBAction) row96BtnPressed:(id)sender;
- (IBAction) cleanBtnPressed:(id)sender;

@end

@implementation TestViewController

@synthesize responseSegCtrl, appIDLabel;

- (IBAction) responseSegCtrlValueChanged:(id)sender {
    if (responseSegCtrl.selectedSegmentIndex == 0) {
        [[MWManager sharedManager] setMWMWriteWithResponse:YES];
    } else {
        [[MWManager sharedManager] setMWMWriteWithResponse:NO];
    }
}

- (IBAction) clearBtnPressed:(id)sender {
    [[MWManager sharedManager] forceReleaseAccessToAppModeFromApp:[[MWManager sharedManager] currentAppModeIdentifier]];
    appIDLabel.text = [[MWManager sharedManager] currentAppModeIdentifier];
}

- (IBAction)sendBtnPressed:(id)sender {
    UIImage *sendingImg = [UIImage imageNamed:@"2.bmp"];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:sendingImg.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, 0, sendingImg.size.width, sendingImg.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:NO shouldUpdate:YES buzzWhenDone:NO buzzRepeats:0];
}

- (IBAction)nvalBtnPressed:(id)sender {
    [[MWManager sharedManager] performSelector:@selector(testReadNval) withObject:nil];
}

- (IBAction) row1BtnPressed:(id)sender {
    UIImage *sendingImg = [UIImage imageNamed:@"1row.bmp"];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:sendingImg.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, 0, sendingImg.size.width, sendingImg.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:YES buzzWhenDone:NO buzzRepeats:0];
}

- (IBAction) row48BtnPressed:(id)sender {
    UIImage *sendingImg = [UIImage imageNamed:@"48rows.bmp"];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:sendingImg.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, 0, sendingImg.size.width, sendingImg.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:YES buzzWhenDone:NO buzzRepeats:0];
}

- (IBAction) row96BtnPressed:(id)sender {
    UIImage *sendingImg = [UIImage imageNamed:@"96rows.bmp"];
    [[MWManager sharedManager] writeImage:[MWManager bitmapDataForCGImage:sendingImg.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, 0, sendingImg.size.width, sendingImg.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:YES buzzWhenDone:NO buzzRepeats:0];
}

- (IBAction) cleanBtnPressed:(id)sender {
    [[MWManager sharedManager] loadTemplate:kMODE_NOTIFICATION];
    [[MWManager sharedManager] updateDisplay:kMODE_NOTIFICATION];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Tests";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLabel) name:@"MWMDidCleanAppMode" object:[MWManager sharedManager]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLabel) name:@"MWMDidGrantAppMode" object:[MWManager sharedManager]];
    }
    return self;
}

- (void) syncLabel {
    appIDLabel.text = [[MWManager sharedManager] currentAppModeIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs objectForKey:@"writeWithResponse"] boolValue]) {
        [responseSegCtrl setSelectedSegmentIndex:0];
    } else {
        [responseSegCtrl setSelectedSegmentIndex:1];
    }
    appIDLabel.text = [[MWManager sharedManager] currentAppModeIdentifier];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
