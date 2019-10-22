//
//  IPAddress.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface IPAddress : NSObject

- (instancetype)initWithResponse:(id)response;

@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *country;
@property (nonatomic, copy, readonly) NSString *hostname;
@property (nonatomic, copy, readonly) NSString *ip;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, copy, readonly) NSString *org;
@property (nonatomic, copy, readonly) NSString *postal;
@property (nonatomic, copy, readonly) NSString *region;

@end
