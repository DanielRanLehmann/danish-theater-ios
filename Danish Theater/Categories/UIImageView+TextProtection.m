//
//  UIImageView+TextProtection.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/6/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UIImageView+TextProtection.h"

@implementation UIImageView (TextProtection)

// Follows this guide
// https://material.io/guidelines/style/imagery.html#imagery-ui-integration
// Section: Text Protection

- (void)applyTextProtectionWithFrame:(CGRect)frame opacity:(CGFloat)opacity {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    gradient.locations = @[@(.3)];
    
    /*
    if (opacity == UIImageViewTextProtectionOpacityDynamic) {
        opacity = .6;
    }
    */
    
    gradient.opacity = opacity;
    
    gradient.colors = @[(id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    
    [self.layer addSublayer:gradient];
}

@end

@implementation UIView (TextProtectionAdditions)

- (void)applyTextProtectionWithFrame:(CGRect)frame opacity:(CGFloat)opacity {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    gradient.locations = @[@(.3)];
    
    /*
     if (opacity == UIImageViewTextProtectionOpacityDynamic) {
     opacity = .6;
     }
     */
    
    gradient.opacity = opacity;
    
    gradient.colors = @[(id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    
    [self.layer addSublayer:gradient];
}

@end
