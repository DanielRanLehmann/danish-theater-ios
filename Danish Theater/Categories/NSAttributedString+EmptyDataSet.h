//
//  NSAttributedString+EmptyDataSet.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DanishTheater.h"

@interface NSAttributedString (EmptyDataSet)

// BARE BONES
+ (NSAttributedString *)attributedStringForEmptyDataSetWithTitle:(NSString *)aTitle;
+ (NSAttributedString *)attributedStringForEmptyDataSetWithDescription:(NSString *)aDescription;
+ (NSAttributedString *)attributedStringForEmptyDataSetWithButtonTitle:(NSString *)buttonTitle;

// OFFLINE STATE

+ (NSAttributedString *)offlineEmptyDataSetTitle;
+ (NSAttributedString *)offlineEmptyDataSetDescription;
+ (NSAttributedString *)offlineEmptyDataSetButtonTitle;

// EMPTY FAVORITES STATE
+ (NSAttributedString *)favoritesEmptyDataSetTitle;
+ (NSAttributedString *)favoritesEmptyDataSetDescription;

@end
