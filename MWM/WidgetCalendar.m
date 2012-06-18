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
//  WidgetCalendar.m
//  MWM
//
//  Created by Siqi Hao on 4/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "WidgetCalendar.h"
#import "WidgetTime.h"

@implementation WidgetCalendar

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, widgetName, delegate, previewRef;

@synthesize eventsArray, nextEvent, showMode, eventStore, internalUpdateTimer;

static NSInteger widget = 10002;
static CGFloat widgetWidth = 96;
static CGFloat widgetHeight = 32;

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
        widgetName = @"Calendar";
        showMode = 0;
        updateIntvl = -1;
        updatedTimestamp = 0;
        
        eventStore = [[EKEventStore alloc] init];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *dataDict = [prefs valueForKey:[NSString stringWithFormat:@"%d", widgetID]];
        if (dataDict == nil) {
            [self saveData];
        } else {
            showMode = [[dataDict valueForKey:@"showMode"] integerValue];
        }
        
        // Setting
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WidgetCalendarSettingView" owner:nil options:nil];
        self.settingView = [topLevelObjects objectAtIndex:0];
        self.settingView.alpha = 0;
        
        [(UISegmentedControl*)[settingView viewWithTag:3001] addTarget:self action:@selector(toggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        [(UISegmentedControl*)[settingView viewWithTag:3001] setSelectedSegmentIndex:showMode];
        
    }
    return self;
}

- (void) saveData {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    [dataDict setObject:[NSNumber numberWithInteger:showMode] forKey:@"showMode"];
    [prefs setObject:dataDict forKey:[NSString stringWithFormat:@"%d", widgetID]];
    [prefs synchronize];
}


- (void) toggleValueChanged:(id)sender {
    showMode = [(UISegmentedControl*)sender selectedSegmentIndex];
    [self saveData];
    [self update:-1];
}

- (void) storeChanged {
    NSLog(@"Calendar Changes Detected");
    //[self update:-1];
    [internalUpdateTimer invalidate];
    internalUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(internalUpdate:) userInfo:nil repeats:NO];
}

- (void) timeChanged {
    NSLog(@"System time changed");
    [self update:-1];
}

- (void) prepareToUpdate {
    [delegate widgetViewCreated:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeChanged)
                                                 name:EKEventStoreChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChanged) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

- (void) stopUpdate {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) update:(NSInteger)timestamp {
    if (updateIntvl < 0 && timestamp > 0) {
        return;
    }
    if (timestamp < 0 || timestamp - updatedTimestamp >= updateIntvl) {
        if (timestamp < 0) {
            updatedTimestamp = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
        } else {
            updatedTimestamp = timestamp;
        }
        
        NSDate *startDate = [NSDate date];
        NSDate *endDate   = [NSDate distantFuture];
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate
                                                                     endDate:endDate
                                                                   calendars:nil];

        NSMutableArray *newEventsArray = [NSMutableArray array];

        // get events sorted by start date
		for (EKEvent *event in [[eventStore eventsMatchingPredicate:predicate] sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)]) {
            if ([event.startDate timeIntervalSinceNow] > 0) {
                [newEventsArray addObject:event];
            }
			// no need to get more than three events
			if (newEventsArray.count >= 3) break;
        }

        if (showMode == 0) {
            [self updateModeNext:newEventsArray];
        } else if (showMode == 1) {
            [self updateModeNextThree:newEventsArray];
        }

        if (newEventsArray.count > 0) {
            NSLog(@"Next internal update in:%f", [nextEvent.endDate timeIntervalSinceDate:[NSDate date]]+10);
            self.internalUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:[nextEvent.endDate timeIntervalSinceDate:[NSDate date]]+10 target:self selector:@selector(internalUpdate:) userInfo:nil repeats:NO];
        }
        
        self.eventsArray = newEventsArray;
    }
    
}

- (void) internalUpdate:(NSTimer*)theTimer {
    NSLog(@"WidgetCalendar: internalupdate");
    [self update:-1];
    self.internalUpdateTimer = nil;
}

