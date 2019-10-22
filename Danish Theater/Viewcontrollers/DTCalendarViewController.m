//
//  DTCalendarViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCalendarViewController.h"
#import "TLYShyNavBarManager.h"

#define DEFAULT_QUERY_LIMTIT 50 // THIS NEEDS TO BE THOROUGHLY TESTED.
#define DEFAULT_MUNICIPALITY @"København" // if all else fails

#import "DTColorPalette.h"
#import "DTQuery.h"
@import Firebase;

@interface DTCalendarViewController () {

    BOOL showsQueryIsEmpty;
    NSError *initialLoadingError;
}

@property (nonatomic, strong) FIRDatabaseReference *ref;

@property BOOL didLoadInitially;

@property (nonatomic, strong) NSMutableArray *shows;
@property (nonatomic, strong) NSMutableArray *months;

@property (nonatomic, strong) NSArray <NSString *> *municipalities;
@property (nonatomic, strong) NSString *selectedMunicipality;
@property (nonatomic, copy) NSString *usersLocalMunicipaltiy;

@property (nonatomic, strong) UIButton *municipalityBtn;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;

@property (nonatomic) NSTimeInterval lastShowTimestamp;

@end

@implementation DTCalendarViewController

- (instancetype)init {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Calendar"];
    if (self) {
        
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"CALENDAR_TITLE", nil);
    
    _selectedMunicipality = nil;
    
    self.ref = [[FIRDatabase database] reference];
    _didLoadInitially = false;
    
    _municipalityBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _municipalityBtn.tintColor = [UIColor blackColor];
    [_municipalityBtn setTitle:NSLocalizedString(@"LOADING_NAVBAR_TITLE", nil) forState:UIControlStateNormal];
    [_municipalityBtn addTarget:self action:@selector(pickMunicipality:) forControlEvents:UIControlEventTouchUpInside];
    [_municipalityBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_municipalityBtn sizeToFit];
    
    self.navigationItem.titleView = _municipalityBtn;
    
    UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAVORITES_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(favorites:)]; // pickMuni selector just for testing.
    self.navigationItem.rightBarButtonItem = favoritesItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // DZNEMPTYDATASET
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTCalendarTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    [_tableView registerClass:[DTShowTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    [_tableView setEstimatedSectionHeaderHeight:10];
    _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    
    self.shyNavBarManager.scrollView = _tableView;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // remember, I just have to detect the muni
    
    _lastShowTimestamp = [[NSDate date] timeIntervalSince1970];
    
    showsQueryIsEmpty = false;
    
    _shows = [NSMutableArray array];
    _months = [NSMutableArray array];
    _municipalities = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline] && _selectedMunicipality == nil) {
        if (!_userLocation) {
            [self requestUserLocation];
        }
        
        [self configureView];
    }
}

#pragma mark - Load Data

- (void)configureView {
    
    __block NSError *municipalitiesError = nil;
    __block NSError *nearestMunicipalityLocationError = nil;
    
    // Create the dispatch group
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // start the first service
    dispatch_group_enter(serviceGroup);
    
    [DTQuery queryMunicipalitiesWithSuccess:^(NSArray<NSString *> *municipalities) {
        _municipalities = [NSArray arrayWithArray:municipalities];
        dispatch_group_leave(serviceGroup);
    
    } failure:^(NSError *error) {
        municipalitiesError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_enter(serviceGroup);
    
    _userLocation = nil;
    if (_userLocation) {
    
        # warning error with this thing. -> use apples internal reverseGeocoder instead.
        [DTMunicipalityPickerController getNearestMunicipalityWithLocation:_userLocation withSuccess:^(NSString *municipality) {
            
            _selectedMunicipality = municipality;
            if (_userLocation) { _usersLocalMunicipaltiy = municipality; }
            
            if (![_municipalities containsObject:_selectedMunicipality]) {
                _selectedMunicipality = DEFAULT_MUNICIPALITY;
            }
            
            dispatch_group_leave(serviceGroup);
            
        } failure:^(NSError *error) {
            nearestMunicipalityLocationError = error;
            dispatch_group_leave(serviceGroup);
        }];

    } else { _selectedMunicipality = DEFAULT_MUNICIPALITY; }
    
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
        
        NSError *overallError = nil;
        if (municipalitiesError || nearestMunicipalityLocationError) {
            overallError = municipalitiesError ?: nearestMunicipalityLocationError;
        }
        
        if (!overallError) {
            [_municipalityBtn setAttributedTitle:[self attributedStringWithTitle] forState:UIControlStateNormal];
            [_municipalityBtn sizeToFit];
            
            [self loadShows];
        } else {
            initialLoadingError = overallError;
        }
    });
}

