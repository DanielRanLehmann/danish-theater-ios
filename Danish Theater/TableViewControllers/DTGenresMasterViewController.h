//
//  DTGenresMasterViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "MDProgress.h"
#import "UIApplication+Reachability.h"
#import "DanishTheater.h"
#import "NSAttributedString+EmptyDataSet.h"

#import "DTEmptyDataSetStatesDefines.h"
#import "UIImage+Tint.h" 

@class DTGenresDetailViewController;

@interface DTGenresMasterViewController : UITableViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) DTGenresDetailViewController *detailViewController;
@property DTEmptyDataSetState emptyDataSetState;

@end
