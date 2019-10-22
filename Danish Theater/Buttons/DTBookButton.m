//
//  DTBookButton.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTBookButton.h"
#import "DanishTheater.h"

@implementation DTBookButton

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title priceRange:(NSString *)priceRange currency:(NSString *)currency {
    self = [super init];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (NSAttributedString *)attributedText {
    if (!_title || !_priceRange) // edge case :: if priceRange (str) is free. currency don't matter no more, so don't make that part of the condition. !(|| !_currency)
        return nil;
    
    NSMutableString *mutStr = [NSMutableString stringWithFormat:@"%@\n%@", _title, _priceRange];
    if (_currency) {
        [mutStr appendString:@" "];
        [mutStr appendString:_currency];
    }
    
    // NSString *str = [NSString stringWithFormat:@"%@\n%@ %@", _title, _priceRange, _currency];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:mutStr attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSRange newlineRange = [mutStr rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} range:NSMakeRange(newlineRange.location + 1, mutStr.length - (newlineRange.location + 1))];
    }
    
    return mutAttrStr;
}

- (void)configure {
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    // [self setAttributedTitle:mutAttrStr forState:UIControlStateNormal];
    
    self.layer.backgroundColor = DTGlobalTintColor.CGColor; // self.tintColor.CGColor;
    self.layer.cornerRadius = 6.0;
    // self.layer.borderWidth = 1.0;
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Only change if necessary.
    if ( highlighted == super.highlighted ) {
        return;
    }
    
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.layer.backgroundColor = highlighted ? [DTGlobalTintColor colorWithAlphaComponent:.50].CGColor : DTGlobalTintColor.CGColor;
    }];
    
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize org = [super sizeThatFits:self.bounds.size];
    return CGSizeMake(org.width + 20, org.height - 2);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