- (void)loadShows {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] referenceWithPath:[NSString stringWithFormat:@"municipality-shows/%@", _selectedMunicipality]];

    __block NSError *showsError = nil;
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    [DTQuery loadShowsWithReferencePath:ref includeMonths:YES startingWithTimestamp:_lastShowTimestamp limitedToFirst:DEFAULT_QUERY_LIMTIT success:^(NSString * _Nonnull startingCode, NSArray<NSString *> * _Nonnull months, NSArray * _Nonnull shows) {
        
        if (shows.count <= 0) {
            showsQueryIsEmpty = true;
        } else {
        
            for (int i = 0; i < months.count; i++) {
                NSString *month = months[i];
                
                NSUInteger monthIndex = [_months indexOfObject:month];
                if (monthIndex != NSNotFound) {
                    
                    NSMutableArray *updatedMutArray = [NSMutableArray arrayWithArray:[_shows objectAtIndex:monthIndex]];
                    [updatedMutArray addObjectsFromArray:shows[i]];
                    
                    [_shows replaceObjectAtIndex:monthIndex withObject:updatedMutArray];
                }
                
                else {
                    [_months addObject:month];
                    
                    NSArray *newSectionArr = shows[i];
                    [_shows addObject:newSectionArr];
                }
            }
            
            Show *lastShow = (Show *)[[_shows lastObject] lastObject];
            _lastShowTimestamp = lastShow.timestamp + 1;

        }
    
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError * _Nonnull error) {
        showsError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        NSError *overallError = showsError;
        
        if (!overallError) {
            _didLoadInitially = true;
            
        } else {
            initialLoadingError = overallError;
        }
        
        [self.tableView reloadData];
    });
}

#pragma mark - Actions

- (IBAction)more:(id)sender {
    
    DTShowTableViewCell *selectedCell = (DTShowTableViewCell *)[[(sender) superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithShow:[[_shows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
}

- (IBAction)favorites:(id)sender {
    [DanishTheater presentFavoritesFromViewController:self animated:YES completion:^(BOOL cancelled, NSString * _Nonnull selectedEventCode) {
        if (!cancelled) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEventCode];
            [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CALENDAR_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
    }];
}

- (IBAction)pickMunicipality:(id)sender {
    
    [DanishTheater pickMunicipalityFromViewController:self selectedMunicipality:_selectedMunicipality usersLocalMunicipality:_usersLocalMunicipaltiy animated:YES completion:^(BOOL cancelled, NSString * _Nonnull selectedMunicipality) {
        
        if (!cancelled) {
            _didLoadInitially = NO;
             showsQueryIsEmpty = false;
            _selectedMunicipality = selectedMunicipality;
            
            [self refresh];
            [self loadShows];
        }
        
    }];
}

#pragma mark - Convenience Methods

- (void)requestUserLocation {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        
        [_locationManager requestWhenInUseAuthorization]; //only ask for location of user when app is in foreground.
        
    } else {
        
        [_locationManager startUpdatingLocation];
    }
}

- (void)refresh {
    
    // condition prevents title turning null
    if (_selectedMunicipality) {
        [_municipalityBtn setAttributedTitle:[self attributedStringWithTitle] forState:UIControlStateNormal];
        [_municipalityBtn sizeToFit];
    }
    
    _shows = [NSMutableArray array];
    _months = [NSMutableArray array];
    [_tableView reloadData];
}

- (NSAttributedString *)attributedStringWithTitle {
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"        %@ ", _selectedMunicipality]];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [[UIImage imageNamed:@"ic_arrow_drop_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    attachment.bounds = CGRectMake(-6, -6, attachment.image.size.width, attachment.image.size.height);
    [attrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    
    return attrStr;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = [[_shows objectAtIndex:section] count];
    if (section == self.shows.count - 1 && showsQueryIsEmpty != true) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = DTShowTableViewCellRowHeight;
    if (indexPath.section == self.shows.count - 1 && indexPath.row == [self.shows[indexPath.section] count]) {
        estimatedRowHeight = DTLoadingTableViewCellRowHeight;
    }
    
    return estimatedRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == self.shows.count - 1 && indexPath.row == [self.shows[indexPath.section] count]) {
        
        DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
        cell = loadingCell;
    }
    
    else {
        
        DTShowTableViewCell *showCell = [[DTShowTableViewCell alloc] initWithFrame:CGRectZero];
        [showCell.moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
        
        Show *show = [[_shows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.locale = [NSLocale localeWithLocaleIdentifier:[preferredLocalization isEqualToString:@"da"] ? @"da" : @"en_US_POSIX"];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%@ %@", show.date, show.time]];
        
        NSDateFormatter *newDf = [[NSDateFormatter alloc] init];
        [newDf setDateStyle:NSDateFormatterNoStyle];
        [newDf setTimeStyle:NSDateFormatterShortStyle];
        
        showCell.date = date;
        showCell.imageRef = show.imageRef;
        showCell.titleText = show.localizedEventTitle;
        
        NSMutableString *showTimeStr = [NSMutableString string];
        if ([preferredLocalization isEqualToString:@"da"]) {
            [showTimeStr appendFormat:@"kl. %@", [newDf stringFromDate:date]];
        }
        
        else {
            showTimeStr = [NSMutableString stringWithString:[newDf stringFromDate:date]];
        }
        
        showCell.contentDescriptions = @[show.venueName, showTimeStr];
        
        cell = showCell;
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_months count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *reuseIdentifier = @"Header";
    
    DTCalendarTableViewHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    header.textLabel.text = [_months objectAtIndex:section];
    
    [header updateConstraintsIfNeeded];
    return header;
}

#pragma mark - UITableViewDelegate
/* only used for testing */

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (showsQueryIsEmpty != true && indexPath.section == self.shows.count - 1 && indexPath.row == [self.shows[indexPath.section] count] - 1) {
        
        [self loadShows];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:[[[_shows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] eventCode]];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CALENDAR_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

#pragma mark - DZNEmptyDataSetSource

// Online State
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    
    if (self.emptyDataSetState == DTEmptyDataSetStateLoading) {
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        return activityView;
    }
    
    return nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_TITLE", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        return nil;
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateAnErrorOccurred) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_TITLE", nil)];
    }
    
    return nil;
    
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_SHOWS_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateAnErrorOccurred) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_DESCRIPTION", nil)];
    }
    
    return nil;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline || self.emptyDataSetState == DTEmptyDataSetStateAnErrorOccurred) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"TRY_AGAIN_EMPTY_DATA_SET_BUTTON_TITLE", nil) attributes:@{NSForegroundColorAttributeName : DTPrimaryColor()}];
    }
    
    return nil;
}

