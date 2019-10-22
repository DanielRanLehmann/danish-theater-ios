//
//  DTVenueTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import <MapKit/MapKit.h>

@interface DTVenueTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray <NSArray *> *contentDescriptions;

// @property (nonatomic, strong) MKMapView *thumbnailMapView;
@property (nonatomic, strong) UILabel *primaryTextLabel;
@property (nonatomic, strong) UIButton *moreButton; // target added: -getDirections:

@end
