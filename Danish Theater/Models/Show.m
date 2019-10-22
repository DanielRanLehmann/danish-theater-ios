//
//  Show.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Show.h"

@implementation Show

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"code" : @"code",
             @"date" : @"date",
             @"time" : @"time",
             @"eventCode" : @"eventCode",
             @"organizationCode" : @"organizationCode",
             @"stage" : @"stage",
             @"type" : @"type",
             @"venueCode" : @"venueCode",
             @"localizedEventTitle" : @"eventTitle",
             @"organizationName" : @"organizationName",
             @"organizationCode" : @"organizationCode",
             @"timestamp" : @"timestamp",
             @"venueName" : @"venueName"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"timestamp"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return @([value doubleValue]);
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"localizedEventTitle"]) {
        
        // just pick DA for now by default.
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return value[@"da"];
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
