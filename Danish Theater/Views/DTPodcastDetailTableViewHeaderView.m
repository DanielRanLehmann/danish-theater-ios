//
//  DTPodcastDetailTableViewHeaderView.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/19/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTPodcastDetailTableViewHeaderView.h"
#import "UIImageView+AFNetworking.h"

@interface DTPodcastDetailTableViewHeaderView ()

@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTPodcastDetailTableViewHeaderView

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
    _imageView.layer.cornerRadius = 6.0f;
    _imageView.clipsToBounds = true;
    
    [self addSubview:_imageView];
    
    _textLabel = [[UILabel alloc] initForAutoLayout];
    _textLabel.lineBreakMode = NSLineBreakByClipping;
    _textLabel.numberOfLines = 0;
    _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    
    _textLabel.text = @"placeholder text";
    
    [self addSubview:_textLabel];
    
    _separatorLine = [[UIView alloc] init];
    _separatorLine.hidden = YES;
    _separatorLine.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(199/255.0) blue:(204/255.0) alpha:1.0];
    
    [self addSubview:_separatorLine];
}

- (void)populateWithData {
    
    //[_imageView setImageWithURL:_imageURL];
    
    // _title = @"Copenhagen";
    // _detailText = @"Capital";
    
    /*
    if (_detailText) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", _title, _detailText] attributes:@{NSFontAttributeName : _textLabel.font, NSForegroundColorAttributeName: _textLabel.textColor}];
        
        NSRange newlineRange = [[attrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        if (newlineRange.location != NSNotFound) {
            
            // NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
            [attrStr addAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} range:NSMakeRange(newlineRange.location, [attrStr string].length - newlineRange.location)];
        }
        
        [_textLabel setAttributedText:attrStr];
        
    } else {
        [_textLabel setText:_title];
    }
    */
    
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populateWithData];
        
        [_imageView autoSetDimensionsToSize:CGSizeMake(140, 140)];
        //[_imageView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        [_imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(16, 16, 16, 0) excludingEdge:ALEdgeRight];
        
        [_textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_imageView withOffset:12.0];
        [_textLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_imageView];
        
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
