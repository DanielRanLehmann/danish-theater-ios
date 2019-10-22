//
//  Venue.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Venue.h"

@implementation Venue

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"city": @"city",
             @"countryCode": @"countryCode",
             @"email": @"email",
             @"info": @"info",
             @"landline" : @"landline",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"municipality" : @"municipality",
             @"name" : @"name",
             @"number" : @"number",
             @"postCode" : @"postCode",
             @"region" : @"region",
             @"street" : @"street",
             @"type" : @"type",
             @"url" : @"url"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"latitude"] ||
        [key isEqualToString:@"longitude"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return @([value doubleValue]);
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"url"]) {
        
        return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
    }
    
    return nil;
    
}



@end
