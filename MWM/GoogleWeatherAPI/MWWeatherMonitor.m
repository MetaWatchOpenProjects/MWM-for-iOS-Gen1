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
//  KAWeatherMonitor.m
//  MWManager
//
//  Created by Kai Aras on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MWWeatherMonitor.h"

@implementation MWWeatherMonitor
@synthesize weatherDict, city, connData, delegate, conn;
@synthesize locationManager;
@synthesize locationMeasurements;
static MWWeatherMonitor *sharedMonitor;

#pragma mark - Singleton

+(MWWeatherMonitor *) sharedMonitor {
    if (sharedMonitor == nil) {
        sharedMonitor = [[super allocWithZone:NULL]init];
    }
    return sharedMonitor;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.weatherDict = [NSMutableDictionary dictionary];
        self.city=@"Helsinki";
        self.connData = [NSMutableData data];
    }
    
    return self;
}

- (void) getWeather {
    // Create the manager object
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    locationManager.desiredAccuracy = 1.0;
    // Once configured, the location manager must be "started".
    [locationManager startUpdatingLocation];
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    CLLocation *location = [[[CLLocation alloc] initWithLatitude:locationManager.location.coordinate.latitude 
                                                       longitude:locationManager.location.coordinate.longitude] autorelease];
    __block NSString *postalCode = @"";
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            //return;
        }
        NSLog(@"Received placemarks: %@", placemark.postalCode);
        postalCode = placemark.postalCode;
        self.city = placemark.postalCode;
        NSLog(@"Accuracy: %f", locationManager.location.coordinate.longitude);
        //NSString* locationString = [NSString stringWithFormat:@"%@", "Okemos"];
        NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@%@&hl=us", kKAWeatherBaseURL, [postalCode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSString *urlString = [url absoluteString];
        NSLog(@"Accuracy: %@", urlString);
        if (url) {
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
            conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        } else {
            [delegate weatherFailedToResolveCity:city];
        }
    }];
    
}

/*
 * We want to get and store a location measurement that meets the desired accuracy. For this example, we are
 *      going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical
 *      accuracy, or both together.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // test that the horizontal accuracy does not indicate an invalid measurement
    NSLog(@"I am here");
    if (newLocation.horizontalAccuracy < 0) return;
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // store all of the measurements, just so we can see what kind of data we might receive
    [locationMeasurements addObject:newLocation];
    // update the display with the new location data
    [self getWeather];
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@%@&hl=us", kKAWeatherBaseURL, [self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSLog(@"%@", url);
    if (url) {
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
        conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    } else {
        [delegate weatherFailedToResolveCity:city];
    }    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.connData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.connData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [weatherDict removeAllObjects];
    
    if (connData == nil) {
        [delegate weatherFailedToUpdate];
        return;
    }
    
    NSString *stringReply = [[NSString alloc] initWithData:connData encoding:NSISOLatin1StringEncoding];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[stringReply dataUsingEncoding:NSUTF8StringEncoding]];
    [parser setShouldProcessNamespaces:YES];
    [parser setShouldResolveExternalEntities:YES];
    [parser setShouldReportNamespacePrefixes:YES];
    [parser setDelegate:self];
    [parser parse];
    
    [stringReply release];
    [parser release];
    if ([weatherDict valueForKey:@"city"]) {
        NSInteger lowInF = [[weatherDict valueForKey:@"low"] integerValue];
        [weatherDict setValue:[NSString stringWithFormat:@"%d", ((lowInF - 32) *5/9)] forKey:@"low_c"];
        NSInteger highInF = [[weatherDict valueForKey:@"high"] integerValue];
        [weatherDict setValue:[NSString stringWithFormat:@"%d", ((highInF - 32) *5/9)] forKey:@"high_c"];
        
        [delegate weatherUpdated:weatherDict];
    } else {
        [delegate weatherFailedToResolveCity:city];
    }
    self.conn = nil;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate weatherFailedToUpdate];
    self.conn = nil;
}

// Use cordinates
//http://www.google.com/ig/api?weather=,,,60167000,24955000 *1000000

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"element: %@ %@",elementName, attributeDict);
    if ([weatherDict objectForKey:elementName] == nil) {
        id obj = [attributeDict objectForKey:@"data"];
        if (obj) {
            [self.weatherDict setObject:obj forKey:elementName];
        }
    }
}

- (void) dealloc {
    self.city = nil;
    self.weatherDict = nil;
    self.connData = nil;
    [self.conn cancel];
    self.conn = nil;
    [super dealloc];
    [locationManager stopUpdatingLocation];
}

@end
