//
//  DTCreditsViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCreditsViewController.h"
#import "TLYShyNavBarManager.h"

@interface DTCreditsViewController ()

@end

@implementation DTCreditsViewController

- (instancetype)initWithAccreditations:(NSArray <Accreditation *> *)accreditations {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Credits"];
    if (self) {
        // config.
        _accreditations = [NSArray arrayWithArray:accreditations];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"CREDITS_TEXT", nil), _includeCountInHeader ? [NSString stringWithFormat:@"(%lu)", _accreditations.count] : @""];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    self.shyNavBarManager.scrollView = _tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setIncludeCountInHeader:(BOOL)includeCountInHeader {
    _includeCountInHeader = includeCountInHeader;
}

#pragma mark - UITableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _accreditations.count; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Accreditation *accreditation = [_accreditations objectAtIndex:indexPath.row];
    
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    
    if (accreditation.positionName) {
        cell.textLabel.text = accreditation.positionName;
    }
    
    NSMutableString *detailText = [NSMutableString string];
    if (accreditation.firstname) {
        [detailText appendString:accreditation.firstname];
        if (accreditation.lastname)
            [detailText appendString:@" "];
    }
    
    if (accreditation.lastname) {
        [detailText appendString:accreditation.lastname];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", accreditation.firstname, accreditation.lastname]; // not safe!
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
