//
//  DTVenueTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTVenueTableViewCell.h"

@interface DTVenueTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTVenueTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    /*
    _thumbnailMapView = [[MKMapView alloc] initForAutoLayout];
    _thumbnailMapView.mapType = MKMapTypeStandard;
    _thumbnailMapView.userInteractionEnabled = NO;
    _thumbnailMapView.layer.cornerRadius = 6.0f;
    
    [self.contentView addSubview:_thumbnailMapView];
    */
    
    _primaryTextLabel = [[UILabel alloc] initForAutoLayout];
    _primaryTextLabel.numberOfLines = 3;
    _primaryTextLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:_primaryTextLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_moreButton setImage:[[UIImage imageNamed:@"ic_arrow_up_right_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [self.contentView addSubview:_moreButton];
}

- (void)populateWithData {
    
    /*
    NSData *data = [content objectForKey:@"locationCoordinate"];
    CLLocationCoordinate2D coordinate;
    [data getBytes:&coordinate length:sizeof(coordinate)];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [_thumbnailMapView addAnnotation:annotation];
    
    MKCoordinateRegion region;
    region.center = coordinate;
    MKCoordinateSpan span;
    span.latitudeDelta = .0005;
    span.longitudeDelta = .0005;
    region.span = span;
    
    [_thumbnailMapView setRegion:region animated:NO];
    */
    
    
    NSString *str = [NSString stringWithFormat:@"%@\n%@", _title, [_contentDescriptions componentsJoinedByString:@"\n"]];
    
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSRange newlineRange = [str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline], NSForegroundColorAttributeName : [UIColor darkGrayColor]} range:NSMakeRange(newlineRange.location + 1, str.length - (newlineRange.location + 1))];
    }
    
    _primaryTextLabel.attributedText = mutAttrStr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populateWithData];
        
        /*
        [_thumbnailMapView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        [_thumbnailMapView autoSetDimensionsToSize:CGSizeMake(65, 65)];
        
        //[_thumbnailMapView autoPinEdgesToSuperviewEdges];
        */
        
        // [_primaryTextLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:_thumbnailMapView withOffset:8.0];
        // [_primaryTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_thumbnailMapView withOffset:-3.0]; // offset: account for label padding internally.
        
        // [_showLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        
        [_primaryTextLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeRight];
        
        [_moreButton autoPinEdgeToSuperviewMargin:ALEdgeRight];
        [_moreButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_primaryTextLabel];
        [_moreButton autoSetDimensionsToSize:CGSizeMake(36, 36)];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
