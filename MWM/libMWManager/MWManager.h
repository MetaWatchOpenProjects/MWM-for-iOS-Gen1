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
//  AppDelegate.h
//  MWM
//
//  Created by Siqi Hao on 4/18/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Do not modify Below
#define kMSG_TYPE_GET_DEVICE_TYPE 0x01
#define kMSG_TYPE_GET_DEVICE_TYPE_RESPONSE 0x02
#define kMSG_TYPE_GET_INFORMATION_STRING 0x03
#define kMSG_TYPE_GET_INFORMATION_TYPE_RESPONSE 0x04

#define kMSG_TYPE_ADVANCE_WATCH_HANDS 0x20
#define kMSG_TYPE_SET_VIBRATE_MODE 0x23

#define kMSG_TYPE_SET_RTC 0x26
#define kMSG_TYPE_GET_RTC 0x27
#define kMSG_TYPE_GET_RTC_RESPONSE 0x28
#define kMSG_TYPE_WRITE_NVAL 0x30

#define kMSG_TYPE_STATUS_CHANGE_EVENT 0x33
#define kMSG_TYPE_BUTTON_EVENT_MESSAGE 0x34

#define kMSG_TYPE_WRITE_BUFFER 0x40
#define kMSG_TYPE_CONFIGURE_MODE 0x41
#define kMSG_TYPE_CONFIGURE_IDLE_BUFFER_SIZE 0x42
#define kMSG_TYPE_UPDATE_DISPLAY 0x43
#define kMSG_TYPE_LOAD_TEMPLATE 0x44
#define kMSG_TYPE_ENABLE_BUTTON 0x46
#define kMSG_TYPE_DISABLE_BUTTON 0x47
#define kMSG_TYPE_READ_BUTTON_CONFIGURATION 0x48
#define kMSG_TYPE_READ_BUTTON_CONFIGURATION_RESPONSE 0x49

#define kMSG_TYPE_BATTERY_CONFIGURATION_MEASSAGE 0x53
#define kMSG_TYPE_LOW_BATTERY_WARNING_MESSAGE 0x54
#define kMSG_TYPE_LOW_BATTERY_BT_OFF_MESSAGE 0x55
#define kMSG_TYPE_READ_BATTERY_VOLTAGE_MESSAGE 0x56
#define kMSG_TYPE_READ_BATTERY_VOLATRE_RESPONSE 0x57
#define kMSG_TYPE_SET_TIMER 0xB0
#define kMSG_TYPE_SET_TIMER_RESPONSE 0xB1

#define kMODE_IDLE 0x00
#define kMODE_APPLICATION 0x01
#define kMODE_NOTIFICATION 0x02
#define kMODE_SCROLL 0x03

#define kBUTTON_A 0x00
#define kBUTTON_B 0x01
#define kBUTTON_C 0x02
#define kBUTTON_D 0x03
#define kBUTTON_E 0x05
#define kBUTTON_F 0x06

#define kBUTTON_TYPE_IMMEDIATE 0x00
#define kBUTTON_TYPE_PRESS_AND_RELEASE 0x01
#define kBUTTON_TYPE_HOLD_AND_RELEASE 0x02
#define kBUTTON_TYPE_LONG_HOLD_AND_RELEASE 0x03

#define FRAME_HEADER_LEN 4
#define FRAME_CRC_LEN 2
#define FRAME_OVERHEAD FRAME_HEADER_LEN + FRAME_CRC_LEN
#define PIXELS_PER_LINE 96
#define BYTES_PER_LINE PIXELS_PER_LINE / 8

// Macro for disconnect error code:
#define DISCONNECTEDUNKNOWN 201
#define DISCONNECTEDBYUSER 202
#define DISCONNECTEDBY8882 203
#define DISCONNECTEDBYBLEPOWER 204
#define DISCONNECTEDBYBLENOTIF 205
// Do not modify above

#define LINESPERMESSAGE 1

@interface MWManager : NSObject

/*!
 *  @property delegate
 *
 *  @discussion Delegate for MWManagerProtocol.
 *
 */
@property (nonatomic, weak) id delegate;

/*!
 *  @property statusCode
 *
 *  @discussion 0:Disconnected; 1: Connecting; 2: Fully connected;
 *
 */
@property (nonatomic) NSInteger statusCode;

/*!
 *  @property currentAppModeIdentifier
 *
 *  @discussion The identifer of the app which is currently using the application mode.
 *
 */
@property (nonatomic, readonly) NSString *currentAppModeIdentifier;

/*!
 *  @method sharedManager
 *
 *  @discussion Singleton to create/return the instance of MWManager.
 *
 */
+ (MWManager *) sharedManager;

/*!
 *  @method startScan
 *
 *  @discussion Ask the MWManager to scan and connect to Meta Watch,
 *  call stopScan to cancel. This method will never timeout.
 *
 */
- (void) startScan;

/*!
 *  @method stopScan
 *
 *  @discussion Ask the MWManager to stop scan. This method 
 *  will also disconnect the watch when the watch connection 
 *  has not been fully established, but will not disconnect 
 *  a fully connected watch.
 *
 */
- (void) stopScan;

/*!
 *  @method disconnect:
 *
 *  @param errorCode Reason of disconnect
 *  @discussion Disconnect a fully connected watch. Give DISCONNECTEDBYUSER if user disconnects it.
 *
 */
- (void) disconnect:(NSInteger)errorCode;

/*!
 *  @method setWatchUse12H:
 *
 *  @discussion Set the watch to use 12h.
 *
 */
- (void) setWatchUse12H:(BOOL)use12H;

/*!
 *  @method setWatchShowSec:
 *
 *  @discussion Set the watch show seconds
 *
 */
- (void) setWatchShowSec:(BOOL)showSec;

