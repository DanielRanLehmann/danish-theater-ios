//
//  DTKidsViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/12/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "UIColor+ColorFromHexadecimal.h" 
#import "DTSectionTableViewCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "UIImageView+TerebaImageView.h"
#import "Event.h"
#import "DTEventDetailViewController.h" 

#import "DTEventsSectionViewController.h"
//#import "DTSectionDetailViewController.h"

#import "MDProgress.h"
#import "UIAlertController+Helpers.h" 

#import "DanishTheater.h"
#import "UIApplication+Reachability.h" 
#import "NSAttributedString+EmptyDataSet.h"
#import "DTEmptyDataSetStatesDefines.h"
#import "UIImage+Tint.h" 

@interface DTKidsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, DTSectionTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property DTEmptyDataSetState emptyDataSetState;

@end
