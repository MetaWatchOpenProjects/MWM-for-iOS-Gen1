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
    [[MWManager sharedManager] releaseAccessToAppModeFromApp:[[MWManager sharedManager] currentAppModeIdentifier]];
    appIDLabel.text = [[MWManager sharedManager] currentAppModeIdentifier];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Tests";
    }
    return self;
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

@end
