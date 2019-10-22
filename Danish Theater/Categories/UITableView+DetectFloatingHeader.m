//
//  UITableView+DetectFloatingHeader.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 11/15/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UITableView+DetectFloatingHeader.h"

@implementation UITableView (DetectFloatingHeader)

- (BOOL)isFloatingSectionHeaderView:(UITableViewHeaderFooterView *)view {
    NSNumber *section = [self sectionForHeaderFooterView:view];
    return [self isFloatingHeaderInSection:section.integerValue];
}

- (BOOL)isFloatingHeaderInSection:(NSInteger)section {
    CGRect frame = [self rectForHeaderInSection:section];
    CGFloat y = self.contentInset.top + self.contentOffset.y;
    return y > frame.origin.y;
}

- (NSNumber *)sectionForHeaderFooterView:(UITableViewHeaderFooterView *)view {
    for (NSInteger i = 0; i < [self numberOfSections]; i++) {
        CGPoint a = [self convertPoint:CGPointZero fromView:[self headerViewForSection:i]];
        CGPoint b = [self convertPoint:CGPointZero fromView:view];
        if (a.y == b.y) {
            return @(i);
        }
    }
    return nil;
}

@end
