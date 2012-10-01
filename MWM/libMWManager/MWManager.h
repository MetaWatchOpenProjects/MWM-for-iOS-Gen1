//
//  MWManager.h
//  MWM
//
//  Created by Siqi Hao on 4/18/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

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

#define kMSG_TYPE_GENERAL_PHONE_MESSAGE 0x35
#define kMSG_TYPE_GENERAL_WATCH_MESSAGE 0x36

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
#define kMSG_TYPE_CALLER_ID 0xB3
#define kMSG_TYPE_RING_PHONE 0xB4
#define kMSG_TYPE_MESSAGE_ACCESS_PROFILE 0xB8

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
#define FRAME_OVERHEAD (FRAME_HEADER_LEN + FRAME_CRC_LEN)
#define PIXELS_PER_LINE 96
#define BYTES_PER_LINE PIXELS_PER_LINE / 8

// Macro for disconnect error code:
#define DISCONNECTEDUNKNOWN 201
#define DISCONNECTEDBYUSER 202
#define DISCONNECTEDBY8882 203
#define DISCONNECTEDBYBLEPOWER 204
#define DISCONNECTEDBYBLENOTIF 205
#define DISCONNECTEDBY8880 206
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
 *  @discussion 0:Disconnected; 1: Connecting; 2: Fully connected; 3: Disconnecting
 *
 */
@property (nonatomic, readonly) NSInteger statusCode;

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
 *  @param imgData Bitmap data for image, use bitmapDataForCGImage to create.
 *  @param mode The mode of the image should be displayed at.
 *  @param rect The y cordinate will be used to determine the start line of the data. Other properties not used yet.
 *  @param lpm Amount of lines of pixel to be written.
 *  @param loadTemplate Whether the watch should clean the buffer before wirting. Useful for popping a notifiction.
 *  @param buzz Whether should virbrate when watch when finished. Useful for popping a notifiction.
 *
 *  @discussion Upload image data to watch and display it.
 *
 */
- (void) writeImage:(NSData*)imgData forMode:(unsigned char)mode inRect:(CGRect)rect linesPerMessage:(unsigned char)lpm shouldLoadTemplate:(BOOL)loadTemplate shouldUpdate:(BOOL)update buzzWhenDone:(BOOL)buzz buzzRepeats:(unsigned char)repeats;

- (void) loadTemplate:(unsigned char)mode withTemplate:(unsigned char)templ;

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
 *  @discussion This message is used to draw a new screen to the display for certain rows.
 *
 */
- (void) updateDisplay:(unsigned char)mode inRect:(CGRect)rect;

/*!
 *  @method setWatchIdleFullScreen:
 *
 *  @discussion This command is used to determine who draws the top 1/3 of the watch idel screen.
 *
 */
- (void) setWatchIdleFullScreen:(BOOL)enabled;

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
 *  @method getDeviceInfogString
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
 *  @discussion Toggle whether the MWM should send BLE commands using with
 *  repsonse or without response. With Response" is signficantly faster but may be unreliable.
 *
 */
- (void) setMWMWriteWithResponse:(BOOL)withRes;

/*!
 *  @method handle:from:
 *
 *  @discussion Only invoke this method in application:openURL:sourceApplication:annotation:,
 *  URL should have scheme "mwm://". When another iOS app sends a request to the App Mode of
 *  the Meta Watch through URL Scheme, this method will handle this request. That iOS app will
 *  be notified if the request is succeeded through "mwmapp://" URL Scheme
 *
 */
- (void) handle:(NSURL*)url from:(NSString*)appIdentifier;

/*!
 *  @method isAppModeAvailable
 *
 *  @discussion This method return YES if the App Mode of the Meta Watch is free to be used.
 *  No if any app is using the App Mode.
 *
 */
- (BOOL) isAppModeAvailable;

/*!
 *  @method releaseAccessToAppModeFromApp:
 *  @param appIdentifier The application bundle identifier of the app which should be released:
 *  currentAppModeIdentifier in most cases.
 *
 *  @discussion This method manually withdraw the access to the App Mode of the Meta Watch from
 *  the sepcified application. The sepcified app will be notified through URL scheme.
 *
 */
- (BOOL) forceReleaseAccessToAppModeFromApp:(NSString*)appIdentifier;

/*!
 *  @method imageForText:
 *  @param text The text needs to be rendered.
 *
 *  @discussion Create an image with a width of 96px and a dynamic height according to the length of the text.
 *
 */
+ (UIImage *)imageForText:(NSString *)text;

/*!
 *  @method bitmapDataForCGImage:
 *  @param The image needs to be drawn at the watch screen.
 *
 *  @discussion Return the bitmap data to send to the watch, pass to writeImage:forMode:inRect:linesPerMessage:
 *  shouldLoadTemplate:buzzWhenDone:buzzRepeats: to send to the watch.
 *
 */
+ (NSData*) bitmapDataForCGImage:(CGImageRef)inImage;

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
 *  @discussion Do updates needed. e.g Progressive updates to inform the user status of connecting.
 *
 */
- (void) MWMCheckEvent:(NSTimeInterval)timestamp;

/*!
 *  @method MWMBtn:atMode:pressedForType:withMsg:
 *
 *  @discussion Invoked when any button is pressed when the watch is in Application mode, Notification mode and Scroll Mode.
 *
 */
- (void) MWMBtn:(unsigned char)btnIndex atMode:(unsigned char)mode pressedForType:(unsigned char)type withMsg:(unsigned char)msg;

/*!
 *  @method MWMGrantedLocalAppMode
 *
 *  @discussion Callback for internal MWMApp received the access to App mode.
 *
 */
- (void) MWMGrantedLocalAppMode;

/*!
 *  @method MWMReleasedLocalAppMode
 *
 *  @discussion Callback for internal MWMApp lost the access to App mode.
 *
 */
- (void) MWMReleasedLocalAppMode;

@end