//
//  DTGenresDetailViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "DTTableViewCell.h" // for now just use the "thumbnail" style.
#import "UIScrollView+EmptyDataSet.h"
#import "Event.h" 

#import "NSString+FormatHelpers.h"
#import "DTEventDetailViewController.h"
#import "DTLoadingTableViewCell.h"
#import "MDProgress.h"
#import "UIAlertController+Helpers.h"
#import "UIApplication+Reachability.h"

#import "NSAttributedString+EmptyDataSet.h" 

#import "DTEmptyDataSetStatesDefines.h" 
#import "UIImage+Tint.h" 

@interface DTGenresDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIScrollViewDelegate>

@property (strong, nonatomic) NSString *genreDetailItem;
@property (nonatomic, strong) UITableView *tableView;

@end
