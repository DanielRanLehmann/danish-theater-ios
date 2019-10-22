//
//  DTVenuesViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTVenuesViewController.h"
@import Firebase;

@interface DTVenuesViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSMutableArray <NSDictionary *> *contents;

@end

@implementation DTVenuesViewController

- (instancetype)initWithCodes:(NSArray<NSString *> *)venueCodes {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Venues"];
    if (self) {
        _venueCodes = [NSArray arrayWithArray:venueCodes];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"Venues (%lu)", _venueCodes.count];
    
    self.ref = [[FIRDatabase database] reference];
    _venues = [NSMutableArray array];
    // _venueCodes = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTVenueTableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:(65 + (2 * 8))];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadVenues];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadVenues {
    if (_venueCodes.count > 0) {
        for (NSString *venueCode in _venueCodes) {
            [[[_ref child:@"venues"] child:venueCode] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSError *error = nil;
                Venue *venue = [MTLJSONAdapter modelOfClass:Venue.class fromJSONDictionary:snapshot.value error:&error];
                venue.code = snapshot.key;
                
                if (!error) {
                    [_venues addObject:venue];
                    
                    if (_venues.count == _venueCodes.count) {
                        [_tableView reloadData];
                    }
                }
            }];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _venues.count; // use a bool _loaded (self isLoaded]) instead of the localizedDescription nil check!
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Venue *venue = [_venues objectAtIndex:indexPath.row];
    
    DTVenueTableViewCell *cell = [[DTVenueTableViewCell alloc] initWithFrame:CGRectZero];
    cell.title = venue.name;
    cell.contentDescriptions = @[[NSString stringWithFormat:@"%@ %@, %@ %@", venue.street, venue.number, venue.postCode, venue.city]];
    [cell.secondaryBtn addTarget:self action:@selector(getDirections:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (IBAction)getDirections:(id)sender {
    // open apple maps and get directions.
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DZNEmptyDataSetSource
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    MDProgress *progress = [[MDProgress alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    progress.progressType = MDProgressTypeIndeterminate;
    progress.progressStyle = MDProgressStyleCircular;
    
    return progress;
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
