//
//  DTShowTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTShowTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

CGFloat const DTShowTableViewCellRowHeight = 87.0;

#define INTERNAL_LABEL_PADDING 3

@interface DTShowTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTShowTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    // ONLY SUPPORT THE SLIM TYPE FOR NOW.
    _type = DTShowTableViewCellTypeBlurredThumbnail;
    
    _thumbnailView = [[DTThumbnailView alloc] initForAutoLayout];
    [self.contentView addSubview:_thumbnailView];
    
    _showLabel = [[UILabel alloc] initForAutoLayout];
    _showLabel.numberOfLines = 0;
    _showLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:_showLabel];
    
    _moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_moreBtn setImage:[[UIImage imageNamed:@"ic_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_moreBtn setImageEdgeInsets:UIEdgeInsetsMake((44 - 5) / 2, 44 - 19, (44 - 5) / 2, 0)];
    
    [self.contentView addSubview:_moreBtn];
}

- (void)prepareForReuse {
    // [super prepareForReuse];
    
    _thumbnailView = nil;
    _showLabel.text = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)populateWithData {
    
    if (!_placeholderState) {
        
        _thumbnailView.date = _date;
        _thumbnailView.textLabel.attributedText = [_thumbnailView attributedText];
        
        _thumbnailView.shimmeringView.shimmering = NO;
        
        [_imageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (!error) {
                [_thumbnailView.imageView sd_setImageWithURL:URL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (!error) {
                        [_thumbnailView.imageView setImage:[image blurredImageWithRadius:3 iterations:6 tintColor:[UIColor clearColor]]];
                    }
                }];
                 
                
            } else {
                // oops an error occured.
            }
            
             _thumbnailView.shimmeringView.shimmering = NO;
        }];
    }
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", _titleText, [_contentDescriptions componentsJoinedByString:@"\n"]];
    
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSRange newlineRange = [str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        
        // Line break mode doesn't work.
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        [mutAttrStr addAttributes:@{NSParagraphStyleAttributeName : paragrahStyle, NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSForegroundColorAttributeName : [UIColor colorWithHex:@"#8e8e93"]} range:NSMakeRange(newlineRange.location + 1, str.length - (newlineRange.location + 1))];
    }
    
    _showLabel.attributedText = mutAttrStr;
    
}

- (NSUInteger)numberOfLines {
    
    NSInteger lineCount = 0;
    CGSize textSize = CGSizeMake(_showLabel.frame.size.width, MAXFLOAT);
    int rHeight = lroundf([_showLabel sizeThatFits:textSize].height);
    int charSize = lroundf(_showLabel.font.lineHeight);
    lineCount = rHeight/charSize;
    
    return lineCount;
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populateWithData];
        
        [_thumbnailView autoPinEdgeToSuperviewMargin:ALEdgeTop];
        [_thumbnailView autoPinEdgeToSuperviewMargin:ALEdgeLeft];
        
        
        // [_thumbnailView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        [_thumbnailView autoSetDimensionsToSize:CGSizeMake(65, 65)];
        
        [_showLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_thumbnailView withOffset:8.0];
        [_showLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_thumbnailView withOffset:-INTERNAL_LABEL_PADDING]; // offset: account for label padding internally.
        
        // [_showLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        
        [_moreBtn autoPinEdgeToSuperviewMargin:ALEdgeRight];
        [_moreBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_thumbnailView]; // or showlabel?
        [_moreBtn autoSetDimensionsToSize:CGSizeMake(44, 44)];
        
        [_showLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_moreBtn withOffset:-2.0f]; // negative not positive
        
        //[_showLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_thumbnailView];
        
        
        [_thumbnailView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_showLabel];
        
        [_showLabel autoPinEdgeToSuperviewMargin:ALEdgeBottom];
        
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
