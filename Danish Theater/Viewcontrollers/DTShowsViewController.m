//
//  DTShowsViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/29/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTShowsViewController.h"
#import "TLYShyNavBarManager.h"

#import "DTColorPalette.h"
#import "DTQuery.h"

#define DEFAULT_QUERY_LIMTIT 50 // THIS NEEDS TO BE THOROUGHLY TESTED.

@import Firebase;

@interface DTShowsViewController () {
    BOOL showsQueryIsEmpty;
    NSError *initialLoadingError;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;

// both two props below are nullable.
@property (nonatomic, strong) NSString *eventCode;
@property (nonatomic, strong) NSString *organizationCode;

@property BOOL didLoadInitially;

@property (nonatomic, strong) NSString *lastShowCode;

@property (nonatomic, strong) NSMutableArray *shows;
@property (nonatomic, strong) NSMutableArray *months;

@property (nonatomic) NSTimeInterval lastShowTimestamp;

@end

@implementation DTShowsViewController

- (instancetype)initWithOrganizationCode:(NSString *)organizationCode {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Shows"];
    if (self) {
        
        _organizationCode = organizationCode;
        _ref = [[[FIRDatabase database] referenceWithPath:@"organization-shows"] child:organizationCode];
    }
    
    return self;
}

- (instancetype)initWithEventCode:(NSString *)eventCode {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Shows"];
    if (self) {
        
        _eventCode = eventCode;
        _ref = [[[FIRDatabase database] referenceWithPath:@"event-shows"] child:eventCode];
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"SHOWS_TEXT", nil);
    
    if (!_ref) {
        self.ref = [[FIRDatabase database] reference];
    }
    
    _didLoadInitially = false;
    _lastShowCode = nil;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTShowTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTCalendarTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
   
    [_tableView setEstimatedSectionHeaderHeight:10];
    _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    
    self.shyNavBarManager.scrollView = _tableView;
    
    _lastShowTimestamp = [[NSDate date] timeIntervalSince1970];
    showsQueryIsEmpty = false;
    
    _shows = [NSMutableArray array];
    _months = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadShows];
    }
}

#pragma mark - Actions

- (IBAction)more:(id)sender {
    
    DTShowTableViewCell *selectedShowCell = (DTShowTableViewCell *)[[(sender) superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedShowCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithShow:[_shows objectAtIndex:indexPath.row]];
}

#pragma mark - Load Data

- (void)loadShows {
    
    __block NSError *showsError = nil;
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    [DTQuery loadShowsWithReferencePath:_ref includeMonths:YES startingWithTimestamp:_lastShowTimestamp+1 limitedToFirst:DEFAULT_QUERY_LIMTIT success:^(NSString * _Nonnull startingCode, NSArray<NSString *> * _Nonnull months, NSArray * _Nonnull shows) {
        
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
            _lastShowTimestamp = lastShow.timestamp;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (showsQueryIsEmpty != true && indexPath.section == self.shows.count - 1 && indexPath.row == [self.shows[indexPath.section] count] - 1) {
        [self loadShows];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES]; // pop or go to ticket website, if possible. 
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
        [self loadShows];
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
