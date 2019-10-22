//
//  Event.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Event.h"

@implementation Event

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ageBegin": @"ageBegin",
             @"ageEnd": @"ageEnd",
             @"categoryName": @"categoryName",
             @"subcategoryName": @"subcategoryName",
             @"localizedDescription": @"description",
             @"localizedSubtitle" : @"subtitle",
             @"localizedTitle" : @"title",
             
             @"searchTitleDa" : @"searchTitleDa",
             @"searchTitleEn" : @"searchTitleEn",
             
             @"durationInMinutes" : @"durationInMinutes",
             @"formOfStructure" : @"formOfStructure",
             @"intermissionIndicator" : @"intermissionIndicator",
             @"nonVerbal" : @"nonVerbal",
             @"numberedSeats" : @"numberedSeats",
             @"organizationCode" : @"organizationCode",
             @"organizationName" : @"organizationName",
             @"organizationCity" : @"organizationCity", // being tested
             @"playsFrom" : @"playsFrom",
             @"playsTo" : @"playsTo",
             @"primaryLanguage" : @"primaryLanguage",
             @"productionCode" : @"productionCode",
             @"releaseDate" : @"releaseDate", // turns this into an nsdate.
             @"seatTypeName" : @"seatTypeName",
             @"services" : @"services",
             @"sortName" : @"sortName",
             @"sortOfEvent" : @"sortOfEvent",
             @"subscriptionThreshold" : @"subscriptionThreshold",
             @"terms" : @"terms",
             @"totalNumberOfShows" : @"totalNumberOfShows",
             @"venueCodes" : @"venueCodes",
             @"accreditations" : @"accreditations",
             @"contact" : @"contact",
             @"ticketOffice" : @"ticketOffice",
             @"ticketInfo" : @"ticketInfo",
             @"ticketAgencyInfos" : @"ticketAgencyInfos",
             @"tickets" : @"tickets",
             @"videoURL" : @"videoUrl",
             @"categoryNameSubCategoryName" : @"categoryName-subcategoryName",
             
             @"title": @"title", // brand new feb 1. 2018
             @"caption": @"caption" // being tested..
             
             };
}

- (void)setCode:(NSString *)code {
    _code = code;
    // create the thumbnails now..?
    _thumbnail = [[Thumbnail alloc] initWithCode:code];
}

+ (NSValueTransformer *)videoURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)ticketsJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) {
            
            // check to see if value is nil or empty??
            
            NSMutableArray <Ticket *> *tickets = [NSMutableArray array];
            for (NSDictionary *ticket in [NSArray arrayWithArray:value]) {
                [tickets addObject:[MTLJSONAdapter modelOfClass:Ticket.class fromJSONDictionary:ticket error:nil]];
            }
            
            return tickets;
        }
        
        return nil;
    }];
}

+ (NSValueTransformer *)ticketAgencyInfosJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) {
            
            // check to see if value is nil or empty??
            
            NSMutableArray <TicketAgencyInfo *> *ticketAgencyInfos = [NSMutableArray array];
            for (NSDictionary *ticketAgencyInfo in [NSArray arrayWithArray:value]) {
                [ticketAgencyInfos addObject:[MTLJSONAdapter modelOfClass:TicketAgencyInfo.class fromJSONDictionary:ticketAgencyInfo error:nil]];
            }
            
            return ticketAgencyInfos;
        }
        
        return nil;
    }];
}

+ (NSValueTransformer *)ticketInfoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TicketInfo.class];
}

+ (NSValueTransformer *)ticketOfficeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:TicketOffice.class];
}

+ (NSValueTransformer *)accreditationsJSONTransformer {
    return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if (success) {
            
            // check to see if value is nil or empty??
            NSArray *accreditations = [NSArray arrayWithArray:value];
            
            NSMutableArray <Accreditation *> *accreditationsMut = [NSMutableArray arrayWithCapacity:accreditations.count];
            for (NSDictionary *accreditation in accreditations) {
                [accreditationsMut addObject:[MTLJSONAdapter modelOfClass:Accreditation.class fromJSONDictionary:accreditation error:nil]];
            }
            
            return [accreditationsMut copy];
        }
        
        return nil;
    }];
}

+ (NSValueTransformer *)contactJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Contact.class];
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    
    if ([key isEqualToString:@"localizedDescription"] ||
        [key isEqualToString:@"localizedSubtitle"] ||
        [key isEqualToString:@"localizedTitle"]) {
       
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
    
    else if ([key isEqualToString:@"ageBegin"] ||
             [key isEqualToString:@"ageEnd"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                return @([value floatValue]);
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"durationInMinutes"] ||
             [key isEqualToString:@"subscriptionThreshold"] ||
             [key isEqualToString:@"totalNumberOfShows"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                return @([value unsignedIntegerValue]);
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"nonVerbal"] ||
             [key isEqualToString:@"numberedSeats"] ||
             [key isEqualToString:@"intermissionIndicator"]) {
        
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                
                return @([value boolValue]);
            }
            
            return nil;
        }];
    }
    
    else if ([key isEqualToString:@"releaseDate"]) {
        return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
            return [self.dateFormatter dateFromString:dateString];
        } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
            return [self.dateFormatter stringFromDate:date];
        }];
    }
    
    else if ([key isEqualToString:@"services"] ||
             [key isEqualToString:@"venueCodes"]) {
        return [MTLValueTransformer transformerUsingReversibleBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (success) {
                return [NSArray arrayWithArray:value];
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
