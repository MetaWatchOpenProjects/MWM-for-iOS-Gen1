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

@property (nonatomic, strong) NSTimer *notifCalendarTimer;

@property (nonatomic, strong) NSTimer *storeChangedTimer;

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation MWMNotificationsManager

@synthesize notifCalendarTimer, storeChangedTimer, eventStore;

static MWMNotificationsManager *sharedManager;

#pragma mark - Calendar

- (void) setNotificationsEnabled:(BOOL)enable {
    if (enable) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [self setCalendarAlertEnabled:[[prefs objectForKey:@"notifCalendar"] boolValue]];
        [self enableTimeZoneSupport:[[prefs objectForKey:@"notifTimezone"] boolValue]];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [notifCalendarTimer invalidate];
        self.notifCalendarTimer = nil;
    }
    
}

- (void) setCalendarAlertEnabled:(BOOL)enable {
    if (enable) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:eventStore];
        self.eventStore= [[EKEventStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChangedHandler)
                                                     name:EKEventStoreChangedNotification object:eventStore];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChangedHandler)
                                                     name:EKEventStoreChangedNotification object:nil];
        
        [self storeChanged];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EKEventStoreChangedNotification object:nil];
    }
}

- (void) storeChangedHandler {
    [storeChangedTimer invalidate];
    storeChangedTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(storeChanged) userInfo:nil repeats:NO];
}

- (void) storeChanged {
    [self.eventStore refreshSourcesIfNecessary];
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
    
    [self.notifCalendarTimer invalidate];
    
    if (newEventsArray.count > 0) {
        
        EKEvent *nextEvent = [newEventsArray objectAtIndex:0];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH:mm"];
        
        
        NSString *textToDisplay = [NSString stringWithFormat:@"%@\n \n%@", [format stringFromDate:nextEvent.startDate], nextEvent.title];
        self.notifCalendarTimer = [NSTimer scheduledTimerWithTimeInterval:[nextEvent.startDate timeIntervalSinceDate:[NSDate date]] target:self selector:@selector(internalUpdate:) userInfo:textToDisplay repeats:NO];
        NSLog(@"NotificationManager detected calendar changes.\nSend notification in:%f", [nextEvent.startDate timeIntervalSinceDate:[NSDate date]]);
    }
}

- (void) internalUpdate:(NSTimer*)timer {
    UIImage *imageToSend = [AppDelegate imageForText:timer.userInfo];
    
    [[MWManager sharedManager] writeImage:[AppDelegate imageDataForCGImage:imageToSend.CGImage] forMode:kMODE_NOTIFICATION inRect:CGRectMake(0, (96 - imageToSend.size.height)*0.5, imageToSend.size.width, imageToSend.size.height) linesPerMessage:LINESPERMESSAGE shouldLoadTemplate:YES buzzWhenDone:YES buzzRepeats:8];
    
    self.notifCalendarTimer = nil;
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

- (id)init
{
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

    }
    
    return self;
}

@end
