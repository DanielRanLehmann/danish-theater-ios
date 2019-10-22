//
//  PriceGroup.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "PriceGroup.h"

@implementation PriceGroup

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"price": @"price.price",
             @"currency": @"price.currency",
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"price"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                return @([value floatValue]); // should price be a float?
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
