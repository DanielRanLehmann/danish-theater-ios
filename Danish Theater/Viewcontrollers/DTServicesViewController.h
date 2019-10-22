//
//  DTServicesViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "UIScrollView+EmptyDataSet.h"
#import "MDProgress.h"

@interface DTServicesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithServices:(NSArray <NSString *> *)services;
@property (nonatomic, setter=setIncludeCountInHeader:) BOOL includeCountInHeader;

@property (nonatomic, readonly) NSArray <NSString *> *services;
@property (nonatomic, strong) UITableView *tableView;

@end
