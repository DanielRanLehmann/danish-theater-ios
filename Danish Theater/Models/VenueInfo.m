//
//  VenueInfo.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "VenueInfo.h"

@implementation VenueInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cafe": @"cafe",
             @"disabledToilet": @"disabledToilet",
             @"lift": @"lift",
             @"loopset": @"loopset",
             @"parking" : @"parking",
             @"restaurant" : @"restaurant",
             @"wardrobe" : @"wardrobe",
             @"wheelchairAccess" : @"wheelchairAccess"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) {
            return @([value boolValue]);
        }
        
        return nil;
    }];
    
    return nil;
    
}

@end
