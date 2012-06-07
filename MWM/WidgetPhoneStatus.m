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
//  WidgetPhoneStatus.m
//  MWM
//
//  Created by Siqi Hao on 5/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "WidgetPhoneStatus.h"

@implementation WidgetPhoneStatus

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, widgetName, previewRef, delegate;

static NSInteger widget = 10003;
static CGFloat widgetWidth = 96;
static CGFloat widgetHeight = 32;

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
        
        widgetName = @"PhoneStatus";

        // setting view
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WidgetPhoneStatusSettingView" owner:nil options:nil];
        self.settingView = [topLevelObjects objectAtIndex:0];
        self.settingView.alpha = 0;
    }
    return self;
}

- (void) prepareToUpdate {
    [delegate widgetViewCreated:self];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChange)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryLevelDidChange)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:nil];
}

- (void) batteryStateDidChange {
    NSLog(@"batteryStateDidChange");
    [self update:-1];
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
        // post an alert
    }
}

- (void) batteryLevelDidChange {
    NSLog(@"batteryLevelDidChange");
    [self update:-1];
}

- (void) update:(NSInteger)timestamp {
    if (updateIntvl < 0 && timestamp > 0) {
        return;
    }
    if (timestamp < 0 || timestamp - updatedTimestamp >= updateIntvl) {
        updatedTimestamp = timestamp;
        
        // Do drawing
        [self drawWidget];
        
        [delegate widget:self updatedWithError:nil];
    }
    if (timestamp < 0) {
        updatedTimestamp = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
    }
}

- (void) drawWidget {
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
    //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
    CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
    
    UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    CGRect statusRect = CGRectMake(3, 3, 70, 7);
    CGRect percentageRect = CGRectMake(70, 3, 23, 20);
    if ([UIDevice currentDevice].isBatteryMonitoringEnabled == NO) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    [[NSString stringWithFormat:@"%d%%", (NSInteger)([[UIDevice currentDevice] batteryLevel]*100)] drawInRect:percentageRect withFont:font lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentRight];
    NSLog(@"batt:%f", [[UIDevice currentDevice] batteryLevel]);
    
    NSString *statusString;
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged) {
        statusString = @"unplugged";
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging) {
        statusString = @"charging";
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
        statusString = @"full";
    } else if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnknown) {
        statusString = @"unknown";
    }
    [statusString drawInRect:statusRect withFont:font lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
    
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

}

- (void) stopUpdate {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
}

- (void) dealloc {
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
