//
//  NSString+FormatHelpers.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "NSString+FormatHelpers.h"

@implementation NSString (FormatHelpers)

+ (NSString *)stringWithFormattedPhoneNumber:(NSString *)aString {
    if (aString.length == 8) {
        NSMutableString *resultString = [NSMutableString string];
        
        for(int i = 0; i< [aString length] / 2; i++) {
            NSUInteger fromIndex = i * 2;
            NSUInteger len = [aString length] - fromIndex;
            if (len > 2) {
                len = 2;
            }
            
            [resultString appendFormat:@"%@ ", [aString substringWithRange:NSMakeRange(fromIndex, len)]];
        }
        return resultString;
    }
    
    return aString; // simply return the raw string.
}

+ (NSString *)stringWithCompactPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets {
    NSString *priceRangeStr = [NSString stringWithNormalPriceRangeForEventWithTickets:tickets]; // [NSString stringWithPriceRangeForEventWithTickets:tickets];
    if ([priceRangeStr isEqualToString:NSLocalizedString(@"FREE_TEXT", nil).uppercaseString]) {
        return priceRangeStr;
    }
    
    if ([priceRangeStr rangeOfString:@"-"].location != NSNotFound) {
        NSArray *compsPriceRange = [priceRangeStr componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@ %@ DKK", NSLocalizedString(@"FROM_TEXT", nil), [[compsPriceRange firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    
    return [NSString stringWithFormat:@"%@ DKK", priceRangeStr];
    
}

// NEW PRICE RANGE APPROACH
+ (NSString *)stringWithNormalPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets {
    NSRange priceRange = NSMakeRange(0, 0);
    NSString *str = nil;
    
    if (tickets.count > 0) {
        for (Ticket *ticket in tickets) {
            if ([ticket.name isEqualToString:@"Løssalg"]) { // use ticket.name or ticket.code?
                for (PriceGroup *priceGroup in ticket.priceGroups) {
                    if (priceRange.location == 0) {
                        priceRange.location = priceGroup.price;
                    }
                    
                    else if (((NSUInteger)priceGroup.price < priceRange.location) && (NSUInteger)priceGroup.price != 0) {
                        priceRange.location = priceGroup.price;
                    }
                    
                    if ((NSUInteger)priceGroup.price > priceRange.length) {
                        priceRange.length = priceGroup.price;
                    }
                }
                break; // no reason to look at the other ticket groups, once completed.
            }
        }
    }
    
    // CASES AND EDGES
    if (priceRange.location == 0 && priceRange.length == 0) {
        str = NSLocalizedString(@"FREE_TEXT", nil).uppercaseString; // should be uppercase
        
    } else if (priceRange.location == priceRange.length) {
        str = [NSString stringWithFormat:@"%lu", priceRange.location];
        
    } else {
        str = [NSString stringWithFormat:@"%lu - %lu", priceRange.location, priceRange.length];
    }
    
    return str;
}

// DEPRECATEED.
+ (NSString *)stringWithPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets {
    NSRange priceRange = NSMakeRange(0, 0);
    NSString *str = nil;
    if (tickets.count > 0) {
        for (Ticket *ticket in tickets) {
            for (PriceGroup *priceGroup in ticket.priceGroups) {
                
                if (priceRange.location == 0) {
                    priceRange.location = priceGroup.price;
                }
                
                else if (((NSUInteger)priceGroup.price < priceRange.location) && (NSUInteger)priceGroup.price != 0) {
                    priceRange.location = priceGroup.price;
                }
                
                if ((NSUInteger)priceGroup.price > priceRange.length) {
                    priceRange.length = priceGroup.price;
                }
            }
        }
    }
    
    // CASES AND EDGES
    if (priceRange.location == 0 && priceRange.length == 0) {
        str = NSLocalizedString(@"FREE_TEXT", nil).uppercaseString; // should be uppercase
    
    } else if (priceRange.location == priceRange.length) {
        str = [NSString stringWithFormat:@"%lu", priceRange.location];
    
    } else {
        str = [NSString stringWithFormat:@"%lu - %lu", priceRange.location, priceRange.length];
    }
    
    return str;
}

+ (NSString *)stringWithPlayingPeriodFromPlaysFrom:(NSString *)playsFrom andPlaysTo:(NSString *)playsTo {
    
    NSString *playingPeriod;
    
    NSArray <NSString *> *playDates = @[playsFrom, playsTo];
    NSMutableSet <NSDate *> *playSet = [NSMutableSet set];
    
    for (NSString *playDate in playDates) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:playDate];
        [playSet addObject:date];
    }
    
    if (playSet.count == 1) { // 0 or 1?
        
        // NEW
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [NSLocale currentLocale];
        if ([locale.localeIdentifier isEqualToString:@"da"]) {
            [newDateFormatter setLocale:locale];
            [newDateFormatter setDateFormat:@"d MMM YYYY"];
        }
        
        else {
            [newDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
            [newDateFormatter setDateFormat:@"MMM d YYYY"];
        }
        
        NSDate *date = [[playSet allObjects] firstObject];
        playingPeriod = [newDateFormatter stringFromDate:date];
    }
    
    else {
        
        // NEW
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [NSLocale currentLocale];
        if ([locale.localeIdentifier isEqualToString:@"da"]) {
            [newDateFormatter setLocale:locale];
            [newDateFormatter setDateFormat:@"d MMM YYYY"];
        }
        
        else {
            [newDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
            [newDateFormatter setDateFormat:@"MMM d YYYY"];
        }
        
        NSArray *allDates = [[playSet allObjects] sortedArrayUsingSelector:@selector(compare:)];
        
        NSDate *fromDate = [allDates firstObject];
        NSDate *toDate = [allDates lastObject];
        playingPeriod = [NSString stringWithFormat:@"%@ - %@", [newDateFormatter stringFromDate:fromDate], [newDateFormatter stringFromDate:toDate]];
        
        // check and possibly remove the first encountered year.
    }
    
    NSMutableArray <NSString *> *validComponents = [NSMutableArray array];
    
    for (NSString *component in [playingPeriod componentsSeparatedByString:@""]) { // should be @"" and not @" ": otherwise an add. \s will be added.
        if (component.length == 4) {
            [validComponents addObject:component];
        }
    }
    
    NSCountedSet *set = [[NSCountedSet alloc] initWithArray:validComponents];
    for (id item in set) {
        NSUInteger itemCount = [set countForObject:item];
        if (itemCount > 1) {
            NSRange firstYearRange = [playingPeriod rangeOfString:item];
            if (firstYearRange.location != NSNotFound) {
                playingPeriod = [playingPeriod stringByReplacingCharactersInRange:firstYearRange withString:@""];
            }
        }
    }
    
    return playingPeriod;
}

- (NSString *)stringWithCapitalNeighborHood { // or cityNeigh.
    if ([self rangeOfString:@"København"].location == NSNotFound) {
        return self;
    }
    
    NSString *neighborhood = self;
    
    // Vesterbro
    if ([neighborhood hasSuffix:@"V"]) {
        neighborhood = @"Vesterbro";
    }
    
    else if ([neighborhood hasSuffix:@"Ø"]) {
        neighborhood = @"Østerbro";
    }
    
    else if ([neighborhood hasSuffix:@"N"]) {
        neighborhood = @"Nørrebro";
    }
    
    else if ([neighborhood hasSuffix:@"N"]) {
        neighborhood = @"København";
    }
    
    NSLog(@"neighborhood => %@", neighborhood);
    
    return neighborhood;
}

+ (NSString *)stringWithAgeRangeFromAgeBegin:(CGFloat)ageBegin ageEnd:(CGFloat)ageEnd {

    BOOL isAgeBeginInteger = !fmod(ageBegin, 1.0);
    BOOL isAgeEndInteger = !fmod(ageEnd, 1.0);
    
    NSMutableString *ageRange = [NSMutableString stringWithFormat:@"%@", isAgeBeginInteger ? [NSString stringWithFormat:@"%.0f", ageBegin] : [NSString stringWithFormat:@"%.1f", ageBegin]];
    
    if (ageEnd != 0) {
        [ageRange appendFormat:@" - %@ %@", isAgeEndInteger ? [NSString stringWithFormat:@"%.0f", ageEnd] : [NSString stringWithFormat:@"%.1f", ageEnd], NSLocalizedString(@"YEARS_SUFFIX_TEXT", nil)];
    }
    
    else {
        [ageRange appendString:@" "];
        [ageRange appendString:NSLocalizedString(@"YEARS_AND_UP_SUFFIX_TEXT", nil)];
        
    }
    
   
    if ([ageRange isEqualToString:[NSString stringWithFormat:@"0 %@", NSLocalizedString(@"YEARS_AND_UP_SUFFIX_TEXT", nil)]]) {
        ageRange = [NSMutableString stringWithFormat:NSLocalizedString(@"EVERYBODY_SUFFIX_TEXT", nil)];
    }
    
    return ageRange;
}

+ (NSString *)stringWithFormattedAddressWithOrganization:(Organization *)organization {

    NSString *address = nil;
    
    if (organization.street && organization.number && organization.postCode && organization.city) {
        address = [NSString stringWithFormat:@"%@ %@, %@ %@", organization.street, organization.number, organization.postCode, organization.city];
    }
    
    return address;
}

+ (NSString *)stringWithFormattedAddressWithVenue:(Venue *)venue {

    NSString *address = nil;
    if (venue.street && venue.number && venue.postCode && venue.city) {
        address = [NSString stringWithFormat:@"%@ %@, %@ %@", venue.street, venue.number, venue.postCode, venue.city];
    }
    
    return address;
}

@end
