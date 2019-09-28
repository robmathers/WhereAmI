//
//  OpenCageAPI.h
//  WhereAmI
//
//  Created by Rob Mathers on 2019-09-28.
//  Copyright © 2019 Rob Mathers. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCageAPI : NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey;

- (void)sendGeoCodeRequestWithLatitude:(double)latitude
                          andLongitude:(double)longitude 
                     completionHandler:(void (^)(NSString *_Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
