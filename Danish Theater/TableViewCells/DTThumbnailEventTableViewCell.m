//
//  DTThumbnailEventTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTThumbnailEventTableViewCell.h"

@interface DTThumbnailEventTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTThumbnailEventTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configure {
    _thumbnail = [[UIImageView alloc] initForAutoLayout];
    _thumbnail.clipsToBounds = TRUE;
    _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    _thumbnail.backgroundColor = [UIColor colorWithRed:(224/225.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    
    [self.contentView addSubview:_thumbnail];
}

#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_thumbnail autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        [_thumbnail autoSetDimensionsToSize:CGSizeMake(120, 65)];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
