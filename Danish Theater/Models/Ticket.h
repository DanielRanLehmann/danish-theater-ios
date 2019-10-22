//
//  Ticket.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PriceGroup.h"

@interface Ticket : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly, getter=hasAgeRestrictionIndicator) BOOL ageRestrictionIndicator;

@property (nonatomic, readonly, getter=hasVolumeRestrictionIndicator) BOOL volumeRestrictionIndicator;

@property (nonatomic, copy, readonly) NSString *code;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray <PriceGroup *> *priceGroups;

// volumeBegin = 6;
// volumeEnd = 99;

@end
