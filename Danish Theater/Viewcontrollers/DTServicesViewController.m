//
//  DTServicesViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/1/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTServicesViewController.h"

@interface DTServicesViewController ()

@end

@implementation DTServicesViewController

- (instancetype)initWithServices:(NSArray <NSString *> *)services {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Services"];
    if (self) {
        // config.
        _services = [NSArray arrayWithArray:services];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SERVICES_TEXT", nil), _includeCountInHeader ? [NSString stringWithFormat:@"(%lu)", _services.count] : @""];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
}

- (void)setIncludeCountInHeader:(BOOL)includeCountInHeader {
    _includeCountInHeader = includeCountInHeader;
}

#pragma mark - UITableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    cell.textLabel.text = [_services objectAtIndex:indexPath.row];
    
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
