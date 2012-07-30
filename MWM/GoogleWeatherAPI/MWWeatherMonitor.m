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
@synthesize weatherDict, city, connData, delegate, conn, locationManager;

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
    if (city.length == 0) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        locationManager.delegate = self;
        [locationManager startMonitoringSignificantLocationChanges];
    } else {
        [locationManager stopMonitoringSignificantLocationChanges];
        self.locationManager = nil;
        
        NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@%@&hl=us", kKAWeatherBaseURL, [self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NSLog(@"%@", url);
        if (url) {
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
            conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
        } else {
            [delegate weatherFailedToResolveCity:city];
        }
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Location: %@", [newLocation description]);
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count > 0) {
            NSString *locationString = [NSString stringWithFormat:@"%@,%@", [[placemarks objectAtIndex:0] locality], [[placemarks objectAtIndex:0] country]];
            NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@%@&hl=us", kKAWeatherBaseURL, [locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            NSLog(@"Geo:%@", url);
            if (url) {
                NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
                conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
                UILocalNotification *notif =[[UILocalNotification alloc] init];
                notif.alertBody = [NSString stringWithFormat:@"location changed:%@", locationString];
                [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
            } else {
                [delegate weatherFailedToResolveCity:locationString];
            }
        } else {
            [delegate weatherFailedToResolveCity:self.city];
        }
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [delegate weatherFailedToResolveCity:self.city];
}

- (void) dealloc {
    [locationManager stopMonitoringSignificantLocationChanges];
    self.locationManager = nil;
    self.city = nil;
    self.weatherDict = nil;
    self.connData = nil;
    [self.conn cancel];
    self.conn = nil;
    [super dealloc];
}

@end
