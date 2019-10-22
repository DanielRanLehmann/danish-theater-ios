//
//  DTEventsSectionViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/24/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTEventsSectionViewController.h"
#import <PureLayout/PureLayout.h>

#import "DTLoadingTableViewCell.h"

#import "UIApplication+Reachability.h"
#import "NSAttributedString+EmptyDataSet.h"

#import "TLYShyNavBarManager.h"
#import "DTQuery.h"
#import "DTColorPalette.h"

#define DEFAULT_QUERY_LIMIT 25

@interface DTEventsSectionViewController () {
    BOOL eventsQueryIsEmpty;
    BOOL didLoadInitially;
    NSError *initialLoadingError;
}

@property (nonatomic, strong) FIRDatabaseQuery *query;
@property (nonatomic, strong) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSString *lastCode;
@property (nonatomic, strong) NSMutableArray <Event *> *events;

@end

@implementation DTEventsSectionViewController

#pragma mark - Initializers

- (instancetype)initWithEventsQuery:(FIRDatabaseQuery *)evQuery {
    self = [super init];
    if (self) {
        _ref = nil;
        _query = evQuery;
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithEventsReference:(FIRDatabaseReference *)evRef {
    self = [super init];
    if (self) {
        _query = nil; 
        _ref = evRef;
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _tableViewCellStyle = DTTableViewCellStyleCover;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.title) {
        self.title = @"Detail";
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // EMPTY DATA SET
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    self.shyNavBarManager.scrollView = _tableView; // tableview inherits from scrollview class.

    
    if (!_prefixedSubsectionTexts) {
        _prefixedSubsectionTexts = @[];
    }
    
    if (!_prefixedSubsectionEventReferences) {
        _prefixedSubsectionEventReferences = @[];
    }
    
    _events = [NSMutableArray array];
    _lastCode = nil;
    
    didLoadInitially = false;
    initialLoadingError = nil;
    eventsQueryIsEmpty = false;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadEvents];
    }
}

#pragma mark - Actions

- (IBAction)more:(id)sender {
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[_events objectAtIndex:indexPath.row - (_prefixedSubsectionTexts.count > 0 ? _prefixedSubsectionTexts.count : 0)] completionHandler:nil];
}

#pragma mark - Load Data

- (void)loadEvents {
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    __block NSError *itemsError = nil;
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    if (_ref) {
    
        [DTQuery loadEventsWithReferencePath:_ref startingWithCode:_lastCode limitedToFirst:DEFAULT_QUERY_LIMIT success:^(NSArray<Event *> *events) {
            
            if (events.count <= 0) {
                eventsQueryIsEmpty = true;
                
            } else {
                
                [_events addObjectsFromArray:events];
                
                Event *lastEvent = [_events lastObject];
                _lastCode = lastEvent.code;
            }
            
            dispatch_group_leave(serviceGroup);
            
        } failure:^(NSError *error) {
            itemsError = error;
            dispatch_group_leave(serviceGroup);
        }];
    
    } else if (_query) {
        
        [DTQuery queryEventsWithQuery:_query startingWithCode:nil limitedToFirst:0 success:^(NSArray<Event *> *events) {
            
            if (events.count <= 0) {
                eventsQueryIsEmpty = true;
                
            } else {
                
                [_events addObjectsFromArray:events];
                
                Event *lastEvent = [_events lastObject];
                _lastCode = lastEvent.code;
                
            }
            
            dispatch_group_leave(serviceGroup);
            
        } failure:^(NSError *error) {
            itemsError = error;
            dispatch_group_leave(serviceGroup);
        }];
        
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        NSError *overallError = itemsError;
        if (!overallError) {
            didLoadInitially = true;
        } else {
            initialLoadingError = overallError;
        }
        
        [self.tableView reloadData];
        
    });
}

#pragma mark - TableView DataSource
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = _tableViewCellStyle == DTTableViewCellStyleThumbnail ? DTTableViewCellStyleThumbnailRowHeight() : DTTableViewCellStyleCoverRowHeight();
    
    if (indexPath.row == self.events.count) {
        estimatedRowHeight = DTLoadingTableViewCellRowHeight;
    }
    return estimatedRowHeight;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [_events count] > 0 ? (_prefixedSubsectionTexts.count + [_events count]) : 0;
   
    if (didLoadInitially && eventsQueryIsEmpty != true && (_ref != nil && _query == nil)) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (_prefixedSubsectionTexts.count > 0 && (indexPath.row >= 0 && indexPath.row <= _prefixedSubsectionTexts.count - 1)) {
        
        UITableViewCell *subsectionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SubsectionCell"];
        subsectionCell.textLabel.text = _prefixedSubsectionTexts[indexPath.row];
        subsectionCell.textLabel.textColor = self.view.tintColor;
        subsectionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell = subsectionCell;
        
    }
    
    else {
        
        if (indexPath.row == self.events.count + _prefixedSubsectionTexts.count && (_ref != nil && _query == nil)) {
            DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
            cell = loadingCell;
        
        } else {
            
            Event *event = [_events objectAtIndex:indexPath.row - (_prefixedSubsectionTexts.count > 0 ? _prefixedSubsectionTexts.count : 0)];
            
            DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            
            eventCell.style = _tableViewCellStyle;
            eventCell.imageRef = _tableViewCellStyle == DTTableViewCellStyleCover ? event.thumbnail.maxresImageRef : event.thumbnail.highImageRef;
            
            eventCell.title = event.localizedTitle;
            
            if (_tableViewCellStyle == DTTableViewCellStyleCover) {
                NSString *descriptionStr = [NSString stringWithFormat:@"%@ ‧ %@ ‧ %@", event.organizationName, event.organizationCity, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
                eventCell.contentDescriptions = @[descriptionStr];
                
            } else {
                eventCell.contentDescriptions = @[event.organizationName, event.organizationCity, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
            }
            
            cell = eventCell;
        }
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (eventsQueryIsEmpty != true && indexPath.row == ([self.events count] + (_prefixedSubsectionTexts.count - 1)) - 1) {
        if (_ref && !_query) {
            [self loadEvents];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_prefixedSubsectionTexts.count > 0 && (indexPath.row >= 0 && indexPath.row <= _prefixedSubsectionTexts.count - 1)) {
        
        // SUBSECTION
        
        DTEventsSectionViewController *eventsSectionVC = [[DTEventsSectionViewController alloc] initWithEventsReference:_prefixedSubsectionEventReferences[indexPath.row]];
        
        eventsSectionVC.title = _prefixedSubsectionTexts[indexPath.row];
        [self.navigationController pushViewController:eventsSectionVC animated:YES]; 
        
    } else {
    
        Event *event = [_events objectAtIndex:indexPath.row - _prefixedSubsectionTexts.count];
        DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:event.code];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
    }
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
        if (!didLoadInitially && initialLoadingError) { // query has not loaded yet.
            return DTEmptyDataSetStateAnErrorOccurred;
            
        } else if (!didLoadInitially && !initialLoadingError) { // query experienced an error.
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
