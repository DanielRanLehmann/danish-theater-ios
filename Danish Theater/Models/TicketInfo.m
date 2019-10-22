//
//  TicketInfo.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "TicketInfo.h"

@implementation TicketInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"otherSubscriptionURL" : @"otherSubscriptionURL",
             @"reducedDayOfWeek" : @"reducedDayOfWeek",
             @"ticketOfficeURL" : @"ticketOfficeURL",
             @"ticketOperatorURL" : @"ticketOperatorURL",
             @"url" : @"url",
             @"venueSubscriptionURL" : @"venueSubscriptionURL",
             @"weekendAddition" : @"weekendAddition"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"otherSubscriptionURL"] ||
        [key isEqualToString:@"ticketOfficeURL"] ||
        [key isEqualToString:@"ticketOperatorURL"] ||
        [key isEqualToString:@"url"] ||
        [key isEqualToString:@"venueSubscriptionURL"])
    {
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}




@end
