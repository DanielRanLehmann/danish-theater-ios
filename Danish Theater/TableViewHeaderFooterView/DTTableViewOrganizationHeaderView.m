//
//  DTTableViewOrganizationHeaderView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTTableViewOrganizationHeaderView.h"

@interface DTTableViewOrganizationHeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTTableViewOrganizationHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    
    _blurToolbar = [[UIToolbar alloc] initForAutoLayout];
    _blurToolbar.translucent = YES;
    _blurToolbar.clipsToBounds = TRUE;
    
    [self.contentView addSubview:_blurToolbar];
    
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_UPCOMING", nil), NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_EVENTS", nil), NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_ABOUT", nil)]];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:_segmentedControl];
        [self.contentView bringSubviewToFront:_segmentedControl];
    }
    
    
    [self.contentView sendSubviewToBack:_blurToolbar];
    
    _separatorLine = [[UIView alloc] initForAutoLayout];
    _separatorLine.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(199/255.0) blue:(204/255.0) alpha:1.0];
    
    [self.contentView insertSubview:_separatorLine aboveSubview:_segmentedControl];
}

#pragma mark - Layout

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        
        [_blurToolbar autoPinEdgesToSuperviewEdges]; // this forces it to be 44.
        [_segmentedControl autoPinEdgesToSuperviewMargins];
        
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
