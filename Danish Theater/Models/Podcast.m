//
//  Podcast.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/25/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "Podcast.h"

@implementation Podcast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"email": @"email",
             @"publicationYear": @"publicationYear",
             @"localizedDescription": @"description"
             };
}

- (void)setPodcastId:(NSString *)podcastId {
    _podcastId = podcastId;
   
    // create the thumbnails now..?
    //_thumbnail = [[Thumbnail alloc] initWithCode:code];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"localizedDescription"]) {
        
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
    
    if ([dictionaryValue[@"type"] isEqualToString:@"audio"]) {
        _type = DTPodcastTypeAudio;
    } else if ([dictionaryValue[@"type"] isEqualToString:@"video"]) {
        _type = DTPodcastTypeVideo;
    }
    
    return self;
}

@end
