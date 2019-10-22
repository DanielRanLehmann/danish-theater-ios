//
//  NSDate+Helpers.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

- (BOOL)isBetweenDate:(NSDate *)firstDate andDate:(NSDate *)lastDate {
    
    return [self compare:firstDate] == NSOrderedDescending &&
    [self compare:lastDate]  == NSOrderedAscending;
}

#pragma mark - Day

- (NSDate *)beginningOfDay {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}

- (NSDate *)endOfDay {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:self];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
    
}

- (NSDate *)appendDays:(NSInteger)days {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = days;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

#pragma mark - Week

- (NSDate *)appendWeeks:(NSInteger)weeks {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 7 * weeks; // this is a safer way to day it?
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSDate *)beginningOfWeek {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    
    NSCalendar *gregorian = [[NSCalendar alloc]        initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekOfYear | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    
    int dayofweek = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];// this will give you current day of week
    
    [components setDay:([components day] - ((dayofweek) - 2))];// for beginning of the week.
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat_first = [[NSDateFormatter alloc] init];
    [dateFormat_first setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateString2Prev = [dateFormat stringFromDate:beginningOfWeek];
    
    NSDate *weekstartPrev = [dateFormat_first dateFromString:dateString2Prev];
    
    return weekstartPrev;
}

- (NSDate *)endOfWeek { // this is not well written., hard to read.
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    
    NSCalendar *gregorianEnd = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *componentsEnd = [gregorianEnd components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    int endDayofWeek = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self] weekday];// this will give you current day of week
    
    [componentsEnd setDay:([componentsEnd day]+(7-endDayofWeek)+1)];// for end day of the week
    
    NSDate *endOfWeek = [gregorianEnd dateFromComponents:componentsEnd];
    NSDateFormatter *dateFormatEnd = [[NSDateFormatter alloc] init];
    [dateFormatEnd setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateEndPrev = [dateFormat stringFromDate:endOfWeek];
    
    NSDate *weekEndPrev = [dateFormatEnd dateFromString:dateEndPrev];
    
    return weekEndPrev;
}

// Beginning of this week.
// https://stackoverflow.com/questions/11681815/current-week-start-and-end-date

#pragma mark - Month

/*
// Only created, for better readability
+ (NSDate *)thisMonth {
    return [NSDate date];
}
*/

- (NSDate *)appendMonths:(NSInteger)months {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = months;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:dateComponents toDate:self options:0];
}

- (NSDate *)beginningOfMonth {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *arbitraryDate = self;
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
   
    [comp setDay:1];
    
    return [gregorian dateFromComponents:comp];
}

- (NSDate *)endOfMonth {
    
    NSDate *curDate = self;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday fromDate:curDate]; // Get necessary date components
    
    // set last of month
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *tDateMonth = [calendar dateFromComponents:comps];
    
    return tDateMonth;
}

+ (NSDate *)undefinedDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter dateFromString:@"1900-01-01"];
}

- (BOOL)isDateUndefined {
    return [self isEqualToDate:[NSDate undefinedDate]];
}

@end
