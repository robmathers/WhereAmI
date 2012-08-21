//
//  LocationGetter.m
//  WhereAmI
//
//  Created by Rob Mathers on 12-08-09.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//

#import "LocationGetter.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation LocationGetter

-(id)init {
    self = [super init];
    self.manager = [CLLocationManager new];
    self.manager.delegate = self;
    self.shouldExit = NO;
    self.exitCode = 1;
    
    return self;
}

-(void)printCurrentLocation {
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    self.manager.distanceFilter = kCLDistanceFilterNone;
    
    if (![CLLocationManager locationServicesEnabled]) {
        IFPrint(@"Location services are not enabled, quitting.");
        self.exitCode = 1;
        self.shouldExit = 1;
        return;
    }
    else if (
             ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) ||
             ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)) {
        IFPrint(@"Location services are not authorized, quitting.");
        self.exitCode = 1;
        self.shouldExit = 1;
        return;
    }
    else {
        [self.manager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval ageInSeconds = -[newLocation.timestamp timeIntervalSinceNow];
    if (ageInSeconds > 60.0) return;   // Ignore data more than a minute old
    
    IFPrint(@"Latitude: %f", newLocation.coordinate.latitude);
    IFPrint(@"Longitude: %f", newLocation.coordinate.longitude);
    IFPrint(@"Accuracy (m): %f", newLocation.horizontalAccuracy);
    IFPrint(@"Timestamp: %@", [NSDateFormatter localizedStringFromDate:newLocation.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle]);
    
    [self.manager stopUpdatingLocation];
    self.exitCode = 0;
    self.shouldExit = 1;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.manager stopUpdatingLocation];
    if ([error code] == kCLErrorLocationUnknown) {
        IFPrint(@"Location could not be determined right now. Try again later. Check if Wi-Fi is enabled.");
    }
    else if ([error code] == kCLErrorDenied) {
        IFPrint(@"Access to location services was denied. You may need to enable access in System Preferences.");
    }
    else {
        IFPrint(@"Error getting location data. %@", error);
    }
       
    self.exitCode = 1;
    self.shouldExit = 1;
}

// NSLog replacement from http://stackoverflow.com/a/3487392/1376063
void IFPrint (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    fputs([[[NSString alloc] initWithFormat:format arguments:args] UTF8String], stdout);
    fputs("\n", stdout);
    
    va_end(args);
}


@end
