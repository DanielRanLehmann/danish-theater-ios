//
//  UITableView+DetectFloatingHeader.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 11/15/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DetectFloatingHeader)

- (BOOL)isFloatingSectionHeaderView:(UITableViewHeaderFooterView *)view; 
- (BOOL)isFloatingHeaderInSection:(NSInteger)section;
- (NSNumber *)sectionForHeaderFooterView:(UITableViewHeaderFooterView *)view;

@end
