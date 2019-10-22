//
//  DTSearchResultsViewController.h
//  DTSearchTest
//
//  Created by Daniel Ran Lehmann on 11/16/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DTSearchResultType) {
    DTSearchResultTypeEvent,
    DTSearchResultTypeOrganization
};

@interface DTSearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithQueryText:(NSString *)queryText resultType:(DTSearchResultType)searchResultType;

@property (nonatomic, strong) UITableView *tableView;
@property (readonly) DTSearchResultType searchResultType;
@property (readonly) NSString *queryText;

@end
