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
//  AppDelegate.m
//  MWM
//
//  Created by Siqi Hao on 4/18/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

#import "MWManager.h"
#import "MWMNotificationsManager.h"

@interface AppDelegate ()
@property (nonatomic, strong) MWManager *mgr;
@property (nonatomic, strong) MWMNotificationsManager *notifMgr;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

@synthesize allWidgets, mgr, notifMgr;

- (void) preparePresets {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs objectForKey:@"watchLayout"] == nil) {
        NSDictionary *layoutDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"WidgetTime", @"03", 
                                    @"WidgetWeather", @"13", 
                                    @"WidgetCalendar", @"23", 
                                    nil];
        [prefs setObject:layoutDict forKey:@"watchLayout"];
    }
    if ([prefs objectForKey:@"autoConnect"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"autoConnect"];
    }
    if ([prefs objectForKey:@"autoReconnect"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"autoReconnect"];
    }
    if ([prefs objectForKey:@"buzzOnConnect"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"buzzOnConnect"];
    }
    if ([prefs objectForKey:@"rememberOnConnect"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"rememberOnConnect"];
    }
    if ([prefs objectForKey:@"drawDashLines"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"drawDashLines"];
    }
    if ([prefs objectForKey:@"notifCalendar"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"notifCalendar"];
    }
    if ([prefs objectForKey:@"notifTimezone"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"notifTimezone"];
    }
    if ([prefs objectForKey:@"notifWakeUpAlarm"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"notifWakeUpAlarm"];
    }
    if ([prefs objectForKey:@"writeWithResponse"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"writeWithResponse"];
    }
    if ([prefs objectForKey:@"appIndetifier"] == nil) {
        [prefs setObject:@"" forKey:@"appIndetifier"];
    }
    
    [prefs synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self preparePresets];
    
    MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];

    self.mgr = [MWManager sharedManager];
    self.notifMgr = [MWMNotificationsManager sharedManager];
    [MWManager sharedManager].delegate = masterViewController;
    
    allWidgets = [NSMutableArray arrayWithObjects:@"WidgetTime", @"WidgetWeather", @"WidgetCalendar", @"WidgetPhoneStatus", nil];
    
    // Customize navigationbar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forBarMetrics:UIBarMetricsDefault];
    UIFont *font = [UIFont fontWithName:@"Arial" size:20];
    NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                          font, UITextAttributeFont, 
                          [UIColor colorWithRed:0/255.0 green:116/255.0 blue:213/255.0 alpha:1.0], UITextAttributeTextColor,
                          nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attr];
    
    self.navigationController.navigationBar.clipsToBounds = NO;
    
    self.navigationController.navigationBar.layer.cornerRadius = 0; // if you like rounded corners
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationController.navigationBar.layer.shadowRadius = 4;
    self.navigationController.navigationBar.layer.shadowOpacity = 1.0;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:0/255.0 green:116/255.0 blue:213/255.0 alpha:1.0]];
    
    // Normal startup
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    //NSLog(@"%@", [[UIFont familyNames] description]);
    
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    NSLog(@"%@", url);
    
    
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[url scheme] isEqualToString:@"mwm"]) {
        [[MWManager sharedManager] handle:url from:sourceApplication];
        return YES;
    } else {
        return NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
