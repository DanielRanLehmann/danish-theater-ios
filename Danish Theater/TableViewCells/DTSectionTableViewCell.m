//
//  DTSectionTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/25/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTSectionTableViewCell.h"

@interface DTSectionTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property BOOL shouldStartLoading;

@property (nonatomic, strong) Class itemsModelClass;

@end

@implementation DTSectionTableViewCell
@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configure {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headerTextLabel = [[UILabel alloc] initForAutoLayout];
    _headerTextLabel.numberOfLines = 2;
    _headerTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _headerTextLabel.textAlignment = NSTextAlignmentLeft;
    _headerTextLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_headerTextLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.scrollEnabled = NO;
    _tableView.alwaysBounceVertical = NO;
    _tableView.bounces = NO;
    
    _tableView.delaysContentTouches = NO;
    _tableView.canCancelContentTouches = NO;
    
    [_tableView setScrollsToTop:NO];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.contentView addSubview:_tableView];
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"loading cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    // [_tableView setEstimatedRowHeight:DTTableViewCellStyleThumbnailRowHeight];
    
    _showsSeeMoreItem = false;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = DTLoadingTableViewCellRowHeight;
    if (indexPath.row < [_items count]) {
    // if ([[[_items objectAtIndex:indexPath.row] class] isEqual:[Event class]]) {
        estimatedRowHeight = DTTableViewCellStyleThumbnailRowHeight();
    }
    
    return estimatedRowHeight;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count] > 0 ? _items.count + (_showsSeeMoreItem == true ? 1 : 0) : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row < [_items count]) {
        
        if (_itemsModelClass == [Event class]) {
        
            Event *event = [_items objectAtIndex:indexPath.row]; // use this to populate how much you want.
            
            DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            
            eventCell.style = DTTableViewCellStyleThumbnail;
            eventCell.imageRef = event.thumbnail.highImageRef;
            
            eventCell.title = event.localizedTitle;
            eventCell.contentDescriptions = @[event.organizationName, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
            
            cell = eventCell;
            
        } else if (_itemsModelClass == [Organization class]) {
        
            Organization *organization = [_items objectAtIndex:indexPath.row]; // use this to populate how much you want.
            
            DTTableViewCell *organizationCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [organizationCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            
            organizationCell.style = DTTableViewCellStyleThumbnail;
            organizationCell.imageRef = organization.thumbnail.highImageRef;
            
            organizationCell.title = organization.name;
            organizationCell.contentDescriptions = @[organization.city];
            
            cell = organizationCell;
            
        } else {
            NSAssert(_itemsModelClass == nil, @"Model Class Of Items is currently unsuported. Use - setItems: ofModelClass: instead.");
        }
        
    }
    
    else {
        
        DTLoadingTableViewCell *seeMoreCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
         
        [seeMoreCell.primaryBtn setTitle:_seeMoreText forState:UIControlStateNormal];
        [seeMoreCell.primaryBtn addTarget:self action:@selector(primaryAction:) forControlEvents:UIControlEventTouchUpInside];
        
        seeMoreCell.visibleSeparatorLine = NO;
        [seeMoreCell stopLoading];
        
        /*
        UITableViewCell *seeMoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SeeMoreCell"];
        seeMoreCell.textLabel.text = _seeMoreText;
        seeMoreCell.textLabel.textColor = self.contentView.tintColor;
        */
        
        cell = seeMoreCell;
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (IBAction)more:(id)sender {
   
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    [delegate sectionTableViewCell:self didSelectSecondaryButtonWithIndexPath:indexPath];
}

- (void)primaryAction:(id)sender {
    
    DTLoadingTableViewCell *cell = (DTLoadingTableViewCell *)[[sender superview] superview];
    if (_shouldStartLoading) {
        [cell startLoading];
    }
    
    // else might not be needed, just do nothing?
    else {
        [cell stopLoading];
    }
    
    [delegate didSelectSeeMoreWithSectionTableViewCell:self];
    
}

#pragma mark - UITableViewDelegate
/* only used for testing */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cell height: %@", NSStringFromCGRect(cell.bounds));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[[_items objectAtIndex:indexPath.row] class] isEqual:_itemsModelClass]) {
        [delegate sectionTableViewCell:self didSelectSnippetWithIndexPath:indexPath];
    }
}

/* this has just recently been added to make up for the wrong height.
-(void)didMoveToSuperview {
    [self layoutIfNeeded];
}
*/

- (void)setItems:(NSArray *)items ofModelClass:(Class)modelClass {
    _items = [items copy];
    _itemsModelClass = modelClass;
    [_tableView reloadData];
}

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    [_tableView reloadData];
}

- (void)populateWithData {
    
    NSMutableString *mutStr = [NSMutableString string];
    if (_headerTitle) {
        [mutStr appendString:_headerTitle];
        if (_headerSubtitle) {
            [mutStr appendString:[NSString stringWithFormat:@"\n%@", _headerSubtitle]];
            
        }
        
        NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:mutStr attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
        NSRange newlineRange = [[mutAttrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        if (newlineRange.location != NSNotFound) {
            [mutAttrStr addAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote], NSForegroundColorAttributeName : [UIColor lightGrayColor]} range:NSMakeRange(newlineRange.location, [mutAttrStr string].length - newlineRange.location)];
        }
        
        [self.headerTextLabel setAttributedText:mutAttrStr];
    }
}

#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populateWithData];
        
        [_headerTextLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        [_tableView autoSetDimension:ALDimensionHeight toSize:_tableView.contentSize.height];
        
        [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
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
