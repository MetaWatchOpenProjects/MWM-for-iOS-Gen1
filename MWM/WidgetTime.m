//
//  WidgetTime.m
//  MWM
//
//  Created by Siqi Hao on 4/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "WidgetTime.h"

@implementation WidgetTime

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, widgetName, delegate;

@synthesize timeLabel, dateLabel, watchTimer, use12H, showSec, monthFirst;

static NSInteger widget = 10000;
static CGFloat widgetWidth = 96;
static CGFloat widgetHeight = 30;

+ (CGSize) getWidgetSize {
    return CGSizeMake(widgetWidth, widgetHeight);
}

- (id)init
{
    self = [super init];
    if (self) {
        widgetSize = CGSizeMake(widgetWidth, widgetHeight);
        preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
        widgetID = widget;
        preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
        updateIntvl = -1;
        updatedTimestamp = 0;
        use12H = YES;
        showSec = NO;
        monthFirst = YES;
        
        widgetName = @"Time";
        
        // date label
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 36, 24)];
        dateLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        dateLabel.textAlignment = UITextAlignmentLeft;
        dateLabel.numberOfLines = 3;
        dateLabel.font = [UIFont fontWithName:@"MetaWatch Large caps 8pt" size:8];
        [preview addSubview:dateLabel];
        
        // time label
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 7, 89, 17)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        timeLabel.textAlignment = UITextAlignmentLeft;
        timeLabel.font = [UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:23];
        [preview addSubview:timeLabel];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *dataDict = [prefs valueForKey:[NSString stringWithFormat:@"%d", widgetID]];
        if (dataDict == nil) {
            [self saveData];
        } else {
            use12H = [[dataDict valueForKey:@"use12H"] boolValue];
            showSec = [[dataDict valueForKey:@"showSec"] boolValue];
            monthFirst = [[dataDict valueForKey:@"monthFirst"] boolValue];
        }
        
        // setting view
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WidgetTimeSettingView" owner:nil options:nil];
        self.settingView = [topLevelObjects objectAtIndex:0];
        self.settingView.alpha = 0;
        
        if (use12H) {
            [(UISegmentedControl*)[settingView viewWithTag:3001] setSelectedSegmentIndex:0];
        } else {
            [(UISegmentedControl*)[settingView viewWithTag:3001] setSelectedSegmentIndex:1];
        }
        [(UISegmentedControl*)[settingView viewWithTag:3001] addTarget:self action:@selector(hourSegValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [(UISwitch*)[settingView viewWithTag:3002] addTarget:self action:@selector(toggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        [(UISwitch*)[settingView viewWithTag:3002] setOn:showSec];
        
        if (monthFirst) {
            [(UISegmentedControl*)[settingView viewWithTag:3003] setSelectedSegmentIndex:0];
        } else {
            [(UISegmentedControl*)[settingView viewWithTag:3003] setSelectedSegmentIndex:1];
        }
        [(UISegmentedControl*)[settingView viewWithTag:3003] addTarget:self action:@selector(monthSegValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void) saveData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[NSNumber numberWithBool:showSec] forKey:@"showSec"];
    [dataDict setObject:[NSNumber numberWithBool:use12H] forKey:@"use12H"];
    [dataDict setObject:[NSNumber numberWithBool:monthFirst] forKey:@"monthFirst"];
    [prefs setObject:dataDict forKey:[NSString stringWithFormat:@"%d", widgetID]];
    
    //NSLog(@"WeatherData: %@", [dataDict description]);
    
    [prefs synchronize];
}

- (void) toggleValueChanged:(id)sender {
    UISwitch *segCtrl = (UISwitch*)sender;
    showSec = segCtrl.isOn;
    [[MWManager sharedManager] setWatchShowSec:showSec];
    [self saveData];
    //[delegate widget:self updatedWithError:nil];
}

- (void) hourSegValueChanged:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl*)sender;
    if (segCtrl.selectedSegmentIndex == 0) {
        use12H = YES;
    } else {
        use12H = NO;
    }
    [[MWManager sharedManager] setWatchUse12H:use12H];
    [self saveData];
}

- (void) monthSegValueChanged:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl*)sender;
    if (segCtrl.selectedSegmentIndex == 0) {
        monthFirst = YES;
    } else {
        monthFirst = NO;
    }
    [[MWManager sharedManager] setWatchShowMonthFirst:monthFirst];
    [self saveData];
}

- (void) prepareToUpdate {
    [delegate widgetViewCreated:self];
    [[MWManager sharedManager] setWatchShowMonthFirst:use12H];
    [[MWManager sharedManager] setWatchShowSec:showSec];
    [[MWManager sharedManager] setWatchShowMonthFirst:monthFirst];
}

- (void) update:(NSInteger)timestamp {
    if (updateIntvl < 0 && timestamp > 0) {
        return;
    }
    if (timestamp < 0 || timestamp - updatedTimestamp >= updateIntvl) {
        updatedTimestamp = timestamp;
        if (watchTimer == nil) {
            self.watchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(watchTimerCalled:) userInfo:nil repeats:YES];
        }
    }
    if (timestamp < 0) {
        updatedTimestamp = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
    }
}

- (void) stopUpdate {
    [watchTimer invalidate];
    self.watchTimer = nil;
}

- (void) watchTimerCalled:(NSTimer*)timer {
    NSDate *now = [[NSDate alloc] init];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    if (showSec) {
        [timeFormat setDateFormat:@"hh:mm:ss"];
        NSString *theTime = [timeFormat stringFromDate:now];
        timeLabel.text = theTime;
        dateLabel.text = @"";
    } else {
        [timeFormat setDateFormat:@"hh:mm"];
        
        if (use12H) {
            if (monthFirst) {
                [dateFormat setDateFormat:@"a'\n'EEE'\n'MM/dd"];
            } else {
                [dateFormat setDateFormat:@"a'\n'EEE'\n'dd/MM"];
            }
        } else {
            if (monthFirst) {
                [dateFormat setDateFormat:@"EEE'\n'MM/dd'\n'yyyy"];
            } else {
                [dateFormat setDateFormat:@"EEE'\n'dd/MM'\n'yyyy"];
            }
        }

        timeLabel.text = [timeFormat stringFromDate:now];
        dateLabel.text = [dateFormat stringFromDate:now];
    }
    
    
    
    
    //NSLog(@"tick, %@, %@", theTime , theDate);
}

- (void) dealloc {
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
