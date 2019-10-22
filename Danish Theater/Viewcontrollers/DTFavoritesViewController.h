//
//  DTFavoritesViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
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

#import "UIApplication+Reachability.h" 
#import "NSAttributedString+EmptyDataSet.h" 
#import "UIImage+Tint.h" 
#import "DTEmptyDataSetStatesDefines.h"

typedef void (^DTFavoritesCompletion)(BOOL cancelled, NSString *selectedEventCode);

@interface DTFavoritesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, UIScrollViewDelegate>

@property (nonatomic, strong) DTFavoritesCompletion completion;
@property (nonatomic, strong) UITableView *tableView;
@property DTEmptyDataSetState emptyDataSetState;

@end
