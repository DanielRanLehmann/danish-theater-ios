//
//  DTSearchViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Organization.h" 
#import "PureLayout.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "DTTableViewCell.h"
#import "DTEventDetailViewController.h"
#import "NSString+FormatHelpers.h"
#import "MDProgress.h"

#import "DanishTheater.h" 
#import "UIApplication+Reachability.h" 
#import "NSAttributedString+EmptyDataSet.h" 
#import "UIImage+Tint.h" 


#import "SearchItem.h" 

typedef enum : NSUInteger {
    DTSearchEmptyDataSetStateInitial,
    DTSearchEmptyDataSetStateOffline,
    DTSearchEmptyDataSetStateNoResultsFound,
    DTSearchEmptyDataSetStateLoading
} DTSearchEmptyDataSetStates;

@interface DTSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView; // rename searchResultsTableView;

@property (nonatomic, strong) UITableView *trendingTableView;

@property (nonatomic, strong) UISearchBar *searchBar;

@end
