//
//  DTCalendarTableViewHeaderView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCalendarTableViewHeaderView.h"

@interface DTCalendarTableViewHeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTCalendarTableViewHeaderView

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

#pragma mark - Configure & Reuse
- (void)configure {
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _blurToolbar = [[UIToolbar alloc] initForAutoLayout];
    _blurToolbar.translucent = YES;
    _blurToolbar.clipsToBounds = TRUE;
    
    // [self removeHairlineFromToolbar:_blurToolbar];
    
    [self.contentView addSubview:_blurToolbar];
    // [self.contentView bringSubviewToFront:self.textLabel]; // not sure if that's going to work.
    
    /*
    _dateLabel = [[UILabel alloc] initForAutoLayout];
    _dateLabel.font = [UIFont boldSystemFontOfSize:15]; // 14 or 15, because it incl. lower case letters. (if all upper case then possibly 13pt.)
    _dateLabel.textAlignment = NSTextAlignmentLeft;
    _dateLabel.numberOfLines = 1;
    _dateLabel.textColor = [MDColor blueGrey:400];
    
    // add a clear all button to the right.
    
    [self.contentView addSubview:_dateLabel];
    
    [self.contentView bringSubviewToFront:_dateLabel];
    */
    
    [self.contentView sendSubviewToBack:_blurToolbar];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // _dateLabel.text = nil;
}

#pragma mark - Layout

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        
        [_blurToolbar autoPinEdgesToSuperviewEdges]; // this forces it to be 44.
        // [_dateLabel autoPinEdgesToSuperviewMargins];
        
        [_blurToolbar autoSetDimension:ALDimensionHeight toSize:self.textLabel.bounds.size.height + (2 * 15)];
        
        
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
