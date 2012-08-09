//
//  main.m
//  WhereAmI
//
//  Created by Rob Mathers on 12-08-09.
//  Copyright (c) 2012 Rob Mathers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationGetter.h"

int main(int argc, const char * argv[])
{

    NSRunLoop *runLoop;
    LocationGetter *main; // replace with desired class

    // create run loop
    runLoop = [NSRunLoop currentRunLoop];
    main    = [[LocationGetter alloc] init]; // replace with init method
    
    // kick off object, if required
    [main printCurrentLocation];
    
    // enter run loop
    while((!(main.shouldExit)) && (([runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]])));
    
return(main.exitCode);
}

