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

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

@synthesize allWidgets;

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
    if ([prefs objectForKey:@"writeWithResponse"] == nil) {
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"writeWithResponse"];
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
    NSLog(@"%@", url);
    return YES;
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

#pragma mark - BitMap Helpers
+(CGImageRef)scaleCGImage: (CGImageRef) image withScale: (float) scale
{
    // Create the bitmap context
    CGContextRef context = NULL;
    void * bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    int width = CGImageGetWidth(image) * scale;
    int height = CGImageGetHeight(image) * scale;
    NSLog(@"Before Scale:%zu,%zu", CGImageGetWidth(image), CGImageGetHeight(image));
    
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
    
    NSLog(@"Raw Image Size After Scale:%d, %d", width, height);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    
    return imgRef;
}

+(CGContextRef) CreateContext :(CGImageRef) inImage {
    //NSLog(@"CreateContextFromImgRef");
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    size_t pixelsWide;
    size_t pixelsHigh;
    
    if (inImage == NULL) {
        pixelsWide = 96;
        pixelsHigh = 96;
    }else {
        pixelsWide = CGImageGetWidth(inImage);
        pixelsHigh = CGImageGetHeight(inImage);
    }
    
    // Get image width, height. We'll use the entire image.
    
    //NSLog(@"Appdelegate CreateContext: size: %zu:%zu",pixelsHigh,pixelsWide);
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 1);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceGray();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL) 
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits 
    // per component. Regardless of what the source image format is 
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaNone);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

+(NSData*) imageDataForCGImage:(CGImageRef)inImage
{
    
    // Create the bitmap context
    CGContextRef cgctx = [AppDelegate CreateContext:inImage];
    if (cgctx == NULL) 
    { 
        // error creating context
        return nil;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}}; 
    
    // Draw the image to the bitmap context. Once we draw, the memory 
    // allocated for the context for rendering will then contain the 
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage); 
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    char *data = CGBitmapContextGetData (cgctx);
    
    NSData* imgData = [NSData dataWithBytes:data length:w*h];
    
    CGImageRef imgRef = CGBitmapContextCreateImage(cgctx);
    //UIImage* img = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    
    if (data)
    {
        free(data);
    }
    
    return imgData;
}

+(UIImage *)imageForText:(NSString *)text {
    // set the font type and size
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8]; 
    CGSize textSize  =  [text sizeWithFont:font constrainedToSize:CGSizeMake(93, 93) lineBreakMode:UILineBreakModeWordWrap]; //[text sizeWithFont:font forWidth:90 lineBreakMode:UILineBreakModeWordWrap];
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(96, textSize.height),NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor]CGColor]);
    CGContextFillRect(ctx, CGRectMake(0, 0, 96, textSize.height));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    [text drawInRect:CGRectMake(0, 0, 96, textSize.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSLog(@"height%f, %f", image.size.height, textSize.height);
    UIGraphicsEndImageContext();    
    
    return image;
}


@end
