//
//  DTBookButton.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTBookButton : UIButton

- (instancetype)initWithTitle:(NSString *)title priceRange:(NSString *)priceRange currency:(NSString *)currency;

@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSString *priceRange;
@property (nonatomic, strong) NSString *currency;

- (NSAttributedString *)attributedText;

@end
