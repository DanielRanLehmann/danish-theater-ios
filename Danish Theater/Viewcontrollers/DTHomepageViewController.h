//
//  DTHomepageViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "DTTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Event.h"

#import "NSString+FormatHelpers.h"
#import "DTEventDetailViewController.h"
#import "FIRDatabaseReference+ChildreCount.h"
#import "DTLoadingTableViewCell.h"
#import "MDProgress.h"

#import "UIAlertController+Helpers.h"
#import "UIApplication+Reachability.h"
#import "NSAttributedString+EmptyDataSet.h" 

#import "UIImage+Tint.h" 
#import "DTEmptyDataSetStatesDefines.h"

@interface DTHomepageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property DTEmptyDataSetState emptyDataSetState;

@end
