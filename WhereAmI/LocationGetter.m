//
//  LocationGetter.m
//  WhereAmI
//
//  Created by Rob Mathers on 12-08-09.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//

#import "LocationGetter.h"
#import <CoreWLAN/CoreWLAN.h>

/*
 * Utils: Add this section before your class implementation
 */

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
 */
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    return [NSURL URLWithString:URLString];
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
    
    IFPrint(@"Latitude: %f", newLocation.coordinate.latitude);
    IFPrint(@"Longitude: %f", newLocation.coordinate.longitude);
    IFPrint(@"Accuracy (m): %f", newLocation.horizontalAccuracy);
    IFPrint(@"Timestamp: %@", [NSDateFormatter localizedStringFromDate:newLocation.timestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle]);
    
    [self sendGeoCodeRequestWithLatitude:newLocation.coordinate.latitude andLongitude:newLocation.coordinate.longitude];
    
    [self.manager stopUpdatingLocation];
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

- (void)sendGeoCodeRequestWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude {
    /* Configure session, choose between:
     * defaultSessionConfiguration
     * ephemeralSessionConfiguration
     * backgroundSessionConfigurationWithIdentifier:
     And set session-wide properties, such as: HTTPAdditionalHeaders,
     HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
     */
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    /* Create session, and optionally set a NSURLSessionDelegate. */
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    /* Create the Request:
     Atlantic (GET https://api.opencagedata.com/geocode/v1/json)
     */
    
    NSString* apiKey = [self openCageApiKey];
    if (!apiKey) {
        self.exitCode = 1;
        self.shouldExit = 1;
        return;
    }
    
    NSURL* URL = [NSURL URLWithString:@"https://api.opencagedata.com/geocode/v1/json"];
    NSDictionary* URLParams = @{
                                @"key": apiKey,
                                @"q": [NSString stringWithFormat:@"%f,%f", latitude, longitude],
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %ld", ((NSHTTPURLResponse*)response).statusCode);
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            self.exitCode = 0;
            self.shouldExit = 1;

        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            self.exitCode = 1;
            self.shouldExit = 1;
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
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

// NSLog replacement from http://stackoverflow.com/a/3487392/1376063
void IFPrint (NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    fputs([[[NSString alloc] initWithFormat:format arguments:args] UTF8String], stdout);
    fputs("\n", stdout);
    
    va_end(args);
}


@end
