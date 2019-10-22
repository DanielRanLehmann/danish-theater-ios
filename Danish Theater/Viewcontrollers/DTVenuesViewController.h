//
//  DTVenuesViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureLayout.h>
#import "DTVenueTableViewCell.h" 
#import <UIScrollView+EmptyDataSet.h>
#import "Venue.h"
#import <MDProgress.h>

@interface DTVenuesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

- (instancetype)initWithCodes:(NSArray <NSString *> *)venueCodes;
@property (nonatomic, readonly) NSArray <NSString *> *venueCodes;

@property (nonatomic, strong) NSMutableArray <Venue *> *venues;

@property (nonatomic, strong) UITableView *tableView;

@end
