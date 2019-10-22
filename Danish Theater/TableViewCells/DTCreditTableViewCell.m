//
//  DTCreditTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCreditTableViewCell.h"

@interface DTCreditTableViewCell ()

@property (nonatomic, strong) NSMutableArray *contents;
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTCreditTableViewCell

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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.contentView addSubview:_tableView];
    
}

#pragma mark - Public
- (void)addPersonWithPosition:(NSString *)position name:(NSString *)name {
    [_contents addObject:@{@"position" : position, @"name" : name}];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    NSDictionary *person = [_contents objectAtIndex:indexPath.row];
    cell.textLabel.text = person[@"position"];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.detailTextLabel.text = person[@"name"];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

#pragma mark - Layout
- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_headerLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        
        [_tableView autoSetDimension:ALDimensionHeight toSize:_tableView.contentSize.height]; // makes it or breaks it?
        
        // [_tableView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
        
        [_tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [_tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [_tableView autoPinEdgeToSuperviewMargin:ALEdgeBottom];
        
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
