//
//  DTCalendarViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PureLayout.h"
#import "UIColor+ColorFromHexadecimal.h"
#import "Show.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "DTShowTableViewCell.h"
#import "UIImageView+TerebaImageView.h"
#import "NSString+FormatHelpers.h"
#import "DTEventDetailViewController.h"
#import "NSDate+Helpers.h"
#import "DTLoadingTableViewCell.h"

#import "DTMunicipalityPickerController.h"
#import "FIRDatabaseReference+ChildreCount.h"

#import <CoreLocation/CoreLocation.h>
#import "DTCalendarTableViewHeaderView.h"

#import "DTFavoritesViewController.h" 

#import "UIAlertController+Helpers.h"
#import "UIApplication+Reachability.h" 
#import "NSAttributedString+EmptyDataSet.h"
#import "DTEmptyDataSetStatesDefines.h"
#import "UIImage+Tint.h" 

@interface DTCalendarViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property DTEmptyDataSetState emptyDataSetState;

@end
