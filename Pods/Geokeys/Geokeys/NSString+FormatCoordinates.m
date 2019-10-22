//
//  NSString+FormatCoordinates.m
//  Geokeys
//
//  Created by Daniel Ran Lehmann on 3/30/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "NSString+FormatCoordinates.h"

@implementation NSString (FormatCoordinates)

// support cllocationcoordinate struct as well?
+ (NSString *)stringWithFormattedCoordinates:(NSArray *)coordinates {
    
    NSMutableString *coordPairs = [NSMutableString string];
    NSMutableArray *updatedCoords = [NSMutableArray arrayWithCapacity:coordinates.count];
    
    if ([[coordinates firstObject] isKindOfClass:[NSArray class]]) {
        for (NSArray *coordPair in coordinates) {
            [updatedCoords addObjectsFromArray:coordPair];
        }
    } else {
        [updatedCoords addObjectsFromArray:coordinates];
    }
    
    if (updatedCoords.count > 2 && updatedCoords.count % 2 == 0) {
        for (int i = 0; i < updatedCoords.count; i+=2) {
            [coordPairs appendFormat:@"%f,%f", [updatedCoords[i] doubleValue], [updatedCoords[i+1] doubleValue]]; // full intended preciscion is important to keep intact here. ??
            if (i != updatedCoords.count - 2) {
                [coordPairs appendString:@";"];
            }
        }
    }
    
    else if (coordinates.count == 2) {
        [coordPairs appendString:[updatedCoords componentsJoinedByString:@","]];
    }
    
    return coordPairs;
}

@end
