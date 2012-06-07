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

@synthesize timeLabel, dateLabel, watchTimer;

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
        
        widgetName = @"Time";
        
        // time label
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 58, 17)];
        timeLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        timeLabel.textAlignment = UITextAlignmentRight;
        timeLabel.font = [UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:23];
        [preview addSubview:timeLabel];
        
        // date label
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 3, 36, 24)];
        dateLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        dateLabel.textAlignment = UITextAlignmentLeft;
        dateLabel.numberOfLines = 3;
        dateLabel.font = [UIFont fontWithName:@"MetaWatch Large caps 8pt" size:8];
        [preview addSubview:dateLabel];
        
        // setting view
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WidgetTimeSettingView" owner:nil options:nil];
        self.settingView = [topLevelObjects objectAtIndex:0];
        self.settingView.alpha = 0;
    }
    return self;
}

- (void) prepareToUpdate {
    [delegate widgetViewCreated:self];
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
    [timeFormat setDateFormat:@"hh:mm"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"a'\n'EEE'\n'MM/dd"];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    timeLabel.text = theTime;
    dateLabel.text = theDate;
    //NSLog(@"tick, %@, %@", theTime , theDate);
}

- (void) dealloc {
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
