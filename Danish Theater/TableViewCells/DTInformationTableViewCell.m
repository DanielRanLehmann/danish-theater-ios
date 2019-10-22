//
//  DTInformationTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTInformationTableViewCell.h"

@interface DTInformationTableViewCell ()

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTInformationTableViewCell
@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headerTextLabel = [[UILabel alloc] initForAutoLayout];
    _headerTextLabel.numberOfLines = 1;
    _headerTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _headerTextLabel.textAlignment = NSTextAlignmentLeft;
    _headerTextLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_headerTextLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.scrollEnabled = NO;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.contentView addSubview:_tableView];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setPieces:(NSArray *)pieces {
    _pieces = [pieces copy];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pieces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // CELL SPECS
    UITableViewCellStyle cellStyle = UITableViewCellStyleValue1;
    UIColor *textLabelColor = [UIColor colorWithHex:@"#8e8e93"];
    UIColor *detailTextLabelColor = [UIColor darkTextColor];
    
    // A BIT OF PIECE [DATA] PARSING
    NSDictionary *piece = [_pieces objectAtIndex:indexPath.row];
    
    NSString *text = piece[@"Text"]; // non nullable.
    
    NSString *detailText = nil; // nullable
    UIImage *moreButtonIcon = nil; // nullable
    
    if (piece[@"moreButtonIcon"]) {
        moreButtonIcon = piece[@"moreButtonIcon"];
        cellStyle = UITableViewCellStyleDefault;
        // textLabelColor = [UIColor blackColor];
    }
    
    else {
        detailText = piece[@"DetailText"];
    }
    
    if (piece[@"TextLabelColor"]) {
        
        textLabelColor = piece[@"TextLabelColor"];
    }
    
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
    
    DTInformationPieceType informationPieceType = [piece[@"DTInformationPieceType"] unsignedIntegerValue];
    if (informationPieceType == DTInformationPieceTypeReveal) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = text;
    cell.textLabel.textColor = textLabelColor; //[UIColor colorWithHex:@"#8e8e93"]; // informationPieceType != DTInformationPieceTypeDisabled ? [UIColor lightGrayColor] : [UIColor darkTextColor];
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.textColor = informationPieceType == DTInformationPieceTypeDisabled ? [UIColor darkTextColor] : [UIColor darkTextColor];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    if (informationPieceType == DTInformationPieceTypeReveal) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (informationPieceType == DTInformationPieceTypeAction || moreButtonIcon) {
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
        moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight; 
        
        [moreButton setFrame:CGRectMake(0, 0, 44, 44)]; // THE SIZE OF THE MD ICONS.
        [moreButton setImage:moreButtonIcon forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(secondaryAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell setAccessoryView:moreButton];
        [moreButton setEnabled:informationPieceType == DTInformationPieceTypeDisabled ? NO : YES];
    }
    
    return cell;
}

- (IBAction)secondaryAction:(id)sender {
    [delegate informationTableViewCell:self didSelectSecondaryActionWithIndexPath:[_tableView indexPathForCell:(UITableViewCell *)[sender superview]]];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [delegate informationTableViewCell:self didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_headerTextLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        
        [_tableView autoSetDimension:ALDimensionHeight toSize:_tableView.contentSize.height]; // makes it or breaks it?
        
        // [_tableView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
        
        [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_tableView autoPinEdgeToSuperviewMargin:ALEdgeBottom];
        
        [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerTextLabel withOffset:4];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
