
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
//  MWMWidget.m
//  MWM
//
//  Created by Siqi Hao on 5/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "MWMWidget.h"

@implementation MWMWidget

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, widgetName, previewRef, delegate;

- (void) update:(NSInteger)timestamp {}
- (void) prepareToUpdate {}
- (void) stopUpdate {}

@end
