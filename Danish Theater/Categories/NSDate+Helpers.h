//
//  NSDate+Helpers.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helpers)

// taken from stackoverflow: https://stackoverflow.com/questions/8276187/determine-if-todays-date-is-in-a-range-of-two-dates-on-ios

// bad naming convention.!
- (BOOL)isBetweenDate:(NSDate *)firstDate andDate:(NSDate *)lastDate;

// DAYS

- (NSDate *)beginningOfDay; 
- (NSDate *)endOfDay;

- (NSDate *)appendDays:(NSInteger)days;

// WEEKS

- (NSDate *)beginningOfWeek;
- (NSDate *)endOfWeek;

- (NSDate *)appendWeeks:(NSInteger)weeks;

// MONTHS

- (NSDate *)beginningOfMonth;
- (NSDate *)endOfMonth;

- (NSDate *)appendMonths:(NSInteger)months;

+ (NSDate *)undefinedDate; // 1900-01-01
- (BOOL)isDateUndefined;

@end
