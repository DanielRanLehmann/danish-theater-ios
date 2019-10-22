//
//  NSString+PriceRange.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "NSString+PriceRange.h"

@implementation NSString (PriceRange)

+ (NSString *)stringWithPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets {
    NSRange priceRange = NSMakeRange(0, 0);
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
    
    return [NSString stringWithFormat:@"%lu - %lu", priceRange.location, priceRange.length];
}

@end
