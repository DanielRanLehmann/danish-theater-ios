//
//  UIApplication+Reachability.m
//  Theatre
//
//  Created by Daniel Ran Lehmann on 11/8/16.
//  Copyright © 2016 Daniel Ran Lehmann. All rights reserved.
//

#import "UIApplication+Reachability.h"

static NSString *hostname = @"https://www.google.com/";

@implementation UIApplication (Reachability)

- (BOOL)isOnline {
    
    Reachability *reachability = [Reachability reachabilityWithHostname:hostname];
    if ([reachability isReachableViaWiFi] || [reachability isReachableViaWWAN]) {
        return true;
    }
    
    return false;
}

- (BOOL)isOffline {
    Reachability *reachability = [Reachability reachabilityWithHostname:hostname];
    if (![reachability isReachableViaWiFi] || ![reachability isReachableViaWWAN]) {
        return true;
    }
    
    return false;
}

@end
