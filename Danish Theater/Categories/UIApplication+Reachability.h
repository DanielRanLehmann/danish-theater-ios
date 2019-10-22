//
//  UIApplication+Reachability.h
//  Theatre
//
//  Created by Daniel Ran Lehmann on 11/8/16.
//  Copyright © 2016 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface UIApplication (Reachability)

- (BOOL)isOnline;
- (BOOL)isOffline;

@end
