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
//  KAWeatherMonitor.h
//  MWManager
//
//  Created by Kai Aras on 9/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kKAWeatherBaseURL @"http://www.google.com/ig/api\?weather="

@interface MWWeatherMonitor : NSObject<NSXMLParserDelegate>


+(MWWeatherMonitor *) sharedMonitor;

-(NSDictionary*)currentWeather;

@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSMutableDictionary *weatherDict;

@end
