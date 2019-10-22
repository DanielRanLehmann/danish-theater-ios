//
//  DTShowTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "DTThumbnailView.h" 

@import Firebase;

FOUNDATION_EXPORT CGFloat const DTShowTableViewCellRowHeight;

typedef enum : NSUInteger {
    DTShowTableViewCellTypeSlim,
    DTShowTableViewCellTypeBlurredThumbnail, // DEFAULT
    // DTInformationPieceTypeReveal // is there a third?
} DTShowTableViewCellType;

@interface DTShowTableViewCell : UITableViewCell

@property (nonatomic, strong) DTThumbnailView *thumbnailView;

@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic) DTShowTableViewCellType type; // set this if I need to.

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSURL *fallbackImageURL;
@property (nonatomic, strong) FIRStorageReference *imageRef;


@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSArray <NSString *> *contentDescriptions;

@property BOOL placeholderState;

@end
