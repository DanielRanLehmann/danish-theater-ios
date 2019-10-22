//
//  DTEventDetailTableViewHeaderView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTEventDetailTableViewHeaderView.h"

@interface DTEventDetailTableViewHeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTEventDetailTableViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _shimmeringView = [[FBShimmeringView alloc] init];
    _shimmeringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_shimmeringView];
    
    _imageView = [[UIImageView alloc] initForAutoLayout];
    _imageView.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = true;
    
    [_shimmeringView setContentView:_imageView];
    
    _playButtonEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    
    _playButtonEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _playButtonEffectView.clipsToBounds = true;
    _playButtonEffectView.layer.cornerRadius = roundf(40/2.0f);
    
    _playButtonEffectView.frame = CGRectZero;
    [self addSubview:_playButtonEffectView];
    
    _playButton = [[AYVibrantButton alloc] initWithFrame:CGRectZero style:AYVibrantButtonStyleFill];
    _playButton.translatesAutoresizingMaskIntoConstraints = NO;
    _playButton.vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _playButton.icon = [[UIImage imageNamed:@"ic_play_circle_filled_48pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [_playButtonEffectView.contentView addSubview:_playButton];
    
    _titleLabel = [[UILabel alloc] initForAutoLayout];
    _titleLabel.lineBreakMode = NSLineBreakByClipping;
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    
    _titleLabel.text = @"Event Title";
    
    [self addSubview:_titleLabel];
    
    _organizationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _organizationBtn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [_organizationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_organizationBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_organizationBtn setTitle:@"Theater" forState:UIControlStateNormal];
    
    [_organizationBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [self addSubview:_organizationBtn];
    
    _bookBtn = [[DTBookButton alloc] init];
    [self addSubview:_bookBtn];
    
    _separatorLine = [[UIView alloc] init];
    _separatorLine.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(199/255.0) blue:(204/255.0) alpha:1.0];
    
    [self addSubview:_separatorLine];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_shimmeringView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [_shimmeringView autoSetDimensionsToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / (1024 / 539.0))];
        [_imageView autoPinEdgesToSuperviewEdges];
        
        [_playButtonEffectView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_shimmeringView withOffset:-15];
        [_playButtonEffectView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_shimmeringView withOffset:-15];
        [_playButtonEffectView autoSetDimensionsToSize:CGSizeMake(40, 40)];
        
        [_playButton autoPinEdgesToSuperviewEdges];
        
        [_bookBtn autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(16, 16, 16, 16) excludingEdge:ALEdgeTop]; // wrong place to put it?
        [_bookBtn autoSetDimensionsToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - (2 * 16), 47)];
        
        [_titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_shimmeringView withOffset:16];
      
        [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        
        [_organizationBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:0];
        [_organizationBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:16];
        
        if ([_organizationBtn.titleLabel intrinsicContentSize].width >= [UIScreen mainScreen].bounds.size.width - 15) {
            [_organizationBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:16];
        }
        
        [_organizationBtn autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:_bookBtn withOffset:-16.0];
        
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
