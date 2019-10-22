//
//  SearchItem.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 2/1/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "SearchItem.h"

@implementation SearchItem

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"searchItemId": @"searchItemId",
             @"lastVisitAt": @"lastVisitAt",
             @"title": @"title",
             @"localizedTitle": @"localizedTitle",
             @"visitCount": @"visitCount",
             @"contentId": @"contentId",
             @"contentType": @"contentType"
             };
}

+ (NSValueTransformer *)stateJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"event": @(DTSearchItemContentTypeEvent),
                                                                           @"organization": @(DTSearchItemContentTypeOrganization)
                                                                           }];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"localizedTitle"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
                if ([preferredLocalization isEqualToString:@"da"]) {
                    return value[@"da"];
                }
                
                else { // defaults to english.
                    return value[@"en"] ? value[@"en"] : value[@"da"];
                }
                
            }
            
            return nil;
        }];
    }
    
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    _lastVisitAt = [[NSDate date] timeIntervalSince1970];
    
    return self;
}



@end
