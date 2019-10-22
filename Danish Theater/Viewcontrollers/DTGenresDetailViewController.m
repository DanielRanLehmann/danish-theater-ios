//
//  DTGenresDetailViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTGenresDetailViewController.h"
#import "DTQuery.h"
#import "DTColorPalette.h"

#define DEFAULT_QUERY_LIMIT 25

@import Firebase;

@interface DTGenresDetailViewController () {
    BOOL eventsQueryIsEmpty;
    NSError *initialLoadingError;
}

@property (nonatomic, strong) FIRDatabaseReference *ref;

@property BOOL didLoadInitially;
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSString *lastEventCode;

@property (nonatomic) NSUInteger totalNumberOfEvents;
@property (nonatomic) NSUInteger currentNumberOfEvents;

@end

@implementation DTGenresDetailViewController

- (instancetype)init {

    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Genres Detail"];
    if (self) {
        
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ref = [[[FIRDatabase database] referenceWithPath:@"genre-event-snippets"] child:_genreDetailItem];
    
    _didLoadInitially = false;
    initialLoadingError = nil;
    _lastEventCode = nil;
    
    _events = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // EMPTYDATASET
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    eventsQueryIsEmpty = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadEvents];
    }
}

#pragma mark - Managing the detail item

- (void)setGenreDetailItem:(NSString *)newGenreDetailItem {
    if (_genreDetailItem != newGenreDetailItem) {
        _genreDetailItem = newGenreDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    if (self.genreDetailItem) {
        self.navigationItem.title = self.genreDetailItem;
    }
}

#pragma mark - Actions
- (IBAction)more:(id)sender {
    
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[(sender) superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[_events objectAtIndex:indexPath.row] completionHandler:nil];
}

#pragma mark - Load Data
- (void)loadEvents {
    
    __block NSError *eventsError = nil;
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    [DTQuery loadEventsWithReferencePath:_ref startingWithCode:_lastEventCode limitedToFirst:DEFAULT_QUERY_LIMIT success:^(NSArray<Event *> *events) {
        
        if (events.count <= 0) {
            eventsQueryIsEmpty = true;
        
        } else {
        
            [_events addObjectsFromArray:events];
            _currentNumberOfEvents = [_events count];
            
            Event *lastEvent = [_events lastObject];
            _lastEventCode = lastEvent.code;
        }
        
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        // handle failure.
        eventsError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        NSError *overallError = eventsError;
        if (!overallError) {
            
            [FIRAnalytics logEventWithName:kFIREventSelectContent
                                parameters:@{
                                             kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", self.navigationItem.title],
                                             kFIRParameterItemName:self.navigationItem.title,
                                             kFIRParameterContentType:@"genre"
                                             }];
            
            _didLoadInitially = true;
            
        } else {
            initialLoadingError = eventsError;
        }
        
        [self.tableView reloadData];
        
    });
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = DTTableViewCellStyleCoverRowHeight();
    
    if (indexPath.row == self.events.count) {
        estimatedRowHeight = DTLoadingTableViewCellRowHeight;
    }
    return estimatedRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [_events count];
    if (numberOfRows >= DEFAULT_QUERY_LIMIT && eventsQueryIsEmpty != true) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row == self.events.count) {
        
        DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
        cell = loadingCell;
    }
    
    else {
        
        Event *event = [_events objectAtIndex:indexPath.row];
        
        DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
        [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
        
        eventCell.style = DTTableViewCellStyleCover;
        eventCell.imageRef = event.thumbnail.maxresImageRef;
        eventCell.fallbackImageURL = [NSURL terebaImageURLWithCode:event.code orientaion:TerebaImageOrientationLandscape];
        
        eventCell.title = event.localizedTitle;
        
        if (![event.caption isEqualToString:@"Almindelig åben"]) {
            eventCell.caption = event.caption;
        }
        
        NSString *descriptionStr = [NSString stringWithFormat:@"%@ ‧ %@ ‧ %@", event.organizationName, event.organizationCity, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
        
        eventCell.contentDescriptions = @[descriptionStr];
        
        cell = eventCell;
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (eventsQueryIsEmpty != true &&  indexPath.row == [self.events count] - 1) {
        [self loadEvents];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Event *event = [_events objectAtIndex:indexPath.row];
    DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:event.code];
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
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_CONTENT_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
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
        [self loadEvents];
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

@end
