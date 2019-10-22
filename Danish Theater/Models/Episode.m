//
//  Episode.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/25/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "Episode.h"

@implementation Episode

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"localizedTitle": @"title",
             @"createdAt": @"createdAt",
             @"podcastName": @"podcastName",
             @"podcastId": @"podcastId",
             @"durationInSeconds": @"durationInSeconds"
             };
}

- (void)setEpisodeId:(NSString *)episodeId {
    _episodeId = episodeId;
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"localizedTitle"]) {
        
        // just pick DA for now by default.
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
    
    return self;
}


@end
