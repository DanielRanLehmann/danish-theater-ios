//
//  DTTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTTableViewCell.h"
#import "DanishTheater.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define __IS_IPHONE_SE__ ([UIScreen mainScreen].bounds.size.width == 320)
#define __IS_IPHONE_7__ ([UIScreen mainScreen].bounds.size.width == 375)
#define __IS_IPHONE_7_PLUS__ ([UIScreen mainScreen].bounds.size.width == 414)

CGFloat DTTableViewCellStyleThumbnailRowHeight() {
    CGFloat rowHeight = 0;
    if (__IS_IPHONE_SE__) {
        rowHeight = 84.5;
    } else if (__IS_IPHONE_7__) {
        rowHeight = 95.0;
    } else if (__IS_IPHONE_7_PLUS__) {
        rowHeight = 102.66666666666667;
    }
    
    return rowHeight;
}

CGFloat DTTableViewCellStyleCoverRowHeight() {
    CGFloat rowHeight = 0;
    if (__IS_IPHONE_SE__) {
        rowHeight = 225.0;
    } else if (__IS_IPHONE_7__) {
        rowHeight = 270.0;
    } else if (__IS_IPHONE_7_PLUS__) {
        rowHeight = 274.66666666666663;
    }
    
    return rowHeight;
}

@interface DTTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, assign) BOOL didShimmerOnce;
- (void)populateWithData;

@end

@implementation DTTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

/*
- (instancetype)initWithStyle:(DTTableViewCellStyle)style {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _style = style;
        [self configure];
    }
    
    return self;
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    if (!_style) {
        _style = DTTableViewCellStyleCover; // defaults to this.
    }
    
    _shimmeringView = [[FBShimmeringView alloc] init];
    
    _shimmeringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_shimmeringView];
    
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _contentImageView.clipsToBounds = TRUE;
    _contentImageView.layer.masksToBounds = TRUE;
    
    _contentImageView.layer.cornerRadius = 6.0;
    
    _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    _contentImageView.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    _contentImageView.layer.borderWidth = .5;
    _contentImageView.layer.borderColor = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0].CGColor;
    
    [_shimmeringView setContentView:_contentImageView];
    
    _primaryTextLabel = [[UILabel alloc] initForAutoLayout];
    _primaryTextLabel.numberOfLines = 3;
    _primaryTextLabel.textAlignment = NSTextAlignmentLeft;
    _primaryTextLabel.lineBreakMode = NSLineBreakByClipping;

    [self.contentView addSubview:_primaryTextLabel];
    
    _captionLabel = [[UILabel alloc] initForAutoLayout];
    _captionLabel.numberOfLines = 1;
    
    _captionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]; // not final EDIT FONT HERE.
    _captionLabel.textColor = DTGlobalTintColor; // not yet final.
    
    _captionLabel.textAlignment = NSTextAlignmentLeft;
    _captionLabel.lineBreakMode = NSLineBreakByClipping;
    
    [self.contentView addSubview:_captionLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_moreButton setImage:[[UIImage imageNamed:@"ic_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake((44 - 5) / 2, 44 - 19, (44 - 5) / 2, 0)];
    
    [self.contentView addSubview:_moreButton];
}

- (NSDictionary *)defaultTitleAttributes {
    return @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSForegroundColorAttributeName : [UIColor blackColor]};
}

- (NSDictionary *)defaultDescriptionAttributes {
    return @{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]/* if two lines [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]*/, NSForegroundColorAttributeName : [UIColor colorWithHex:@"#8e8e93"]};
}

