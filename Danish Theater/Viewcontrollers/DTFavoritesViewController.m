//
//  DTFavoritesViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTFavoritesViewController.h"

#import "DTQuery.h" 
#import "DTColorPalette.h"

#define DEFAULT_QUERY_LIMIT 25

@import Firebase;

@interface DTFavoritesViewController () {
    
    BOOL eventsQueryIsEmpty;
    NSError *initialLoadingError;
}


@property (nonatomic, strong) FIRDatabaseReference *ref;
@property BOOL didLoadInitially;
@property BOOL emptyFavorites;
@property (nonatomic, strong) NSMutableArray *events;
@property NSUInteger childrenCount;
@property (nonatomic, strong) FIRUser *user;
@property (nonatomic, strong) NSMutableOrderedSet *orderedEventCodes;

@end

@implementation DTFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ref = [[FIRDatabase database] reference];
    _user = [FIRAuth auth].currentUser;
    
    self.title = NSLocalizedString(@"FAVORITES_NAVBAR_TITLE", nil);
    
    UIBarButtonItem *clearAllItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLEAR_ALL_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(clearAll:)];
    
    clearAllItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = clearAllItem;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CANCEL_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    _emptyFavorites = true;
    
    _events = [NSMutableArray array];
    _didLoadInitially = false;
    
    eventsQueryIsEmpty = false;
    initialLoadingError = nil;
    
    _events = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    // [_tableView setEstimatedRowHeight:DTTableViewCellStyleCoverRowHeight]; // what should the padding be? 8 is the norm.?
    
}

// REFRESH AFTER POP OF NAVCONTROLLER
// SEEMS TO WORK PRETTY WELL.

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_user != nil && [[UIApplication sharedApplication] isOnline] && _didLoadInitially == false) {
        [self loadFavoriteEventsForUserWithId:_user.uid];
    }
}

#pragma mark - Actions

- (IBAction)more:(id)sender {
    
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[_events objectAtIndex:indexPath.row] completionHandler:^(BOOL cancelled) {
        if (!cancelled) {
            [_events removeObjectAtIndex:indexPath.row];
            
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView endUpdates];
            
        }
    }];
}

- (IBAction)cancel:(id)sender {
    
    _completion(YES, nil);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearAll:(id)sender {
    
    if (_events.count > 0) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CLEAR_ALL_ITEM_TITLE", nil) message:NSLocalizedString(@"ARE_YOU_SURE_TEXT", nil) preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *clearAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CLEAR_ALL_ITEM_TITLE", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[[_ref child:@"user-favorites"] child:_user.uid] setValue:nil];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            _events = [NSMutableArray array];
            _emptyFavorites = YES;
            eventsQueryIsEmpty = YES;
            [_tableView reloadData];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_ITEM_TITLE", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:clearAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

#pragma mark - Load Data
- (void)loadFavoriteEventsForUserWithId:(NSString *)userId {
    
    [DTQuery queryFavoriteEventsForUserWithId:userId success:^(NSArray<Event *> *events) {
        
        if (events.count <= 0) {
            eventsQueryIsEmpty = true;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [_events addObjectsFromArray:events];
        }
        
        _didLoadInitially = true;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        initialLoadingError = error;
        [self.tableView reloadEmptyDataSet];
    }];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return DTTableViewCellStyleCoverRowHeight();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (![[_events objectAtIndex:indexPath.row] isEqual:[NSNull null]]) {
        
        Event *event = [_events objectAtIndex:indexPath.row];
        
        DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
        [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
        
        eventCell.style = DTTableViewCellStyleCover;
        eventCell.fallbackImageURL = [NSURL terebaImageURLWithCode:event.code orientaion:TerebaImageOrientationLandscape];
        eventCell.imageRef = event.thumbnail.maxresImageRef;
        eventCell.title = event.localizedTitle;
        
        if (![event.caption isEqualToString:@"Almindelig åben"]) {
            eventCell.caption = event.caption;
        }
        
        NSString *descriptionStr = [NSString stringWithFormat:@"%@ ‧ %@ ‧ %@", event.organizationName, event.organizationCity, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
        
        eventCell.contentDescriptions = @[descriptionStr/*, [NSString stringWithPlayingPeriodFromPlaysFrom:event.playsFrom andPlaysTo:event.playsTo]*/];
        
        cell = eventCell;
    }
    
    else {
        
        DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
        cell = loadingCell;
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Event *event = [_events objectAtIndex:indexPath.row];
    NSString *eventCode = event.code;
    [self dismissViewControllerAnimated:YES completion:^{
        _completion(NO, eventCode);
    }];
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
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_FAVORITES_EMPTY_DATA_SET_TITLE", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateAnErrorOccurred) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_TITLE", nil)];
    }
    
    return nil;
    
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_FAVORITES_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
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
    if (self.emptyDataSetState != DTEmptyDataSetStateOffline && _user) {
        [self loadFavoriteEventsForUserWithId:_user.uid];
    }
    
}

- (DTEmptyDataSetState)emptyDataSetState {
    
    if ([[UIApplication sharedApplication] isOnline]) {
        if (!_didLoadInitially && (initialLoadingError || !_user)) { // query has not loaded yet.
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
