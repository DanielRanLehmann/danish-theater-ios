//
//  Contact.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Contact.h"

@implementation Contact

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"email" : @"email",
             @"firstname" : @"firstname",
             @"lastname" : @"lastname",
             @"landline" : @"landline",
             @"mobile" : @"mobile",
             @"position" : @"position"
             };
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    return self;
}

@end
