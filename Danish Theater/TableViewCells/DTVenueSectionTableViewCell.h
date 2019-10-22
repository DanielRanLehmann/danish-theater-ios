//
//  DTVenueSectionTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureLayout.h>
#import "Venue.h" // should be event-snippets, to reduce the load.
#import "DTVenueTableViewCell.h"
#import <UIScrollView+EmptyDataSet.h>
#import "UIImageView+TerebaImageView.h"

#import "NSString+FormatHelpers.h"

#import <MDProgress.h>

// no section protocol, because it doesn't do anything.
// what about making a VenueDetailVC? not a top priority.

@interface DTVenueSectionTableViewCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSLayoutConstraint *tableViewHeightConstraint; // deprecated a long time ago, right?

- (void)populateVenuesWithContents:(NSArray *)contents;

@end
