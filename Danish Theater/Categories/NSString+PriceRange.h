//
//  NSString+PriceRange.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ticket.h"
#import <UIKit/UIKit.h>

@interface NSString (PriceRange)

+ (NSString *)stringWithPriceRangeForEventWithTickets:(NSArray <Ticket *> *)tickets;

@end
