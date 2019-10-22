//
//  DTHomepageViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTHomepageViewController.h"
#import "TLYShyNavBarManager.h"

#import "DTCarouselTableViewCell.h"

#define DEFAULT_QUERY_LIMIT 25

#define STATIC_CELLS 5
#define DTGenreMasterRow 1
#define DTCalendarRow 2
#define DTMapRow 3
#define DTPodcastRow 4

#import "DTColorPalette.h"
#import "DTQuery.h"
@import Firebase;

#import "DTGenresMasterViewController.h" 
#import "DTCalendarViewController.h" 
#import "DTMapViewController.h" 

#import "DTEventsSectionViewController.h"

// #import "DTPodcastDetailViewController.h"

@interface DTHomepageViewController () <DTCarouselTableViewCellDelegate> {
    BOOL eventsQueryIsEmpty;
    NSError *initialLoadingError;
}

@property FIRDatabaseReference *ref;
@property BOOL didLoadInitially;

@property (nonatomic, strong) NSArray <NSString *> *shortcuts;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSString *lastEventCode;

@end

@implementation DTHomepageViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // self.title = NSLocalizedString(@"HOMEPAGE_TITLE", nil);
    self.navigationItem.title = NSLocalizedString(@"APP_NAME", nil);
    
    UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAVORITES_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(favorites:)];
    self.navigationItem.rightBarButtonItem = favoritesItem;
    
    _ref = [[FIRDatabase database] referenceWithPath:@"event-snippets"];
    
    
    _didLoadInitially = false;
    _lastEventCode = nil;
    eventsQueryIsEmpty = false;
    initialLoadingError = nil;
    
    _events = [NSMutableArray array];
    _shortcuts = @[NSLocalizedString(@"GENRES_SHORTCUT_TITLE", nil), NSLocalizedString(@"CALENDAR_SHORTCUT_TITLE", nil), NSLocalizedString(@"MAP_SHORTCUT_TITLE", nil), NSLocalizedString(@"PODCAST_SHORTCUT_TITLE", nil)]; // should be localized.
    
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
    
    [_tableView registerClass:[DTCarouselTableViewCell class] forCellReuseIdentifier:@"CarouselCell"];
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    // self.shyNavBarManager.scrollView = _tableView;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Lobster Two" size:20]};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBar.titleTextAttributes = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // could be dangerous.
    while (![[FIRAuth auth] currentUser]) {
        [self.tableView reloadData];
    }
    
    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadEvents];
    }
    
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
            
            Event *lastEvent = [_events lastObject];
            _lastEventCode = lastEvent.code;
        }
        
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        eventsError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        /* ONLY FOR TEST USE.
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Have you tried turning it off and on again?", nil)
                                   };
        NSError *overallError = [NSError errorWithDomain:NSURLErrorDomain
                                             code:-57
                                         userInfo:userInfo];
        
        */
        NSError *overallError = eventsError;
        
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
    
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[_events objectAtIndex:indexPath.row - STATIC_CELLS] completionHandler:nil];
}

