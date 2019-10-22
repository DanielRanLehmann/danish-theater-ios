//
//  DTEventDetailTableViewHeaderView.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "DTBookButton.h"
#import "FBShimmeringView.h"
#import "AYVibrantButton.h"


@interface DTEventDetailTableViewHeaderView : UIView

@property (nonatomic, strong) FBShimmeringView *shimmeringView;
@property (nonatomic, strong) UIImageView *imageView;
// include a play button on top of the imageView.

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *organizationBtn;

@property (nonnull, strong) DTBookButton *bookBtn;

@property (nonatomic, strong) UIVisualEffectView *playButtonEffectView;
@property (nonatomic, strong) AYVibrantButton *playButton;

@property (nonatomic, strong) UIView *separatorLine;

// and a separator fixed to the bottom.

@end
