//
//  TicketInfo.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TicketInfo : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSURL *otherSubscriptionURL;
@property (nonatomic, copy, readonly) NSString *reducedDayOfWeek;
@property (nonatomic, copy, readonly) NSURL *ticketOfficeURL;
@property (nonatomic, copy, readonly) NSURL *ticketOperatorURL;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURL *venueSubscriptionURL;
@property (nonatomic, copy, readonly) NSString *weekendAddition;

@end
