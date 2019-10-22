//
//  GeoLocation.m
//  theater
//
//  Created by Daniel Ran Lehmann on 4/23/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "GeoLocation.h"

@implementation GeoLocation

+ (void)pingIPAddress:(void (^)(NSError *error, IPAddress *address))handler {
    
    NSDictionary *headers = @{ @"cache-control": @"no-cache" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ipinfo.io/json"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                   
                                                        handler(error, nil);
                                                        return;
                                                   
                                                    } else {
                                                        
                                                        IPAddress *address = [[IPAddress alloc] initWithResponse:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]];
                                                        handler(nil, address);
                                                        return;
                                                    }
                                                }];
    [dataTask resume];
    
}

@end
