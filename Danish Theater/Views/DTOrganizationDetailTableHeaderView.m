//
//  DTOrganizationDetailTableHeaderView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTOrganizationDetailTableHeaderView.h"

@interface DTOrganizationDetailTableHeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end


@implementation DTOrganizationDetailTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _imageView = [[UIImageView alloc] initForAutoLayout];
    _imageView.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    
    [self addSubview:_imageView];
    
    _titleLabel = [[UILabel alloc] initForAutoLayout];
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:_titleLabel];
    
    _separatorLine = [[UIView alloc] init];
    _separatorLine.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(199/255.0) blue:(204/255.0) alpha:1.0];
    _separatorLine.hidden = YES;
    
    [self addSubview:_separatorLine];

}

- (NSAttributedString *)attributedStringWithTitleText:(NSString *)titleText detailText:(NSString *)detailText {
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", titleText, detailText] attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSRange newlineRange = [[mutAttrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName : [UIColor lightGrayColor]} range:NSMakeRange(newlineRange.location, [mutAttrStr string].length - newlineRange.location)];
    }
        
    return mutAttrStr;
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [_imageView autoSetDimensionsToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, /*[UIScreen mainScreen].bounds.size.width / (16/9.0))*/ ([UIScreen mainScreen].bounds.size.width / (375 / 88.0))  /*+ (44 + 20)*/)];
        
        [_titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_imageView withOffset:16];
        [_titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(16, 16, 16, 16) excludingEdge:ALEdgeTop];
        
        [_separatorLine autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [_separatorLine autoSetDimension:ALDimensionHeight toSize:.5];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
