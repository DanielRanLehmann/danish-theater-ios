//
//  DTLoadingTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/20/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTLoadingTableViewCell.h"
#import "DanishTheater.h"

CGFloat const DTLoadingTableViewCellRowHeight = 56.0;

#define HIDE_SEPARATOR_LEFT_INSET 1000

@interface DTLoadingTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTLoadingTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!_visibleSeparatorLine) {
      [self setSeparatorInset:UIEdgeInsetsMake(0, HIDE_SEPARATOR_LEFT_INSET, 0, 0)];
    }
    
    _primaryBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_primaryBtn.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]]; // or body?
    [self.contentView addSubview:_primaryBtn];
    
    /*
    _progress = [[MDProgress alloc] initWithFrame:CGRectZero];
    _progress.progressColor = DTGlobalTintColor;
    _progress.progressType = MDProgressTypeIndeterminate;
    
    [self.contentView addSubview:_progress];
    */
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.hidesWhenStopped = YES;
    
    [self.contentView addSubview:_activityView];
    
    [self startLoading]; // this is the default, now.
}

- (void)startLoading {
    _primaryBtn.hidden = YES;
    // _progress.hidden = NO;
     [_activityView startAnimating];
}

- (void)stopLoading {
    _primaryBtn.hidden = NO;
    // _progress.hidden = YES;
    [_activityView stopAnimating];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_primaryBtn autoPinEdgesToSuperviewMargins];
        
        //[_progress autoSetDimensionsToSize:CGSizeMake(22, 22)];
        // [_progress autoCenterInSuperview];
        
        [_activityView autoCenterInSuperviewMargins];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
