//
//  TicketOffice.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TicketOffice : MTLModel <MTLJSONSerializing> 

@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *countryName;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *email2;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *ticketPhone;
@property (nonatomic, copy, readonly) NSURL *url;


@end
