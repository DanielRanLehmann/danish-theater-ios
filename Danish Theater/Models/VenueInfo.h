//
//  VenueInfo.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface VenueInfo : MTLModel <MTLJSONSerializing> 

@property (nonatomic, readonly, getter=hasCafe) BOOL cafe;
@property (nonatomic, readonly, getter=hasDisabledToilet) BOOL disabledToilet;
@property (nonatomic, readonly, getter=hasLift) BOOL lift;
@property (nonatomic, readonly, getter=hasLoopset) BOOL loopset;
@property (nonatomic, readonly, getter=hasParking) BOOL parking;
@property (nonatomic, readonly, getter=hasPublicTransport) BOOL publicTransport;
@property (nonatomic, readonly, getter=hasRestaurant) BOOL restaurant;
@property (nonatomic, readonly, getter=hasWardrobe) BOOL wardrobe;
@property (nonatomic, readonly, getter=hasWheelchairAccess) BOOL wheelchairAccess;

@end
