//
//  DTKidsViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/12/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTKidsViewController.h"
#import "TLYShyNavBarManager.h"

#define DEFAULT_QUERY_LIMIT 5

#import "DTColorPalette.h"
#import "DTQuery.h"
@import Firebase;

@interface DTKidsViewController () {
    
    NSError *initialLoadingError;
}

@property (nonatomic, strong) FIRDatabaseReference *ref;
@property BOOL didLoadInitially;

@property (nonatomic, strong) NSMutableArray <NSString *> *kidsAgeRanges;
@property (nonatomic, strong) NSMutableArray <NSArray <Event *> *> *eventSections;

@end

@implementation DTKidsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"KIDS_TITLE", nil);
    
    self.ref = [[FIRDatabase database] reference];
    
    _didLoadInitially = false;
    initialLoadingError = nil;
    
    UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAVORITES_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(favorites:)]; // pickMuni selector just for testing.
    self.navigationItem.rightBarButtonItem = favoritesItem;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];

    [_tableView registerClass:[DTSectionTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:200];
    
    _eventSections = [NSMutableArray array];
    _kidsAgeRanges = [NSMutableArray array];
    
    self.shyNavBarManager.scrollView = _tableView; // tableview inherits from scrollview class.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_didLoadInitially && [[UIApplication sharedApplication] isOnline]) {
        [self loadKidsEvents];
    }
}

#pragma mark - Actions

- (IBAction)favorites:(id)sender {
    [DanishTheater presentFavoritesFromViewController:self animated:YES completion:^(BOOL cancelled, NSString * _Nonnull selectedEventCode) {
        if (!cancelled) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEventCode];
            [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"KIDS_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
    }];
}

#pragma mark - Load Data

- (void)loadKidsEvents {
    
    __block NSError *ageRangesError = nil;
    __block NSError *eventsError = nil;
    
    // Create the dispatch group
    dispatch_group_t serviceGroup = dispatch_group_create();
    dispatch_group_enter(serviceGroup);
    
    [DTQuery queryKidsAgeRangesWithSuccess:^(NSArray<NSString *> *kidsAgeRanges) {
    
        if (kidsAgeRanges.count > 0) {
          
            [_kidsAgeRanges addObjectsFromArray:kidsAgeRanges];
            [DTQuery queryEventSectionsForKidsAtRanges:_kidsAgeRanges limitedToFirst:5 success:^(NSArray<NSArray<Event *> *> *eventSections) {
                
                _eventSections = [NSMutableArray arrayWithArray:eventSections];
                dispatch_group_leave(serviceGroup);
                
            } failure:^(NSError *error) {
                
                eventsError = error;
                dispatch_group_leave(serviceGroup);
            }];
        }
                
        else {
            // no content found scenario.
            dispatch_group_leave(serviceGroup);
        }
        
    } failure:^(NSError *error) {
        ageRangesError = error;
        dispatch_group_leave(serviceGroup);
    }];
 
    dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),^{
       
        NSError *overallError = nil;
        
        if (ageRangesError || eventsError)
        {
            // Either make a new error or assign one of them to the overall error
            overallError = ageRangesError ?: eventsError;
        }
        
        if (!overallError) {
            _didLoadInitially = true;
        } else {
            initialLoadingError = overallError;
        }
        
        [_tableView reloadData];
        
    });
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DTSectionTableViewCell *cell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
    cell.delegate = self;
    cell.showsSeeMoreItem = true;
    
    cell.headerTitle = [NSString stringWithFormat:@"%@ %@", [_kidsAgeRanges objectAtIndex:indexPath.row], NSLocalizedString(@"YEARS_SUFFIX_TEXT", nil)];
    [cell setItems:[_eventSections objectAtIndex:indexPath.row] ofModelClass:[Event class]];
    [cell setSeeMoreText:NSLocalizedString(@"SEE_MORE_TEXT", nil)];
     
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _didLoadInitially ? _eventSections.count : 0;
}

#pragma mark - DTSectionDelegate
- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSnippetWithIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger sectionIndex = [_tableView indexPathForCell:sectionTableViewCell].row;
    Event *selectedEvent = [[_eventSections objectAtIndex:sectionIndex] objectAtIndex:indexPath.row];
    
    DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEvent.code];
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSecondaryButtonWithIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[[_eventSections objectAtIndex:sectionTableViewCell.tag] objectAtIndex:indexPath.row] completionHandler:nil];
}

- (void)didSelectSeeMoreWithSectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell {
    
    NSUInteger sectionIndex = [_tableView indexPathForCell:sectionTableViewCell].row;
    NSString *sectionTitle = sectionTableViewCell.headerTextLabel.text;
    
    NSString *refPath = [NSString stringWithFormat:@"kids-event-snippets/%@", _kidsAgeRanges[sectionIndex]];
    DTEventsSectionViewController *eventsSectionVC = [[DTEventsSectionViewController alloc] initWithEventsReference:[[FIRDatabase database] referenceWithPath:refPath]];
    
    eventsSectionVC.title = sectionTitle;
    eventsSectionVC.tableViewCellStyle = DTTableViewCellStyleThumbnail;
    
    [self.navigationController pushViewController:eventsSectionVC animated:YES];
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
        [self loadKidsEvents];
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
