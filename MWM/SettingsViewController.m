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
//  SettingsViewController.m
//  MWM
//
//  Created by Siqi Hao on 5/29/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "SettingsViewController.h"

#import "MWMNotificationsManager.h"

#import "WidgetsSelectionViewController.h"
#import "TestViewController.h"
#import "AlarmViewController.h"

#import "MWManager.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;

@end

@implementation SettingsViewController

@synthesize mainTableView;

- (void) notifCalendarToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"notifCalendar"];
    [prefs synchronize];
    
    [[MWMNotificationsManager sharedManager] setCalendarAlertEnabled:toggle.isOn];
}

- (void) drawDashLinesToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"drawDashLines"];
    [prefs synchronize];
    [[MWManager sharedManager] drawIdleLines:[[[NSUserDefaults standardUserDefaults] objectForKey:@"drawDashLines"] boolValue]];
}

- (void) buzzOnConnectToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"buzzOnConnect"];
    [prefs synchronize];
}

- (void) autoReconnectToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"autoReconnect"];
    [prefs synchronize];
}

- (void) autoConnectToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"autoConnect"];
    [prefs synchronize];
}

- (void) rememberOnConnectToggleValueChanged:(id)sender {
    UISwitch *toggle = (UISwitch*)sender;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:toggle.isOn] forKey:@"rememberOnConnect"];
    [prefs synchronize];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return 2;
    } else if (section == 3)  {
        return 2;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"General";
    } else if (section == 1) {
        return @"Connection";
    } else if (section == 2) {
        return @"Idle Widgets";
    } else if (section == 3) {
        return @"Notifications";
    } else {
        return @"Other";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        UISwitch *toggleSwitch = [[UISwitch alloc] init];
        cell.textLabel.numberOfLines = 0;
        toggleSwitch.center = CGPointMake(260, 22);
        toggleSwitch.tag = 100;
        [cell addSubview:toggleSwitch];
        cell.imageView.image = [UIImage imageNamed:@"setting_icon.jpg"];
    }
    
    // Configure the cell...
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    UISwitch *toggleSwitch = (UISwitch*)[cell viewWithTag:100];
    [toggleSwitch setOn:NO];
    toggleSwitch.hidden = NO;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Auto Connect";
            
            [toggleSwitch setOn:[[prefs objectForKey:@"autoConnect"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(autoConnectToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Reconnect on Diconnect";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            
            [toggleSwitch setOn:[[prefs objectForKey:@"autoReconnect"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(autoReconnectToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        } else {
            cell.textLabel.text = @"Vibrate on Connect";
            
            [toggleSwitch setOn:[[prefs objectForKey:@"buzzOnConnect"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(buzzOnConnectToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Remember the Watch\non First Connect";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            
            [toggleSwitch setOn:[[prefs objectForKey:@"rememberOnConnect"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(rememberOnConnectToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"Watch Address:"];
            toggleSwitch.hidden = YES;
            NSString *uuidString = [[NSUserDefaults standardUserDefaults] valueForKey:@"savedUUID"];
            if (uuidString.length == 0) {
                cell.detailTextLabel.text = @"not available";
            } else {
                cell.detailTextLabel.text = [uuidString substringWithRange:NSMakeRange(uuidString.length - 8, 8)];
            }
        } else {
            cell.textLabel.text = @"Unpair the watch";
            toggleSwitch.hidden = YES;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Draw Separation Line";
            
            [toggleSwitch setOn:[[prefs objectForKey:@"drawDashLines"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(drawDashLinesToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        } else {
            cell.textLabel.text = @"Idle Screen Layout";
            toggleSwitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else if (indexPath.section == 3)  {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Calender Events";
            
            [toggleSwitch setOn:[[prefs objectForKey:@"notifCalendar"] boolValue]];
            [toggleSwitch addTarget:self action:@selector(notifCalendarToggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        } else {
            cell.textLabel.text = @"Wake Up Alarm";
            toggleSwitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Tests";
            toggleSwitch.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    
    return cell; 
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        } else {
            
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        } else {
            NSUserDefaults *perfs = [NSUserDefaults standardUserDefaults];
            [perfs setValue:@"" forKey:@"savedUUID"];
            [perfs synchronize];
            [mainTableView reloadData];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
        } else {
            WidgetsSelectionViewController *VC = [[WidgetsSelectionViewController alloc] initWithNibName:@"WidgetsSelectionViewController" bundle:[NSBundle mainBundle]];
            VC.delegate = [self.navigationController.viewControllers objectAtIndex:0];
            [self.navigationController pushViewController:VC animated:YES];
        }
    } else if (indexPath.section == 3)  {
        if (indexPath.row == 0) {
            
        } else if (indexPath.row == 1) {
            
        } else {
            AlarmViewController *VC = [[AlarmViewController alloc] initWithNibName:@"AlarmViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:VC animated:YES];
        }
    } else {
        if (indexPath.row == 0) {
            TestViewController *VC = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - View Controller Lefe Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Settings";
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
