//
//  DTCreditsViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Accreditation.h"
#import "MDProgress.h"

@interface DTCreditsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithAccreditations:(NSArray <Accreditation *> *)accreditations;

@property (nonatomic, setter=setIncludeCountInHeader:) BOOL includeCountInHeader;

@property (nonatomic, readonly) NSArray <Accreditation *> *accreditations;
@property (nonatomic, strong) UITableView *tableView;

@end
