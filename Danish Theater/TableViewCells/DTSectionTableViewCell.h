//
//  DTSectionTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/25/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "Event.h" // should be event-snippets, to reduce the load.
#import "UIScrollView+EmptyDataSet.h"
#import "UIImageView+TerebaImageView.h"

#import "NSString+FormatHelpers.h"
#import "DTLoadingTableViewCell.h"

#import "FIRDatabaseReference+ChildreCount.h"

#import "DTTableViewCell.h"

@class DTSectionTableViewCell;
@protocol DTSectionTableViewCellDelegate <NSObject>

@optional
- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSnippetWithIndexPath:(NSIndexPath *)indexPath;
- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSecondaryButtonWithIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectSeeMoreWithSectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell;

@end

@interface DTSectionTableViewCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource> 

/*
@property NSUInteger totalNumberOfEventSnippets;
@property NSUInteger allowedNumberOfQueries; // defaults to 2, including the first initial batch query.
@property NSUInteger executedQueries; // defaults to 0
@property NSUInteger queryLimit; // defaults to 10
*/

@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) NSString *headerSubtitle;

@property (nonatomic, strong) NSArray *items; // passing null at this stage, so don't class restrict the array.
- (void)setItems:(NSArray *)items ofModelClass:(Class)modelClass;

@property (nonatomic, strong) UILabel *headerTextLabel;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id <DTSectionTableViewCellDelegate> delegate;

@property (nonatomic, copy) NSString *seeMoreText;
@property (nonatomic) BOOL showsSeeMoreItem; // defaults to false

@end
