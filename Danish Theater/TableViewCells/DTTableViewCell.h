//
//  DTTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/24/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "PureLayout.h"
#import "UIColor+ColorFromHexadecimal.h" 
#import "FBShimmeringView.h"

@import Firebase;

FOUNDATION_EXPORT CGFloat DTTableViewCellStyleThumbnailRowHeight();
FOUNDATION_EXPORT CGFloat DTTableViewCellStyleCoverRowHeight();

typedef enum : NSUInteger {
    DTTableViewCellStyleThumbnail,
    DTTableViewCellStyleCover
} DTTableViewCellStyle;

@interface DTTableViewCell : UITableViewCell

@property (nonatomic, strong) FIRStorageReference *imageRef;
@property (nonatomic, strong) NSURL *fallbackImageURL; 

// BRAND NEW
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UILabel *captionLabel;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSAttributedString *attributedTitle; // used for searchVC mainly.

@property (nonatomic, strong) NSArray <NSString *> *contentDescriptions;

// uses imageView and textLabel to populate.
@property (nonatomic, readonly) FBShimmeringView *shimmeringView;

@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UILabel *primaryTextLabel;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic) DTTableViewCellStyle style;

- (NSDictionary *)defaultTitleAttributes;
- (NSDictionary *)defaultDescriptionAttributes;

- (void)cellInTableView:(UITableView *)tableView didScrollOnView:(UIView *)view; 

@end
