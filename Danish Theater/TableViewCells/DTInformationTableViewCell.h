//
//  DTInformationTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "UIColor+ColorFromHexadecimal.h" 

@class DTInformationTableViewCell;
@protocol DTInformationTableViewCellDelegate <NSObject> // or alt. name: DTInformationTableViewCellDelegate

- (void)informationTableViewCell:(DTInformationTableViewCell *)cell didSelectRowAtIndexPath:(NSIndexPath *)indexPath; // This is not great., but makes the point clear.
- (void)informationTableViewCell:(DTInformationTableViewCell *)cell didSelectSecondaryActionWithIndexPath:(NSIndexPath *)indexPath;

@end

typedef enum : NSUInteger {
    DTInformationPieceTypeDefault, // default just means plain text
    DTInformationPieceTypeAction,
    DTInformationPieceTypeReveal,
    DTInformationPieceTypeDisabled
} DTInformationPieceType;

// create protocol (delegate) to listen for DTInformationTypeAction triggers, and be able to act upon them?

@interface DTInformationTableViewCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *headerTextLabel;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *pieces;

@property (nonatomic, weak) id <DTInformationTableViewCellDelegate> delegate;

@end
