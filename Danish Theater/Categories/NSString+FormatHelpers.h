//
//  NSString+FormatHelpers.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Ticket.h" 
#import "Organization.h"
#import "Venue.h"

@interface NSString (FormatHelpers)

+ (NSString *)stringWithCompactPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets;

+ (NSString *)stringWithFormattedPhoneNumber:(NSString *)aString;
+ (NSString *)stringWithNormalPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets;
+ (NSString *)stringWithPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets;
+ (NSString *)stringWithPlayingPeriodFromPlaysFrom:(NSString *)playsFrom andPlaysTo:(NSString *)playsTo;

// a helper that converts this: København V into this: Vesterbro.
- (NSString *)stringWithCapitalNeighborHood;

+ (NSString *)stringWithAgeRangeFromAgeBegin:(CGFloat)ageBegin ageEnd:(CGFloat)ageEnd;

// ADDRESS FORMATTING
+ (NSString *)stringWithFormattedAddressWithOrganization:(Organization *)organization;
+ (NSString *)stringWithFormattedAddressWithVenue:(Venue *)venue;

@end
