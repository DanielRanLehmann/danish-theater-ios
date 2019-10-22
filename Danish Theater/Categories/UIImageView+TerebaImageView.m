//
//  UIImageView+TerebaImageView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UIImageView+TerebaImageView.h"
#define GUID @"5ac9856289164d79b9eb641ede3820a8"

@implementation UIImageView (TerebaImageView)

#pragma mark - Public

- (void)setImageWithCode:(NSString *)code orientation:(TerebaImageOrientation)orientation {
    [self setImageWithURL:[NSURL terebaImageURLWithCode:code orientaion:TerebaImageOrientationLandscape]]; // placeholderImage:[UIImage imageNamed:@"default_img_placeholder"]];
}

@end

@implementation NSURL (TerebaImageViewURLAdditions)

+ (NSURL *)terebaImageURLWithCode:(NSString *)code orientaion:(TerebaImageOrientation)orientation {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.tereba.dk/ws/media/?guid=%@&code=%@&format=%@", GUID, code, [NSString stringWithOrientation:orientation]]];
}

@end

@implementation NSString (TerebaImageViewStringAdditions)

+ (NSString *)stringWithOrientation:(TerebaImageOrientation)orientation {
    NSString *str = nil;
    switch (orientation) {
        case TerebaImageOrientationPortrait:
            str = @"portrait";
            break;
            
        case TerebaImageOrientationLandscape:
            str = @"landscape";
            break;
    }
    
    return str;
}

@end
