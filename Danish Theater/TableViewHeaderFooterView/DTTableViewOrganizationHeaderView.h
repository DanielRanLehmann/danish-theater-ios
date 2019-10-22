//
//  DTTableViewOrganizationHeaderView.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"

@interface DTTableViewOrganizationHeaderView : UITableViewHeaderFooterView // needs a slight renaming as well.

@property (nonatomic, strong) UIToolbar *blurToolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *separatorLine;

@end
