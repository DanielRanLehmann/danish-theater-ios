//
//  Organization.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Organization.h"

@implementation Organization

- (void)setCode:(NSString *)code {
    _code = code;
    _thumbnail = [[Thumbnail alloc] initWithCode:code];
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"artisticDirector": @"artisticDirector",
             @"city": @"city",
             @"contact": @"contact",
             @"countryCode": @"countryCode",
             @"countryName" : @"countryName",
             @"localizedDescription" : @"description",
             @"email" : @"email",
             @"formOfOrganisation" : @"formOfOrganisation",
             @"foundedDate" : @"foundedDate",
             @"generalManager" : @"generalManager",
             @"governmentSubsidies" : @"governmentSubsidies",
             @"landline" : @"landline",
             @"municipality" : @"municipality",
             @"name" : @"name",
             @"searchName" : @"searchName",
             @"number" : @"number",
             @"organizer" : @"organizer",
             @"organizerProfiles" : @"organizerProfiles",
             @"otherGovernmentSubsidies" : @"otherGovernmentSubsidies",
             @"postCode" : @"postCode",
             @"producer" : @"producer",
             @"producerProfiles" : @"producerProfiles",
             @"region" : @"region",
             @"street" : @"street",
             @"venueCodes" : @"venueCodes"
             };
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"localizedDescription"]) {
        
        // just pick DA for now by default.
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return value[@"da"];
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"foundedDate"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
            return [self.dateFormatter dateFromString:dateString];
        } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
            return [self.dateFormatter stringFromDate:date];
        }];
    }
    
    else if ([key isEqualToString:@"governmentSubsidies"] ||
             [key isEqualToString:@"venueCodes"] ||
             [key isEqualToString:@"organizerProfiles"] ||
             [key isEqualToString:@"otherGovernmentSubsidies"] ||
             [key isEqualToString:@"producerProfiles"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return [NSArray arrayWithArray:value];
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"organizer"] ||
             [key isEqualToString:@"producer"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                return @([value boolValue]);
            }
            
            return nil;
        }];
    }
    
    return nil;
    
}

@end
