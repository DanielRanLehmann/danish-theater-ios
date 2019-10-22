//
//  DTOrganizationDetailTableHeaderView.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"

@interface DTOrganizationDetailTableHeaderView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *separatorLine;

- (NSAttributedString *)attributedStringWithTitleText:(NSString *)titleText detailText:(NSString *)detailText;

@end
