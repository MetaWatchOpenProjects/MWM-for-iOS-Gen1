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
//  MWMWidget.h
//  MWM
//
//  Created by Siqi Hao on 5/24/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWMWidgetDelegate.h"

@interface MWMWidget : NSObject

// MetaWatch Widget Interface

/*!
 *  @property preview
 *
 *  @discussion The UIView used to render the preview of thw watch face on the iPhone.
 *  The origin of the UIView will be overwritten by MWM according to your layout.
 *
 */
@property (nonatomic, strong) UIView *preview;

/*!
 *  @property updateIntvl
 *
 *  @discussion If you widget needs updating at a fixed interval to pull the data, you
 *  should set this property in seconds. Current the minimum update frequency is 60 seconds,
 *  if you need a much higher update frequency, like 1 seconds, you should consider using the
 *  App mode of the MetaWatch. Set this property to -1 if you do not need any updates.
 *
 */
@property (nonatomic) NSInteger updateIntvl;

/*!
 *  @property updatedTimestamp
 *
 *  @discussion The previous updated timestamp.
 *
 */
@property (nonatomic) NSInteger updatedTimestamp;

/*!
 *  @property settingView
 *
 *  @discussion The setting view for the widget, the size should be exact (254, 148). If you 
 *  need have much more settings, you can use a UIScrollView or present a ModelViewController
 *  within the setting view.
 *
 */
@property (nonatomic, strong) UIView *settingView;

/*!
 *  @property widgetSize
 *
 *  @discussion Calculated from widgetWidth and widgetHeight from the implementation file.
 *
 */
@property (nonatomic, readonly) CGSize widgetSize;

/*!
 *  @property widgetID
 *
 *  @discussion You should have a unique widgetID. Any presistence settings are stored based on this.
 *
 */
@property (nonatomic, readonly) NSInteger widgetID;

/*!
 *  @property widgetName
 *
 *  @discussion Name of your widget, should be unique also(at least at this moment...).
 *
 */
@property (nonatomic, readonly) NSString *widgetName;

/*!
 *  @property previewRef
 *
 *  @discussion The data will be sent to the Meta Watch. widget:updatedWithError: called, if the error
 *  is nil, the MWM will send data of previewRef to the watch.
 *
 */
@property (nonatomic) CGImageRef previewRef;

/*!
 *  @property delegate
 *
 *  @discussion MWMWidgetDelegate
 *
 */
@property (nonatomic, weak) id delegate;

/*!
 *  @method prepareToUpdate
 *
 *  @discussion Do work needed to update the widget.
 *
 */
- (void) prepareToUpdate;

/*!
 *  @method update:
 *
 *  @discussion Set timestamp to -1, to start a manual update, otherwise no need to call this method.
 *
 */
- (void) update:(NSInteger)timestamp;

/*!
 *  @method stopUpdate:
 *
 *  @discussion Do worked needed to remove the widget. This method normally will also be called in dealloc.
 *
 */
- (void) stopUpdate;

@end
