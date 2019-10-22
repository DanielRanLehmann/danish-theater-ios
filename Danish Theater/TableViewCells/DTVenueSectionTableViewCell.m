//
//  DTVenueSectionTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTVenueSectionTableViewCell.h"

@interface DTVenueSectionTableViewCell ()

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTVenueSectionTableViewCell

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
    
    _contents = [NSMutableArray array];
    
    _headerLabel = [[UILabel alloc] initForAutoLayout];
    _headerLabel.numberOfLines = 1;
    _headerLabel.font = [UIFont systemFontOfSize:17];
    _headerLabel.textAlignment = NSTextAlignmentLeft;
    _headerLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_headerLabel];
    
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
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.contentView addSubview:_tableView];
    
    [_tableView registerClass:[DTVenueTableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:65 * (2 * 8)]; // what should the padding be?
}

#pragma mark - Public
- (void)populateVenuesWithContents:(NSArray *)contents {
    [_contents addObjectsFromArray:contents];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DTVenueTableViewCell *cell = [[DTVenueTableViewCell alloc] initWithFrame:CGRectZero];
    
    NSDictionary *content = [_contents objectAtIndex:indexPath.row];
    [cell populateWithContent:content];
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - DZNEmptyDataSetSource
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    MDProgress *progress = [[MDProgress alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    progress.progressType = MDProgressTypeIndeterminate;
    progress.progressStyle = MDProgressStyleCircular;
    
    return progress;
}

#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_headerLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        [_tableView autoSetDimension:ALDimensionHeight toSize:_tableView.contentSize.height];
        
        [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerLabel withOffset:4];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
