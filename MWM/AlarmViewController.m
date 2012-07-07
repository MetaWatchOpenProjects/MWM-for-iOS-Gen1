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
//  AlarmViewController.m
//  MWM
//
//  Created by Siqi Hao on 6/5/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "AlarmViewController.h"

#import "MWMNotificationsManager.h"

@interface AlarmViewController ()

@property (nonatomic, strong) IBOutlet UIDatePicker *timePickerView;
@property (nonatomic, strong) IBOutlet UISwitch *alarmSwitch;
@property (nonatomic, strong) IBOutlet UISlider *buzzCountsSlider;

@end

@implementation AlarmViewController

@synthesize timePickerView, alarmSwitch, buzzCountsSlider;

+ (NSInteger) minsOffetFromDate:(NSDate*)date {
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone systemTimeZone];
    unsigned int unitFlags = NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* dateComponents = [gregorian components:unitFlags fromDate:date];
    return dateComponents.hour*60 + dateComponents.minute;
}

+ (NSDate*) localFireDateFromOffset:(NSInteger)minsOffset {
    // Check if minsoffset is out of range
    if (minsOffset < 0 || minsOffset > 1439) {
        NSLog(@"sharedManager: localFireDateFromOffset - Failed: minsOffset out of range");
        return nil;
    }
    
    NSDate *nowDate = [NSDate date];
    
    
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone systemTimeZone];
    unsigned int unitFlags = NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* dateComponents = [gregorian components:unitFlags fromDate:nowDate];
    
    dateComponents.hour = minsOffset/60;
    dateComponents.minute = minsOffset%60;
    
    NSDate *theFireDateForCurrentTZ = [gregorian dateFromComponents:dateComponents];
    
    return theFireDateForCurrentTZ;
}

- (void) leftBarBtnPressed:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[NSNumber numberWithBool:alarmSwitch.isOn] forKey:@"notifWakeUpAlarm"];
    
    NSMutableDictionary *alarmDict = [NSMutableDictionary dictionary];
    [alarmDict setObject:[NSNumber numberWithInteger:[AlarmViewController minsOffetFromDate:timePickerView.date]] forKey:@"minsOffset"];
    [prefs setObject:alarmDict forKey:@"notifWakeUpAlarmData"];
    
    [prefs synchronize];
    
    [[MWMNotificationsManager sharedManager] setWakeUpAlarmEnabled:alarmSwitch.isOn];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Alarms";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(leftBarBtnPressed:)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
}

- (void) viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [alarmSwitch setOn:[[prefs objectForKey:@"notifWakeUpAlarm"] boolValue]];
    
    NSDate *fireDate = [AlarmViewController localFireDateFromOffset:[[prefs valueForKeyPath:@"notifWakeUpAlarmData.minsOffset"] integerValue]];
    [timePickerView setDate:fireDate];
    
    [super viewWillAppear:animated];
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
