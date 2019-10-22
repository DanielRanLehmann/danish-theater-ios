//
//  TicketAgencyInfo.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TicketAgencyInfo : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *note;
@property (nonatomic, readonly) NSUInteger preOpeningSpan;
@property (nonatomic, copy, readonly) NSString *salesMethodKeys;
@property (nonatomic, copy, readonly) NSString *ticketAgencyName;
@property (nonatomic, readonly) NSUInteger ticketsPerShow;

@end
