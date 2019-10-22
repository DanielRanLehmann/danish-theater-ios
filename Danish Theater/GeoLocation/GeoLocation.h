//
//  GeoLocation.h
//  theater
//
//  Created by Daniel Ran Lehmann on 4/23/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPAddress.h"

@interface GeoLocation : NSObject

+ (void)pingIPAddress:(void (^)(NSError *error, IPAddress *address))handler; // or call it pingIPAddress.?

@end