- (void)populate {
    
    if (!_didShimmerOnce) {
        _shimmeringView.shimmering = NO;
    }
    
    if (_imageRef) {
        [_imageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (!error) {
                [_contentImageView sd_setImageWithURL:URL];
                
            } else {
               // oops an error occured.
            }
            
            _shimmeringView.shimmering = NO;
        }];
    }
    
    NSMutableAttributedString *mutAttrStr = nil;
    NSString *contentDescriptionStr = [_contentDescriptions componentsJoinedByString:@"\n"];
    
    if (_attributedTitle) {
        mutAttrStr = [[NSMutableAttributedString alloc] initWithAttributedString:_attributedTitle];
        [mutAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", contentDescriptionStr] attributes:nil]];
    
    } else {
        NSString *str = [NSString stringWithFormat:@"%@\n%@", _title, contentDescriptionStr];
        mutAttrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:[self defaultTitleAttributes]];
    }
    
    NSRange newlineRange = [[mutAttrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:[self defaultDescriptionAttributes] range:NSMakeRange(newlineRange.location + 1, [mutAttrStr string].length - (newlineRange.location + 1))];
    }
    
    
    _primaryTextLabel.attributedText = mutAttrStr;
    _primaryTextLabel.numberOfLines = 3;
    //_primaryTextLabel.adjustsFontSizeToFitWidth = YES;
    // _primaryTextLabel.minimumScaleFactor = 0.85;
    
    _captionLabel.text = _caption.uppercaseString;
}

// parallax effect during scroll.
- (void)cellInTableView:(UITableView *)tableView didScrollOnView:(UIView *)view
{
    CGRect rectInSuperview = [tableView convertRect:self.frame toView:view];
    
    float distanceFromCenter = CGRectGetHeight(view.frame)/2 - CGRectGetMinY(rectInSuperview);
    float difference = CGRectGetHeight(_contentImageView.frame) - CGRectGetHeight(self.frame);
    float move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference;
    
    CGRect imageRect = _contentImageView.frame;
    imageRect.origin.y = -(difference/2)+move;
    _contentImageView.frame = imageRect;
}

#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populate];
        
        if (_style == DTTableViewCellStyleCover) {
            
            if (_caption) {
                [_captionLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
                
                [_shimmeringView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_captionLabel withOffset:8.0]; // offset not yet clear.
                [_shimmeringView autoPinEdgeToSuperviewMargin:ALEdgeLeft];
                [_shimmeringView autoPinEdgeToSuperviewMargin:ALEdgeRight];
            
            } else {
                [_shimmeringView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
            }
            
            [_shimmeringView autoSetDimensionsToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (2 * 16), ([UIScreen mainScreen].bounds.size.width - (2 * 16)) / (1024/539.0))];
            [_contentImageView autoPinEdgesToSuperviewEdges];
            
            [_moreButton autoPinEdgeToSuperviewMargin:ALEdgeRight];
            [_moreButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_primaryTextLabel];
            [_moreButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
            
            [_primaryTextLabel autoPinEdgeToSuperviewMargin:ALEdgeLeft];
            [_primaryTextLabel autoPinEdgeToSuperviewMargin:ALEdgeBottom];
            [_primaryTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_shimmeringView withOffset:13.5f];
            [_primaryTextLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_moreButton withOffset:-2.0];
        }
        
        else { // DTTableViewCellStyleThumbnail
            [_shimmeringView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
            
            CGFloat width = [UIScreen mainScreen].bounds.size.width / (375/139.0);
            CGFloat height = width/(139/73.0);
            
            [_shimmeringView autoSetDimensionsToSize:CGSizeMake(width, height)];
            [_contentImageView autoPinEdgesToSuperviewEdges];
            
            [_moreButton autoPinEdgeToSuperviewMargin:ALEdgeRight];
            [_moreButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_shimmeringView];
            [_moreButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
            
            [_primaryTextLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_shimmeringView withOffset:8.0];
            [_primaryTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_shimmeringView withOffset:-3.0]; // offset: account for label padding internally.
            
            [_primaryTextLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_moreButton withOffset:-2.0];
        }
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

/*
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithHex:@"#FAFAFA"];
    }
    
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = [UIColor colorWithHex:@"#FAFAFA"];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}
*/

@end
