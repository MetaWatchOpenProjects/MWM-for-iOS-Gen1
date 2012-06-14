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

@implementation WidgetCalendar

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, widgetName, delegate, previewRef;

@synthesize eventsArray, nextEvent, showMode, eventStore, internalUpdateTimer, nextUpdateTimestamp;

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
        nextUpdateTimestamp = -1;
        
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
    [self update:-1];
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
    if (timestamp > nextUpdateTimestamp && nextUpdateTimestamp > 0) {
        [self internalUpdate:nil];
        nextUpdateTimestamp = -1;
        return;
    }
    
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
        
        for (EKEvent *event in [eventStore eventsMatchingPredicate:predicate]) {
            if ([event.startDate timeIntervalSinceNow] > 0) {
                [newEventsArray addObject:event];
            }
        }
        
        [newEventsArray sortUsingSelector:@selector(compareStartDateWithEvent:)];
        
        if (showMode == 0) {
            [self updateModeNext:newEventsArray];
        } else if (showMode == 1) {
            [self updateModeNextThree:newEventsArray];
        }
        
        if (newEventsArray.count > 0) {
            nextUpdateTimestamp = [nextEvent.startDate timeIntervalSinceReferenceDate] + 10;
            NSLog(@"Next internal update in:%d", nextUpdateTimestamp);
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
    
    
    
    NSLog(@"Event Start Date:%@", [self transformedValue:nextEvent.startDate]);
    
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
    [[self transformedValue:nextEvent.startDate] drawInRect:CGRectMake(titleRect.origin.x + 1, titleRect.origin.y + 1, titleRect.size.width, titleRect.size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
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
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"ddMM" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSInteger currentHeight = 4;
    for (int i = 0; i < [events count]; i++) {
        EKEvent *currentEvent = [events objectAtIndex:i];
        NSString *drawingString = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:currentEvent.startDate], currentEvent.title];
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

// snippet from BDDateTransformer.m //2
- (NSString*)transformedValue:(NSDate *)date
{
    // Initialize the formatter.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    // Initialize the calendar and flags.
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *suppliedDate = [calendar dateFromComponents:comps];
    
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = 0; i < 7; i++)
    {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] + i];
        NSDate *referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
        
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
        {
            // Today's time (a la iPhone Mail)
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            return [NSString stringWithFormat:@"Today %@", [formatter stringFromDate:date]];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
        {
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            return [NSString stringWithFormat:@"Tomorrow %@", [formatter stringFromDate:date]];
        }
        else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
        {
            // Day of the week
            [formatter setDateStyle:NSDateFormatterNoStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
            return [NSString stringWithFormat:@"%@ %@", day, [formatter stringFromDate:date]];
        }
    }
    
    // It's not in those eight days.
    NSString *defaultDate = [formatter stringFromDate:date];
    return defaultDate;
}

- (void) dealloc {
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
