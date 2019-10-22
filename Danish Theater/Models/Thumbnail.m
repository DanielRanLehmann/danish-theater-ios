//
//  Thumbnail.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 11/17/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Thumbnail.h"

@implementation Thumbnail

- (instancetype)initWithCode:(NSString *)code {
    if (self == [super init]) {
        // magic goes here.
        FIRStorage *storage = [FIRStorage storage];
        
        NSString *model = nil;
        if ([code hasPrefix:@"EV"]) {
            model = @"events";
        } else if ([code hasPrefix:@"OR"]) {
            model = @"organizations";
        }
        self.defaultImageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/%@/%@/default.jpeg", model, code]];
        self.mediumImageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/%@/%@/medium.jpeg", model, code]];
        self.highImageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/%@/%@/high.jpeg", model, code]];
        self.standardImageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/%@/%@/standard.jpeg", model, code]];
        self.maxresImageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/%@/%@/maxres.jpeg", model, code]];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

@end
