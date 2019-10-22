//
//  DTThumbnailEventTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureLayout.h>

@interface DTThumbnailEventTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *moreBtn;

@end
