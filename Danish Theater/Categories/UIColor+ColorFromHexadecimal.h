//
//  UIColor+ColorFromHexadecimal.h
//  ColorFromHex
//
//  Created by Daniel Ran Lehmann on 08/06/15.
//  Copyright (c) 2015 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromHexadecimal)

+ (UIColor *)colorWithHex:(NSString *)hexString;

@end