/*!
 *  @method setWatchShowMonthFirst:
 *
 *  @discussion Set the watch show month first
 *
 */
- (void) setWatchShowMonthFirst:(BOOL)monthFirst;

/*!
 *  @method setWatchRTC
 *
 *  @discussion Set the real time clock of the watch. Invoked automatically when watch connected.
 *
 */
- (void) setWatchRTC;

/*!
 *  @method writeImage:forMode:inRect:linesPerMessage:shouldLoadTemplate:buzzWhenDone:buzzRepeats:
 *  @param imgData Bitmap data for image, use imageDataForCGImage to create.
 *  @param mode The mode of the image should be displayed at.
 *  @param rect The y cordinate will be used to determine the start line of the data. Other properties not used yet.
 *  @param lpm Amount of lines of pixel to be written.
 *  @param loadTemplate Whether the watch should clean the buffer before wirting. Useful for popping a notifiction.
 *  @param buzz Whether should virbrate when watch when finished. Useful for popping a notifiction.
 *
 *  @discussion Upload image data to watch and display it.
 *
 */
- (void) writeImage:(NSData*)imgData forMode:(unsigned char)mode inRect:(CGRect)rect linesPerMessage:(unsigned char)lpm shouldLoadTemplate:(BOOL)loadTemplate buzzWhenDone:(BOOL)buzz buzzRepeats:(unsigned char)repeats;
/*!
 *  @method loadTemplate:
 *  @param mode Template will be loaded into selected mode’s display buffer.
 *  @param rect Indicate the starting row and number of rows to be updated.
 *
 *  @discussion Copy a template stored in flash memory into the display buffer. 
 *  The clear and fill functions work, but otherwise this message is not implemented.
 *
 */
- (void) loadTemplate:(unsigned char)mode;

/*!
 *  @method updateDisplay:
 *  @param mode The selected buffer will become active.
 *
 *  @discussion This message is used to draw a new screen to the display.
 *
 */
- (void) updateDisplay:(unsigned char)mode;

/*!
 *  @method updateDisplay:inRect:
 *  @param mode The selected buffer will become active.
 *  @param rect Indicate the starting row and number of rows to be updated.
 *
 *  @discussion This message is used to draw a new screen to the display.
 *
 */
- (void) updateDisplay:(unsigned char)mode inRect:(CGRect)rect;

/*!
 *  @method drawIdleLines:
 *
 *  @discussion Draw dash lines between widgets
 *
 */
- (void) drawIdleLines:(BOOL)draw;

/*!
 *  @method getDeviceType
 *
 *  @discussion Not in use
 *
 */
- (void) getDeviceType;

/*!
 *  @method getDeviceInfoString
 *
 *  @discussion Not in use
 *
 */
- (void) getDeviceInfoString;

/*!
 *  @method setBuzz
 *
 *  @discussion Virbrate the watch.
 *
 */
-(void) setBuzzWithRepeats:(NSUInteger)repeats;

/*!
 *  @method setTimerWith:andID:andCounts::
 *
 *  @discussion Set update internal interval of the watch.
 *
 */
- (void) setTimerWith:(NSUInteger)interval andID:(NSUInteger)idInteger andCounts:(NSUInteger)counts;

/*!
 *  @method removeTimer:
 *
 *  @discussion Not in use.
 *
 */
- (void) removeTimer:(NSUInteger)idInteger;

/*!
 *  @method setButton:atMode:forType:withCallbackMsg:
 *
 *  @discussion Not in use.
 *
 */
- (void) setButton:(unsigned char)btnIndex atMode:(unsigned char)mode forType:(unsigned char)type withCallbackMsg:(unsigned char)msg;

/*!
 *  @method setMWMWriteWithResponse:
 *
 *  @discussion Toggle whether the MWM should send BLE commands using with repsonse or without response. With Response" is signficantly faster but may be unreliable.
 *
 */
- (void) setMWMWriteWithResponse:(BOOL)withRes;

- (BOOL) isAppModeAvailable;
- (BOOL) gainAccessToAppModeFromApp:(NSString*)appIdentifier;
- (BOOL) releaseAccessToAppModeFromApp:(NSString*)appIdentifier;

@end

/*!
 *  @protocol MWManagerProtocol:
 *
 *  @discussion Delegate for MWManager
 *
 */
@protocol MWManagerProtocol <NSObject>

/*!
 *  @method MWMDidDiscoveredWritePort
 *
 *  @discussion Invoked when the watch is fully connected and ready to be used.
 *
 */
- (void) MWMDidDiscoveredWritePort;

/*!
 *  @method MWM:didDisconnectPeripheral:withError:
 *
 *  @param err Error code above, domain is "MWM"
 *  @discussion Invoked when the watch disconnected.
 *
 */
- (void) MWM:(MWManager*)mwm didDisconnectPeripheral:(CBPeripheral *)peripheral withError:(NSError*)err;

@optional

/*!
 *  @method MWM:didConnectPeripheral:
 *
 *  @discussion Invoked when the watch is connected but more handshakes 
 *  still undergoing. MWMDidDiscoveredWritePort will be invoked when watch 
 *  is fully connected
 *
 */
- (void) MWM:(MWManager*)mwm didConnectPeripheral:(CBPeripheral *)peripheral;

/*!
 *  @method MWMCheckEvent:
 *
 *  @discussion Do updates needed.
 *
 */
- (void) MWMCheckEvent:(NSTimeInterval)timestamp;

/*!
 *  @method MWMBtn:atMode:pressedForType:withMsg:
 *
 *  @discussion Not in use.
 *
 */
- (void) MWMBtn:(unsigned char)btnIndex atMode:(unsigned char)mode pressedForType:(unsigned char)type withMsg:(unsigned char)msg;

@end