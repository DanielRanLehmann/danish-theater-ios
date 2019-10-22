//
//  DTEventDetailViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "PureLayout.h"
#import "UIScrollView+EmptyDataSet.h"
#import "DTEventDetailTableViewHeaderView.h" // what a terrible name
#import "DTDescriptionTableViewCell.h"
#import "DTInformationTableViewCell.h" 
#import "DTSectionTableViewCell.h" 
#import "NSString+FormatHelpers.h"
#import "DTServicesViewController.h" 
#import "DTShowsViewController.h"
#import "DTCreditsViewController.h"
#import "Trailer.h"
#import "DTOrganizationDetailViewController.h"
#import "MDProgress.h"
#import "NSDate+Helpers.h"

#import "UIBarButtonItem+DTBackButtonItem.h" 

#import "UIAlertController+Helpers.h" 
#import "DTEmptyDataSetStatesDefines.h"

#import "DTOrganizationDetailViewController.h"

@interface DTEventDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, DTInformationTableViewCellDelegate, DTSectionTableViewCellDelegate, DTDescriptionTableViewCellDelegate>

- (instancetype)initWithCode:(NSString *)eventCode;

@property (nonatomic, readonly) NSString *eventCode;
@property (nonatomic, readonly) Event *event;

@property (nonatomic, strong) UITableView *tableView;

@property DTEmptyDataSetState emptyDataSetState;

@end
