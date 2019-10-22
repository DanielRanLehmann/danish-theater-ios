//
//  Event.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <UIKit/UIKit.h>

#import "Thumbnail.h"
#import "Accreditation.h"
#import "Contact.h"
#import "TicketOffice.h"
#import "TicketInfo.h"
#import "TicketAgencyInfo.h"
#import "Ticket.h"

@import Firebase;

@interface Event : MTLModel <MTLJSONSerializing>

// forget about the other models for now..
@property (nonatomic, strong) NSString *code;

@property (nonatomic, readonly) CGFloat ageBegin;
@property (nonatomic, readonly) CGFloat ageEnd;

@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, copy, readonly) NSString *subcategoryName;

// This has recently been added and is used by 'You may also like' section in DTEventDetailVC
@property (nonatomic, copy, readonly) NSString *categoryNameSubCategoryName;


@property (nonatomic, copy, readonly) NSDictionary *title;

@property (nonatomic,  copy, readonly) NSString *localizedDescription; // reserved?
@property (nonatomic,  copy, readonly) NSString *localizedSubtitle; // reserved?
@property (nonatomic, copy, readonly) NSString *localizedTitle;

@property (nonatomic, copy, readonly) NSString *searchTitleDa;
@property (nonatomic, copy, readonly) NSString *searchTitleEn;

@property (nonatomic, readonly) NSUInteger durationInMinutes;
@property (nonatomic,  copy, readonly) NSString *formOfStructure;

@property (nonatomic, readonly, getter=hasIntermissionIndicator) BOOL intermissionIndicator;
@property (nonatomic, readonly, getter=isNonVerbal) BOOL nonVerbal;
@property (nonatomic, readonly, getter=hasNumberedSeats) BOOL numberedSeats;

@property (nonatomic, copy, readonly) NSString *organizationCode; // keep this, don't start to download the organization, here!! because then you're missing the point.
@property (nonatomic, copy, readonly) NSString *organizationName;

@property (nonatomic, copy, readonly) NSString *organizationCity; // being tested

@property (nonatomic,  copy, readonly) NSString *playsFrom;
@property (nonatomic,  copy, readonly) NSString *playsTo;

@property (nonatomic,  copy, readonly) NSString *primaryLanguage;
@property (nonatomic,  copy, readonly) NSString *productionCode;

@property (nonatomic,  copy, readonly) NSDate *releaseDate;

@property (nonatomic,  copy, readonly) NSString *seatTypeName;

@property (nonatomic, copy, readonly) NSArray <NSString *> *services; // could bring trouble

@property (nonatomic,  copy, readonly) NSString *sortName;
@property (nonatomic,  copy, readonly) NSString *sortOfEvent;

@property (nonatomic, readonly) NSUInteger subscriptionThreshold;

@property (nonatomic,  copy, readonly) NSString *terms;

@property (nonatomic, readonly) NSUInteger totalNumberOfShows;

@property (nonatomic, copy, readonly) NSArray <NSString *> *venueCodes;

@property (nonatomic, copy, readonly) NSArray <Accreditation *> *accreditations; // should this be a copy?
@property (nonatomic, strong, readonly) Contact *contact;

@property (nonatomic, strong, readonly) TicketOffice *ticketOffice;
@property (nonatomic, strong, readonly) TicketInfo *ticketInfo;

@property (nonatomic, copy, readonly) NSArray <TicketAgencyInfo *> *ticketAgencyInfos;
@property (nonatomic, copy, readonly) NSArray <Ticket *> *tickets;

@property (nonatomic, copy, readonly) NSURL *videoURL;

//@property (nonatomic, strong) FIRStorageReference *imageRef;
@property (nonatomic, strong) Thumbnail *thumbnail;

@property (nonatomic, copy, readonly) NSString *caption; // being tested

@end
