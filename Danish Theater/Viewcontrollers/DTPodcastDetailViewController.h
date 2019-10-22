//
//  DTPodcastDetailViewController.h
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/19/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"

@interface DTPodcastDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (instancetype)initWithPodcastId:(NSString *)podcastId;

@property (nonatomic, strong) UITableView *tableView;

@end
