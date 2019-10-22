//
//  UIImageView+TerebaImageView.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

typedef enum : NSUInteger {
    TerebaImageOrientationPortrait,
    TerebaImageOrientationLandscape
} TerebaImageOrientation;

@interface UIImageView (TerebaImageView)

- (void)setImageWithCode:(NSString *)code orientation:(TerebaImageOrientation)orientation;

@end

@interface NSURL (TerebaImageViewURLAdditions)

+ (NSURL *)terebaImageURLWithCode:(NSString *)code orientaion:(TerebaImageOrientation)orientation;

@end

@interface NSString (TerebaImageViewStringAdditions)

+ (NSString *)stringWithOrientation:(TerebaImageOrientation)orientation;

@end