- (IBAction)favorites:(id)sender {
    [DanishTheater presentFavoritesFromViewController:self animated:YES completion:^(BOOL cancelled, NSString * _Nonnull selectedEventCode) {
        if (!cancelled) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEventCode];
            [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOMEPAGE_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
    }];
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = DTTableViewCellStyleCoverRowHeight();
    
    if (indexPath.row == 0) {
        estimatedRowHeight = (142 + 8 + 12) + (2 * 16);
    }
    
    else if (indexPath.row >= 1 && indexPath.row <= 4) {
        estimatedRowHeight = 44.0f; // the "shortcuts"
    }
    
    else if (indexPath.row == self.events.count) {
        estimatedRowHeight = DTLoadingTableViewCellRowHeight;
    }
    
    return estimatedRowHeight;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return (142 + 8 + 12) + (2 * 16);
    }
    
    return 44.0f;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [_events count] > 0 ? STATIC_CELLS + [_events count] : 0;
    if (_didLoadInitially && eventsQueryIsEmpty != true) {
        numberOfRows += 1;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;

    if (indexPath.row == 0) {
        
        DTCarouselTableViewCell *carouselCell = [[DTCarouselTableViewCell alloc] initWithFrame:CGRectZero];
        carouselCell.delegate = self;
        
        [carouselCell addItemsWithImageUrls:@[[NSURL URLWithString:@"https://erling-christensen.dk/images/15354/KBNHVNTrianglenGrafisk_1024x1024-p.jpg"],
                                              [NSURL URLWithString:@"https://cdn.shopify.com/s/files/1/1176/1118/products/FRKSBRG_Zoo_tarnet._Grafisk.jpeg?v=1509548546"],
                                              [NSURL URLWithString:@"https://cdn.shopify.com/s/files/1/1176/1118/products/AARHUS_Aen.lowres._Grafisk.jpeg?v=1509548965"],
                                              [NSURL URLWithString:@"https://static.getdreamshop.dk/13/2/images/products/0/0/vissevasse-poster-aalborg-limfjordsbroen-limfjorden-6809163.jpeg"],
                                              [NSURL URLWithString:@"https://cdn.shopify.com/s/files/1/1176/1118/products/ODENSE_AEllingen.lowres.Grafisk.jpeg?v=1510925764"]]
                                   captions:@[@"Copenhagen", @"Frederiksberg", @"Aarhus", @"Aalborg", @"Odense"]];
        
        cell = carouselCell;
        
    } else if (indexPath.row >= 1 && indexPath.row <= 4) {
        
        UITableViewCell *shortcutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShortcutCell"];
        shortcutCell.textLabel.text = _shortcuts[(indexPath.row - 1)];
        shortcutCell.textLabel.textColor = self.view.tintColor;
        shortcutCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell = shortcutCell;
        
    } else {
        
         if (indexPath.row == self.events.count + STATIC_CELLS) {
         
             DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
             cell = loadingCell;
         
         } else {
         
             Event *event = [_events objectAtIndex:indexPath.row - STATIC_CELLS];
             
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
    }
    

    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (eventsQueryIsEmpty != true && indexPath.row == ([self.events count] + STATIC_CELLS) - 1) {
        [self loadEvents];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == DTGenreMasterRow) {
        DTGenresMasterViewController *genreMasterVC = [[DTGenresMasterViewController alloc] init];
        [self.navigationController pushViewController:genreMasterVC animated:YES];
    }
    
    else if (indexPath.row == DTCalendarRow) {
        DTCalendarViewController *calendarVC = [[DTCalendarViewController alloc] init];
        [self.navigationController pushViewController:calendarVC animated:YES];
    }
    
    else if (indexPath.row == DTMapRow) {
        DTMapViewController *mapVC = [[DTMapViewController alloc] init];
        [self.navigationController pushViewController:mapVC animated:YES];
    }
    
    else if (indexPath.row == DTPodcastRow) {
        /*
        DTPodcastDetailViewController *podcastDetailVC = [[DTPodcastDetailViewController alloc] initWithPodcastId:@"-L3eKv2jEUhKxlTJdo26"];
        [self.navigationController pushViewController:podcastDetailVC animated:YES];
        */
    }
    
    else {
    
        Event *event = [_events objectAtIndex:indexPath.row - STATIC_CELLS];
        DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:event.code];
        [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOMEPAGE_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
    }
}

#pragma mark - DTCarouselTableViewCellDelegate
- (void)carouselTableViewCell:(DTCarouselTableViewCell *)caoruselTableViewCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *selectedCity = [caoruselTableViewCell.captions objectAtIndex:indexPath.row];
    if ([selectedCity isEqualToString:@"Copenhagen"] || [selectedCity isEqualToString:@"København"]) {
        selectedCity = @"København K";
    }
    
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"organizationCity"] queryEqualToValue:selectedCity];
    DTEventsSectionViewController *eventsSectionVC = [[DTEventsSectionViewController alloc] initWithEventsQuery:query];
    
    if ([selectedCity isEqualToString:@"København K"]) {
        eventsSectionVC.prefixedSubsectionTexts = @[@"Nørrebro", @"Vesterbro", @"Østerbro", @"Indre København"];
        
        // only for testing purposes for now.
        NSString *refPath = @"kids-event-snippets/0-5";
        
        eventsSectionVC.prefixedSubsectionEventReferences = @[[[FIRDatabase database] referenceWithPath:refPath], [[FIRDatabase database] referenceWithPath:refPath], [[FIRDatabase database] referenceWithPath:refPath], [[FIRDatabase database] referenceWithPath:refPath]];
    }
    
    eventsSectionVC.title = selectedCity;
    eventsSectionVC.tableViewCellStyle = DTTableViewCellStyleCover;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
