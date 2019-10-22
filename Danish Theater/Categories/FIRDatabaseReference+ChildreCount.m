//
//  FIRDatabaseReference+ChildreCount.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/21/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "FIRDatabaseReference+ChildreCount.h"

@import FirebaseAuth;
#import <Foundation/Foundation.h>

@implementation FIRDatabaseReference (ChildreCount)

- (void)getNumberOfChildrenWithStartingKey:(NSString *)startingKey completion:(ChildrenCountCallBack)completion {
    
    [self observeShallowEventTypeValueWithCompletion:^(NSDictionary *json, NSError *error) {
        if (error) {
            completion(0, error);
            return;
            
        } else {
            
            NSUInteger childrenCount = [[json allKeys] count];
            if (startingKey) {
                NSMutableDictionary *tempJSON = [NSMutableDictionary dictionaryWithDictionary:json];
                [json enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
                    
                    if ([key isEqualToString:startingKey]) {
                        *stop = YES;
                        return;
                    }
                    [tempJSON removeObjectForKey:key];
                    
                }];
                
                childrenCount = tempJSON.count;
            }
            
            completion(childrenCount, nil);
            return;
        }
    }];
}

- (void)observeShallowEventTypeValueWithCompletion:(ObserveShallowCallback)completion {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        
        // SHOULD ALSO SUPPORT NON AUTH.
        // HOW TO, THOUGH?
        FIRUser *user = [FIRAuth auth].currentUser;
        [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json?shallow=true&auth=%@", self.URL, token]]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10.0];
            [request setHTTPMethod:@"GET"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                completion(nil, error);
                                                                return;
                                                                
                                                            } else {
                                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                     options:kNilOptions
                                                                                                                       error:nil];
                                                                
                                                                completion(json, error);
                                                                return;
                                                            }
                                                        }];
            [dataTask resume];
        }];
        
    });
}

@end
