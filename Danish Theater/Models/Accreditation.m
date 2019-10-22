//
//  Accreditation.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Accreditation.h"

@implementation Accreditation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"firstname" : @"firstname",
             @"lastname" : @"lastname",
             @"positionName" : @"positionName",
             @"positionTypeName" : @"positionTypeName",
             @"index" : @"index"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:@"index"]) {
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
