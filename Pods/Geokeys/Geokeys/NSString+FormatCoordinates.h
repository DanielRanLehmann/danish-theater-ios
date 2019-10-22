//
//  NSString+FormatCoordinates.h
//  Geokeys
//
//  Created by Daniel Ran Lehmann on 3/30/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FormatCoordinates)

+ (NSString *)stringWithFormattedCoordinates:(NSArray *)coordinates;

@end
