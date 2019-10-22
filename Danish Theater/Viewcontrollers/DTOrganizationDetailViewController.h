//
//  DTOrganizationDetailViewController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/13/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FXBlurView.h"
#import "Organization.h"
#import "UIColor+ColorFromHexadecimal.h"
#import "UIImageView+AFNetworking.h"

#import "DTTableViewCell.h"
#import "DTLoadingTableViewCell.h" 
#import "DTCalendarTableViewHeaderView.h" 

#import "UIImageView+TerebaImageView.h" 
#import "PureLayout.h"

#import "DTInformationTableViewCell.h" 
#import "DTDescriptionTableViewCell.h"

#import "DTEventDetailViewController.h"

#import "UIScrollView+EmptyDataSet.h"
#import "UIApplication+Reachability.h" 
#import "DTEmptyDataSetStatesDefines.h"
#import "NSAttributedString+EmptyDataSet.h" 

#import "UIImageView+TextProtection.h" 

#import "UIImage+Tint.h" 

@interface DTOrganizationDetailViewController : UIViewController <DTDescriptionTableViewCellDelegate, DTInformationTableViewCellDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UITableViewDelegate, UITableViewDataSource, UIBarPositioningDelegate>

- (instancetype)initWithCode:(NSString *)organizationCode;
@property (strong, nonatomic) NSString *organizationCode;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIToolbar *blurToolbar;
@property (nonatomic, strong) UIView *separatorLine;

@end
