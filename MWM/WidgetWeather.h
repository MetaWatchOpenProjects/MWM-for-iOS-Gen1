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
//  WidgetWeather.h
//  MWM
//
//  Created by Siqi Hao on 4/20/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWMWidgetDelegate.h"
#import "MWWeatherMonitor.h"

@interface WidgetWeather : NSObject <UITextFieldDelegate, UIActionSheetDelegate, MWWeatherMonitorDelegate>

// MetaWatch Widget Interface
@property (nonatomic, strong) UIView *preview;
@property (nonatomic) NSInteger updateIntvl;
@property (nonatomic) NSInteger updatedTimestamp;
@property (nonatomic, strong) UIView *settingView;
@property (nonatomic, readonly) CGSize widgetSize;
@property (nonatomic, readonly) NSInteger widgetID;
@property (nonatomic, readonly) NSString *widgetName;
@property (nonatomic) CGImageRef previewRef;
@property (nonatomic, weak) id delegate;

+ (CGSize) getWidgetSize;

- (void) update:(NSInteger)timestamp;
- (void) prepareToUpdate;
- (void) stopUpdate;

// Weather Widget Specific
@property (nonatomic) BOOL received;
@property (nonatomic) BOOL geoLocationEnabled;
@property (nonatomic, strong) NSDate *updatedTime;
@property (nonatomic) BOOL useCelsius;
@property (nonatomic, strong) NSString *currentCityName;
@property (nonatomic) NSInteger weatherUpdateIntervalInMins;
@property (nonatomic, strong) NSDictionary *weatherDict;



- (void) toggleValueChanged:(id)sender;
- (void) updateBtnPressed:(id)sender;

@end

