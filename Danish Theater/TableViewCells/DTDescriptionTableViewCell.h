//
//  DTDescriptionTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"

@class DTDescriptionTableViewCell;
@protocol DTDescriptionTableViewCellDelegate <NSObject>

- (void)didSelectMoreWithDescriptionTableViewCell:(DTDescriptionTableViewCell *)cell;

@end

@interface DTDescriptionTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, readonly) UILabel *headerLabel;
@property (nonatomic, readonly) UITextView *textView;

@property (nonatomic, strong) NSString *headerText;
@property (nonatomic, strong) NSString *descriptionText;

@property (nonatomic) NSUInteger previewDescriptionLength;

@property (nonatomic, assign, getter=isDescriptionTextExpanded) BOOL descriptionTextExpanded;

@property (nonatomic, weak) id <DTDescriptionTableViewCellDelegate> delegate;

- (void)expandDescription;
- (void)populateWithData;

@end
