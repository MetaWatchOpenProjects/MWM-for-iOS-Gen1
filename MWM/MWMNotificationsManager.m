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
//  MWMNotificationsManager.m
//  MWM
//
//  Created by Siqi Hao on 6/6/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "MWMNotificationsManager.h"

#import "MWManager.h"
#import "AppDelegate.h"

@interface MWMNotificationsManager () 

@property (nonatomic) NSInteger nextCalendarUpdateTimestamp;
@property (nonatomic) NSInteger nextWakeUpAlarmUpdateTimestamp;

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) EKEvent *nextEvent;

@end

@implementation MWMNotificationsManager

@synthesize nextCalendarUpdateTimestamp, eventStore, nextEvent;

@synthesize nextWakeUpAlarmUpdateTimestamp;

static MWMNotificationsManager *sharedManager;

#pragma mark - Calendar

- (void) setNotificationsEnabled:(BOOL)enable {
    if (enable) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [self setCalendarAlertEnabled:[[prefs objectForKey:@"notifCalendar"] boolValue]];
        [self enableTimeZoneSupport:[[prefs objectForKey:@"notifTimezone"] boolValue]];
        [self setWakeUpAlarmEnabled:[[prefs objectForKey:@"notifWakeUpAlarm"] boolValue]];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        nextCalendarUpdateTimestamp = 0;
        nextWakeUpAlarmUpdateTimestamp = 0;
    }
    
}

- (void) setCalendarAlertEnabled:(BOOL)enable {
    if (enable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:eventStore];
        self.eventStore= [[EKEventStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged)
                                                     name:EKEventStoreChangedNotification object:eventStore];
        [self storeChanged];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    }
}

- (void) storeChanged {
    self.nextEvent = nil;
    
    NSDate *startDate = [NSDate date];
    NSDate *endDate   = [NSDate distantFuture];
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate
                                                                 endDate:endDate
                                                               calendars:nil];
    
    NSMutableArray *newEventsArray = [NSMutableArray array];
    
    for (EKEvent *event in [eventStore eventsMatchingPredicate:predicate]) {
        if ([event.startDate timeIntervalSinceNow] > 0) {
            [newEventsArray addObject:event];
        }
    }
    
    [newEventsArray sortUsingSelector:@selector(compareStartDateWithEvent:)];
    
    if (newEventsArray.count > 0) {
        
        self.nextEvent = [newEventsArray objectAtIndex:0];
        nextCalendarUpdateTimestamp = [nextEvent.startDate timeIntervalSinceReferenceDate];
        NSLog(@"NotificationManager detected calendar changes.\nSend notification in:%f", nextCalendarUpdateTimestamp - [NSDate timeIntervalSinceReferenceDate]);
    }
}

#pragma mark - Timezone

- (void) enableTimeZoneSupport:(BOOL)enable {
    if (enable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemTimeZoneDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemTimeZoneChanged) name:NSSystemTimeZoneDidChangeNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemTimeZoneDidChangeNotification object:nil];
    }
}

- (void) systemTimeZoneChanged {
    [[MWManager sharedManager] setWatchRTC];
}

#pragma mark - Wake Up Alarm

- (void) setWakeUpAlarmEnabled:(BOOL)enable {
    if (enable) {
        [self updateNextAlarmTimestamp];
    } else {
        nextWakeUpAlarmUpdateTimestamp = 0;
    }
}

- (void) updateNextAlarmTimestamp {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger alarmOffset = [[prefs valueForKeyPath:@"notifWakeUpAlarmData.minsOffset"] integerValue];
    NSInteger currertOffet = [MWMNotificationsManager currentWallClockOffsetInMins];
    if (currertOffet >= alarmOffset) {
        // Alarm Passed Today
        nextWakeUpAlarmUpdateTimestamp = [NSDate timeIntervalSinceReferenceDate] + ((1440 - currertOffet) + alarmOffset)*60;
    } else {
        nextWakeUpAlarmUpdateTimestamp = [NSDate timeIntervalSinceReferenceDate] + (alarmOffset - currertOffet)*60;
    }
}

+ (NSInteger) currentWallClockOffsetInMins {
    NSDate *todayDate = [NSDate date];
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.timeZone = [NSTimeZone systemTimeZone];
    
    unsigned int unitFlags = NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* dateComponents = [gregorian components:unitFlags fromDate:todayDate];
    
    return dateComponents.hour*60 + dateComponents.minute;
}

#pragma mark - Singleton

+ (MWMNotificationsManager *) sharedManager {
    @synchronized([MWMNotificationsManager class])
	{
		if (sharedManager == nil) {
            sharedManager = [[super allocWithZone:NULL] init];
        }
        return sharedManager;
	}
    
}

- (id) init {
    self = [super init];
    if (self) {
        // Initialization code here.
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([prefs objectForKey:@"notifCalendar"] == nil) {
            [prefs setValue:[NSNumber numberWithBool:YES] forKeyPath:@"notifCalendar"];
        }
        if ([prefs objectForKey:@"notifTimezone"] == nil) {
            [prefs setValue:[NSNumber numberWithBool:YES] forKeyPath:@"notifTimezone"];
        }
        
        [prefs synchronize];
        
        nextCalendarUpdateTimestamp = 0;
        nextWakeUpAlarmUpdateTimestamp = 0;
    }
    
    return self;
}

- (void) update:(NSInteger)timestamp {
    // Calendar
    if (timestamp > nextCalendarUpdateTimestamp && nextCalendarUpdateTimestamp > 0) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        
        NSString *textToDisplay = [NSString stringWithFormat:@"%@\n \n%@", [format stringFromDate:nextEvent.startDate], nextEvent.title];
        UIImage *imageToSend = [AppDelegate imageForText:textToDisplay];
        [[MWManager sharedManager] writeImage:[AppDelegate imageDataForCGImage:imageToSend.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, (96 - imageToSend.size.height)*0.5, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:YES buzzWhenDone:YES buzzRepeats:8];
        
        [self storeChanged];
    }
    
    if (timestamp > nextWakeUpAlarmUpdateTimestamp && nextWakeUpAlarmUpdateTimestamp > 0) {        
        NSString *textToDisplay = [NSString stringWithFormat:@"Time to Wake Up"];
        UIImage *imageToSend = [AppDelegate imageForText:textToDisplay];
        [[MWManager sharedManager] writeImage:[AppDelegate imageDataForCGImage:imageToSend.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, (96 - imageToSend.size.height)*0.5, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES shouldUpdate:YES buzzWhenDone:YES buzzRepeats:8];
        
        [self updateNextAlarmTimestamp];
    }
}

@end
