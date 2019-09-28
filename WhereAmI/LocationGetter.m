//
//  LocationGetter.m
//  WhereAmI
//
//  Created by Rob Mathers on 12-08-09.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//

#import "LocationGetter.h"
#import "OpenCageAPI.h"
#import <CoreWLAN/CoreWLAN.h>

// NSLog replacement from http://stackoverflow.com/a/3487392/1376063
void IFPrint (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    fputs([[[NSString alloc] initWithFormat:format arguments:args] UTF8String], stdout);
    fputs("\n", stdout);
    
    va_end(args);
}

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
    [self.manager stopUpdatingLocation];

    IFPrint(@"Latitude: %f", newLocation.coordinate.latitude);
    IFPrint(@"Longitude: %f", newLocation.coordinate.longitude);
    IFPrint(@"Accuracy (m): %f", newLocation.horizontalAccuracy);
    IFPrint(@"Timestamp: %@", [NSDateFormatter localizedStringFromDate:newLocation.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle]);
    
    if ([self hasApiKeyFlag]) {
        NSString* apiKey = [self openCageApiKey];
        if (!apiKey) {
            IFPrint(@"API key not found.");
            self.exitCode = 1;
            self.shouldExit = 1;
            return;
        }
        
        OpenCageAPI *api = [[OpenCageAPI alloc] initWithApiKey:apiKey];
        
        [api sendGeoCodeRequestWithLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude completionHandler:^(NSString * _Nullable response, NSError * _Nullable error) {
            if (response) {
                IFPrint(response);
                self.exitCode = 0;
                self.shouldExit = 1;
            }
            else {
                IFPrint(error.localizedDescription);
                self.exitCode = 1;
                self.shouldExit = 1;
            }
        }];
    }
    else {
        self.exitCode = 0;
        self.shouldExit = 1;
    }
}

-(BOOL)isWifiEnabled {
    CWInterface *wifi = [CWInterface interface];
    return wifi.powerOn;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.manager stopUpdatingLocation];
    if ([error code] == kCLErrorLocationUnknown) {
        if (![self isWifiEnabled])
            IFPrint(@"Wi-Fi is not enabled. Please enable it to gather location data");
        else
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

- (BOOL)hasApiKeyFlag {
    NSArray<NSString *>* arguments = NSProcessInfo.processInfo.arguments;
    NSUInteger apiKeyFlagIndex = [arguments indexOfObject: @"-k"];
    return apiKeyFlagIndex != NSNotFound;
}

- (nullable NSString *)openCageApiKey {
    NSArray<NSString *>* arguments = NSProcessInfo.processInfo.arguments;
    
    NSUInteger apiKeyFlagIndex = [arguments indexOfObject: @"-k"];
    if (arguments.count > apiKeyFlagIndex + 1) {
        NSString* apiKey = arguments[apiKeyFlagIndex + 1];
        if (apiKey.length > 0) {
            return apiKey;
        }
    }
    return nil;
}

@end