- (void)setEmptyDataSetState:(DTEmptyDataSetState)emptyDataSetState {
    self.emptyDataSetState = emptyDataSetState;
}

#pragma mark - EmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    if (self.emptyDataSetState != DTEmptyDataSetStateOffline) {
        [self configureView];
    }
    
}

- (DTEmptyDataSetState)emptyDataSetState {
    
    if ([[UIApplication sharedApplication] isOnline]) {
        if (!_didLoadInitially && initialLoadingError) { // query has not loaded yet.
            return DTEmptyDataSetStateAnErrorOccurred;
            
        } else if (!_didLoadInitially && !initialLoadingError) { // query experienced an error.
            return DTEmptyDataSetStateLoading;
        }
        
        else {
            return DTEmptyDataSetStateNoContent; // query did load intially and expereinced no error, but no content was found at [child] path.
        }
        
    } else if ([[UIApplication sharedApplication] isOffline]) {
        return DTEmptyDataSetStateOffline;
        
    }
    
    return DTEmptyDataSetStateUndefined;
}


#pragma mark - DTMunicipalityPickerControllerDelegate
- (void)municipalityPickerController:(DTMunicipalityPickerController *)picker didFinishPickingWithMuncipality:(NSString *)municipality {
    
    /*
    _didLoadInitially = NO;
    _selectedMunicipality = municipality;
    
    [self refresh];
    [self loadShowsWithMunicipality:_selectedMunicipality];
    */
}

- (void)municipalityPickerControllerDidCancel:(DTMunicipalityPickerController *)picker {
    NSLog(@"municipalityPickerControllerDidCancel");
}

#pragma mark - CLLocation

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"this is called. status: %d", status);
    [self handleAuthorizationStatus:status withLocationManager:manager];
    
}

- (void)handleAuthorizationStatus:(CLAuthorizationStatus)status withLocationManager:(CLLocationManager *)manager {
    
    switch (status) {
            
            //Ask again
        case kCLAuthorizationStatusNotDetermined:
            [manager requestWhenInUseAuthorization];
            break;
            
            //Success handling
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            [self refresh];
            [manager startUpdatingLocation];
            
            break;
            
            //Error handling
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            
            NSLog(@"denied.");
            //[self presentAlertControllerWithTitle:@"Location Access Disabled" message:@"In order to find theatres near you, kindly give us access to your location."];
            
            break;
            
        default:
            break;
    }
    
}

-(void)locationManger:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.userLocation = [locations lastObject];
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
