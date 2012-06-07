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
//  MasterViewController.h
//  MWM
//
//  Created by Siqi Hao on 4/18/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "MWManager.h"
#import "MWMNotificationsManager.h"
#import "DragImageView.h"

#import "MWMWidgetDelegate.h"

#import "WidgetsSelectionDelegate.h"
#import "MWMWidget.h"

#define TIMERVALUE 60

@interface MasterViewController : UIViewController <UIScrollViewDelegate, DragSliderViewDelegate, MWManagerProtocol, MWMWidgetDelegate, WidgetsSelectionDelegate>

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) IBOutlet UIImageView *watchDisplay;
@property (nonatomic, strong) IBOutlet DragImageView *barIndicatorView;

@property (nonatomic, strong) IBOutlet UIView* widgetSettingView;

@end
