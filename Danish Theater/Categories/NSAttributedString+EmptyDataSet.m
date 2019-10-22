//
//  NSAttributedString+EmptyDataSet.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "NSAttributedString+EmptyDataSet.h"

@implementation NSAttributedString (EmptyDataSet)

// BARE BONES
+ (NSAttributedString *)attributedStringForEmptyDataSetWithTitle:(NSString *)aTitle {
    
    NSString *text = aTitle;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (NSAttributedString *)attributedStringForEmptyDataSetWithDescription:(NSString *)aDescription {

    NSString *text = aDescription;
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (NSAttributedString *)attributedStringForEmptyDataSetWithButtonTitle:(NSString *)buttonTitle {
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f], NSForegroundColorAttributeName : DTGlobalTintColor}; // DTPrimaryColor()
    return [[NSAttributedString alloc] initWithString:buttonTitle attributes:attributes];
}

// OFFLINE STATE

+ (NSAttributedString *)offlineEmptyDataSetTitle {
    return [NSAttributedString attributedStringForEmptyDataSetWithTitle:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_TITLE", nil)];
}

+ (NSAttributedString *)offlineEmptyDataSetDescription {
    return [NSAttributedString attributedStringForEmptyDataSetWithDescription:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_DESCRIPTION_TEXT", nil)];
}

+ (NSAttributedString *)offlineEmptyDataSetButtonTitle {
    return [NSAttributedString attributedStringForEmptyDataSetWithButtonTitle:@"Try Again"];
}

// EMPTY FAVORITES STATE
+ (NSAttributedString *)favoritesEmptyDataSetTitle {
    return [NSAttributedString attributedStringForEmptyDataSetWithTitle:NSLocalizedString(@"FAVORITES_EMPTY_DATA_SET_TITLE", nil)];
}

+ (NSAttributedString *)favoritesEmptyDataSetDescription {
    return [NSAttributedString attributedStringForEmptyDataSetWithDescription:@"All your favorite events will be saved here."];
}

@end
