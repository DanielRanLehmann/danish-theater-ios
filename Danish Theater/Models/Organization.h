//
//  Organization.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "Contact.h"
#import "Thumbnail.h"

@import Firebase;

@interface Organization : MTLModel <MTLJSONSerializing>

// forget about the other models for now..
@property (nonatomic, strong) NSString *code;

@property (nonatomic, copy, readonly) NSString *artisticDirector;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, readonly) Contact *contact;
@property (nonatomic, copy, readonly) NSString *countryCode;
@property (nonatomic, copy, readonly) NSString *countryName;
@property (nonatomic, copy, readonly) NSString *localizedDescription;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *formOfOrganisation;
@property (nonatomic, copy, readonly) NSDate *foundedDate;
@property (nonatomic, copy, readonly) NSString *generalManager;
@property (nonatomic, readonly) NSArray <NSString *> *governmentSubsidies;
@property (nonatomic, copy, readonly) NSString *landline;
@property (nonatomic, copy, readonly) NSString *municipality;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *searchName;
@property (nonatomic, copy, readonly) NSString *number;
@property (nonatomic, readonly, getter=isOrganizer) BOOL organizer;
@property (nonatomic, readonly) NSArray <NSString *> *organizerProfiles;
@property (nonatomic, readonly) NSArray <NSString *> *otherGovernmentSubsidies;
@property (nonatomic, copy, readonly) NSString *postCode;
@property (nonatomic, readonly, getter=isProducer) BOOL producer;
@property (nonatomic, readonly) NSArray <NSString *> *producerProfiles;
@property (nonatomic, copy, readonly) NSString *region;
@property (nonatomic, copy, readonly) NSString *street;
@property (nonatomic, readonly) NSArray <NSString *> *venueCodes;

//@property (nonatomic, strong) FIRStorageReference *imageRef;
@property (nonatomic, strong) Thumbnail *thumbnail;

@end
