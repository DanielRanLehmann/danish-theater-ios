//
//  Venue.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <UIKit/UIKit.h>
#import "VenueInfo.h"

@interface Venue : MTLModel <MTLJSONSerializing> 

@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, readonly) VenueInfo *info;
@property (nonatomic, copy, readonly) NSString *landline;
@property (nonatomic, readonly) double latitude;
@property (nonatomic, readonly) double longitude;
@property (nonatomic, copy, readonly) NSString *municipality;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *number;
@property (nonatomic, copy, readonly) NSString *postCode;
@property (nonatomic, copy, readonly) NSString *region;
@property (nonatomic, copy, readonly) NSString *street;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSURL *url;

@end
