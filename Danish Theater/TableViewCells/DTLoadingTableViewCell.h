//
//  DTLoadingTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/20/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "MDProgress.h"

FOUNDATION_EXPORT CGFloat const DTLoadingTableViewCellRowHeight;

@interface DTLoadingTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *primaryBtn;
// @property (nonatomic, strong) MDProgress *progress;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property BOOL visibleSeparatorLine; // deafults to false.

- (void)startLoading;
- (void)stopLoading;

@end
