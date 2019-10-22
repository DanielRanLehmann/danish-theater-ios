//
//  UIColor+ColorFromHexadecimal.m
//  ColorFromHex
//
//  Created by Daniel Ran Lehmann on 08/06/15.
//  Copyright (c) 2015 Daniel Ran Lehmann. All rights reserved.
//

#import "UIColor+ColorFromHexadecimal.h"

@implementation UIColor (ColorFromHexadecimal)

// Should be renmaed to: colorWithHex:
+ (UIColor *)colorWithHex:(NSString *)hexString {

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; //bypass the '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0 green:((rgbValue & 0xFF00) >> 8) / 255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
