//
//  TicketOffice.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "TicketOffice.h"

@implementation TicketOffice

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"countryCode" : @"countryCode",
             @"countryName" : @"countryName",
             @"email" : @"email",
             @"email2" : @"email2",
             @"name" : @"name",
             @"ticketPhone" : @"ticketPhone",
             @"url" : @"url"
             };
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}


@end
