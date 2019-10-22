//
//  DTEventsSectionViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/24/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"

@import Firebase;

@interface DTEventsSectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

// new instance methods
- (instancetype)initWithEventsQuery:(FIRDatabaseQuery *)evQuery;
- (instancetype)initWithEventsReference:(FIRDatabaseReference *)evRef;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray <NSString *> *prefixedSubsectionTexts;
@property (nonatomic, strong) NSArray <FIRDatabaseReference *> *prefixedSubsectionEventReferences;

@property (nonatomic) DTTableViewCellStyle tableViewCellStyle; // defaults to cover.

@end
