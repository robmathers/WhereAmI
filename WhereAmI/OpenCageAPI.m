//
//  OpenCageAPI.m
//  WhereAmI
//
//  Created by Rob Mathers on 2019-09-28.
//  Copyright © 2019 Rob Mathers. All rights reserved.
//

#import "OpenCageAPI.h"

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


@interface OpenCageAPI ()

@property (nonatomic, copy, readonly) NSString* apiKey;

@end

@implementation OpenCageAPI

- (instancetype)initWithApiKey:(NSString *)apiKey {
    if (self = [super init]) {
        _apiKey = apiKey;
    }
    return self;
}


- (void)sendGeoCodeRequestWithLatitude:(double)latitude
                          andLongitude:(double)longitude
                     completionHandler:(void (^)(NSString *_Nullable response, NSError * _Nullable error))completionHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.opencagedata.com/geocode/v1/json"];
    NSDictionary *URLParams = @{
                                @"key": [self apiKey],
                                @"q": [NSString stringWithFormat:@"%f,%f", latitude, longitude],
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            // Success
            
            NSString *responseString = [[NSString alloc] initWithFormat:@"URL Session Task Succeeded: HTTP %ld\n%@",
                                        ((NSHTTPURLResponse *)response).statusCode,
                                        [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            completionHandler(responseString, nil);
        }
        else {
            // Failure
            completionHandler(nil, error);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

@end
