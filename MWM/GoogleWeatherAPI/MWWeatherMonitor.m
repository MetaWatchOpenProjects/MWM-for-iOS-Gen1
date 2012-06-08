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
@synthesize weatherDict,city;

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
    }
    
    return self;
}

// Use cordinates
//http://www.google.com/ig/api?weather=,,,60167000,24955000 *1000000
-(NSDictionary*)currentWeather {
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kKAWeatherBaseURL, [self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    if (url == nil) {
        NSLog(@"invalid url");
        return nil;
    }
    
    NSError* error = nil;
    NSData* d = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    
    if (d == nil) {
        NSLog(@"no weather data");
        return nil;
    }
    
    NSString *dataString = [[NSString alloc]initWithData:d encoding:NSISOLatin1StringEncoding];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [dataString release];
    
    
    if (error) {
        NSLog(@"no weather data");
        return nil;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
    [parser setShouldProcessNamespaces:YES];
    [parser setShouldResolveExternalEntities:YES];
    [parser setShouldReportNamespacePrefixes:YES];
    [parser setDelegate:self];
    [parser parse];
      
    [parser release];
    
    NSInteger lowInF = [[weatherDict valueForKey:@"low"] integerValue];
    [weatherDict setValue:[NSString stringWithFormat:@"%d", ((lowInF - 32) *5/9)] forKey:@"low_c"];
    NSInteger highInF = [[weatherDict valueForKey:@"high"] integerValue];
    [weatherDict setValue:[NSString stringWithFormat:@"%d", ((highInF - 32) *5/9)] forKey:@"high_c"];
    
    //NSLog(@"weather: %@", self.weatherDict);
    return weatherDict;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //  NSLog(@"element: %@ %@",elementName, attributeDict);
     id obj = [attributeDict objectForKey:@"data"];
    if (obj) {
        [self.weatherDict setObject:obj forKey:elementName];
    }
    
}


@end
