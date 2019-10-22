//
//  TicketAgencyInfo.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "TicketAgencyInfo.h"

@implementation TicketAgencyInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"note" : @"note",
             @"preOpeningSpan" : @"preOpeningSpan",
             @"salesMethodKeys" : @"salesMethodKeys",
             @"ticketAgencyName" : @"ticketAgencyName",
             @"ticketsPerShow" : @"ticketsPerShow",
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"preOpeningSpan"] ||
        [key isEqualToString:@"ticketsPerShow"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return @([value unsignedIntegerValue]);
            }
            
            return nil;
        }];
    }
    
    return nil;
    
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

@end
