//
//  UIBarButtonItem+DTBackButtonItem.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/7/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UIBarButtonItem+DTBackButtonItem.h"

@implementation UIBarButtonItem (DTBackButtonItem)

+ (UIBarButtonItem *)backItem {
    
    UIBarButtonItem *item =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK_ITEM_TITLE", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    return item;
}

@end
