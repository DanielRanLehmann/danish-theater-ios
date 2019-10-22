//
//  DTShowsViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"
#import "Event.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PureLayout.h"
#import "DTShowTableViewCell.h"
#import "NSString+FormatHelpers.h"

#import "DTLoadingTableViewCell.h" 

#import "UIAlertController+Helpers.h" 

#import "UIApplication+Reachability.h"
#import "NSAttributedString+EmptyDataSet.h"
#import "UIAlertController+Helpers.h" 

#import "DTCalendarTableViewHeaderView.h"

@interface DTShowsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIScrollViewDelegate>

// differentiate between eventCode and organizationCode.
// should support both.

- (instancetype)initWithEventCode:(NSString *)eventCode;
- (instancetype)initWithOrganizationCode:(NSString *)organizationCode;

@property (nonatomic, strong) UITableView *tableView;

@end
