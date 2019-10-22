//
//  DTCreditTableViewCell.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PureLayout.h>

@interface DTCreditTableViewCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource> // name of cell should be plural, so credits?

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *tableView;

- (void)addPersonWithPosition:(NSString *)position name:(NSString *)name;

@end
