//
//  LocationGetter.h
//  WhereAmI
//
//  Created by Rob Mathers on 12-08-09.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationGetter : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *manager;
@property (nonatomic) BOOL shouldExit;
@property (nonatomic) int exitCode;

-(void)printCurrentLocation;

@end
