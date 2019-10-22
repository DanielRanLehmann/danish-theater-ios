//
//  Ticket.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Ticket.h"

@implementation Ticket

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ageRestrictionIndicator": @"ageRestrictionIndicator",
             @"code": @"code",
             @"name": @"name",
             @"priceGroups": @"priceGroups",
             @"volumeRestrictionIndicator": @"volumeRestrictionIndicator",
             };
}

+ (NSValueTransformer *)priceGroupsJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) {
            
            // check to see if value is nil or empty??
            
            NSMutableArray <PriceGroup *> *priceGroups = [NSMutableArray array];
            for (NSDictionary *priceGroup in [NSArray arrayWithArray:value]) {
                [priceGroups addObject:[MTLJSONAdapter modelOfClass:PriceGroup.class fromJSONDictionary:priceGroup error:nil]];
            }
            
            return priceGroups;
        }
        
        return nil;
    }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"ageRestrictionIndicator"] ||
        [key isEqualToString:@"volumeRestrictionIndicator"]) {
       
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return @([value boolValue]);
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
