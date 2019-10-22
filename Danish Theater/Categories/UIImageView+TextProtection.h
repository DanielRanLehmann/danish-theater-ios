//
//  UIImageView+TextProtection.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/6/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// const CGFloat UIImageViewTextProtectionOpacityDynamic; // brings linker error, so UIKIT extern use?

@interface UIImageView (TextProtection)

- (void)applyTextProtectionWithFrame:(CGRect)frame opacity:(CGFloat)opacity; // should have more inputs.

@end

@interface UIView (TextProtectionAdditions)

- (void)applyTextProtectionWithFrame:(CGRect)frame opacity:(CGFloat)opacity;

@end
