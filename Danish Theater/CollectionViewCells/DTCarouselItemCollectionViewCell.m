//
//  DTCarouselItemCollectionViewCell.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/18/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCarouselItemCollectionViewCell.h"
#import "PureLayout.h"

@interface DTCarouselItemCollectionViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end


@implementation DTCarouselItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    _imageView = [[UIImageView alloc] initForAutoLayout];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.masksToBounds = true;
    _imageView.layer.cornerRadius = 6.0f; 
    [self.contentView addSubview:_imageView];
    
    _captionLabel = [[UILabel alloc] initForAutoLayout];
    _captionLabel.numberOfLines = 1;
    _captionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _captionLabel.textColor = [UIColor blackColor];
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_captionLabel];
    
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_imageView autoSetDimensionsToSize:CGSizeMake(94, 142)]; // 187, 284
        [_imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        
        //[_captionLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
        [_captionLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [_captionLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_imageView withOffset:8];
        [_captionLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:_captionLabel];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


@end
