//
//  Show.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@import Firebase;

@interface Show : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *code; // the showCode.

@property (nonatomic, copy, readonly) NSString *date;
@property (nonatomic, copy, readonly) NSString *time;
@property (nonatomic, copy, readonly) NSString *eventCode;
@property (nonatomic, copy, readonly) NSString *stage;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *venueCode;
@property (nonatomic, copy, readonly) NSString *organizationCode;

@property (nonatomic, copy, readonly) NSString *localizedEventTitle;
@property (nonatomic, copy, readonly) NSString *organizationName;

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, copy, readonly) NSString *venueName;

+ (NSDateFormatter *)dateFormatter;

@property (nonatomic, strong) FIRStorageReference *imageRef;

@end