- (void) updateModeNext:(NSArray*)events {
    if (events.count == 0) {
        UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
        //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
        CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
        
        UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
        
        // Fill background as white
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
        
        // Fill title area as black
        CGRect titleRect = CGRectMake(2, 3, widgetWidth - 4, 7);
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextFillRect(ctx, titleRect);
        
        // Paint text over the title area 
        CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
        [@"No incoming event" drawInRect:CGRectMake(titleRect.origin.x + 1, titleRect.origin.y + 1, titleRect.size.width, titleRect.size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
        
        // transfer image
        previewRef = CGBitmapContextCreateImage(ctx);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();   
        
        for (UIView *view in self.preview.subviews) {
            [view removeFromSuperview];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 7001;
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [self.preview addSubview:imageView];
        
        [delegate widget:self updatedWithError:nil];
        return;
    } else {
        self.nextEvent = [events objectAtIndex:0];
    }


    NSLog(@"Event Start Date:%@", [self relativeEventDate:nextEvent]);
    
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
    //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
    CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
    
    UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
    
    // Fill background as white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
    
    // Fill title area as black
    CGRect titleRect = CGRectMake(2, 3, widgetWidth - 4, 7);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, titleRect);
    
    // Paint text over the title area 
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
    [[self relativeEventDate:nextEvent] drawInRect:CGRectMake(titleRect.origin.x + 1, titleRect.origin.y + 1, titleRect.size.width, titleRect.size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];

    // Draw content
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    [nextEvent.title drawInRect:CGRectMake(titleRect.origin.x + 1, titleRect.origin.y + titleRect.size.height + 1, titleRect.size.width, widgetHeight - titleRect.size.height - titleRect.origin.y - 1) withFont:font lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    
    // transfer image
    previewRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();   
    
    for (UIView *view in self.preview.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 7001;
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.preview addSubview:imageView];
    
    [delegate widget:self updatedWithError:nil];
    
}

- (void) updateModeNextThree:(NSArray*)events {
    if (events.count == 0) {
        UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
        //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
        CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
        
        UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
        
        // Fill background as white
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
        
        // Fill title area as black
        CGRect titleRect = CGRectMake(2, 3, widgetWidth - 4, 7);
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextFillRect(ctx, titleRect);
        
        // Paint text over the title area 
        CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
        [@"No event for today" drawInRect:CGRectMake(titleRect.origin.x + 1, titleRect.origin.y + 1, titleRect.size.width, titleRect.size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
        
        // transfer image
        previewRef = CGBitmapContextCreateImage(ctx);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();   
        
        for (UIView *view in self.preview.subviews) {
            [view removeFromSuperview];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 7001;
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [self.preview addSubview:imageView];
        
        [delegate widget:self updatedWithError:nil];
        return;
    } else {
        self.nextEvent = [events objectAtIndex:0];
    }
    
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
    CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
    
    UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);

    // Fill background as white
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));

    // display date according to clock setting
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[WidgetTime getBoolPref:@"monthFirst"]?@"MM/dd":@"dd/MM"];

	// Formatter to display time for today's events (use 24-hour time to save space)
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];

    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSInteger currentHeight = 4;
    for (int i = 0; i < [events count]; i++) {
        EKEvent *currentEvent = [events objectAtIndex:i];
        
        // Set formatter based upon if event is today (for today show time, otherwise show date)
		NSDateFormatter *formatter =  !currentEvent.allDay && [self isToday:currentEvent.startDate] ? timeFormatter : dateFormatter;
        
		NSString *drawingString = [NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:currentEvent.startDate], currentEvent.title];
		
        [drawingString drawInRect:CGRectMake(3, currentHeight, 90, 5) withFont:font lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
        currentHeight = currentHeight + 9; // font is 5
        if (i == 2) {
            break;
        }
    }
    
    // transfer image
    previewRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();   
    
    for (UIView *view in self.preview.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 7001;
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.preview addSubview:imageView];
    
    [delegate widget:self updatedWithError:nil];
}

// Calculate the days between two dates
- (int)daysBetween:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit units=NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comp1=[calendar components:units fromDate:startDate];
    NSDateComponents *comp2=[calendar components:units fromDate:endDate];
    [comp1 setHour:12];
    [comp2 setHour:12];
    NSDate *date1=[calendar dateFromComponents: comp1];
    NSDate *date2=[calendar dateFromComponents: comp2];
    return [[calendar components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0] day];
}

// Is the specified date today?
- (BOOL)isToday:(NSDate *)date
{
	return [self daysBetween:[NSDate date] toDate:date] == 0;
}

// Get a relative date format from the event
- (NSString *)relativeEventDate:(EKEvent *)event
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateStyle:NSDateFormatterNoStyle];
	if (event.allDay) [timeFormatter setTimeStyle:NSDateFormatterNoStyle];
    else [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
	int days = [self daysBetween:[NSDate date] toDate:event.startDate];
	if (days >= 0 && days < 8) {
		if (days < 2) [dateFormatter setDoesRelativeDateFormatting:YES];
		else if (days < 8) [dateFormatter setDateFormat:@"cccc"];
	}
	return [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:event.startDate], [timeFormatter stringFromDate:event.startDate]];
}

- (void) dealloc {
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
