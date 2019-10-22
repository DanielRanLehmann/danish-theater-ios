//
//  DTSearchViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTSearchViewController.h"

/*
#define DEFAULT_QUERY_LIMIT 25
#define TRIGGER_SEARCH_AFTER_TEXT_LENGTH 2

#define SEARCH_TEXT_THRESHOLD 3
*/


#define EVENT_INDEX_NAME @"dev_danish_theater_events"
#define PROFILES_INDEX_NAME @"dev_danish_theater_profiles"

@import AFNetworking;
@import AlgoliaSearch;
@import InstantSearchCore;

#import "Event.h"
#import "Organization.h"

#import "DTSearchResultsViewController.h"

#import <PureLayout/PureLayout.h>

@import Firebase;

#import "DTEventDetailViewController.h" 
#import "DTOrganizationDetailViewController.h"

#import "UIImage+Tint.h"

#import "DTColorPalette.h"
#import "DTQuery.h"

#import "DTSectionTableViewCell.h"
#import "DTInformationTableViewCell.h"

#import "NSString+Levenshtein.h" 

@interface DTSearchViewController () <SearcherDelegate, DTSectionTableViewCellDelegate, DTInformationTableViewCellDelegate> {
    CGFloat keyboardHeight;
    
    Client* client;
    Index *eventIndex;
    Searcher *eventSearcher;
    
    Index *profileIndex;
    Searcher *profileSearcher;
    
    NSMutableArray *events;
    NSMutableArray *organizations;
    
    NSError *searchResultError;
    
    BOOL shouldShowRecentSearchesInTableView;
    BOOL shouldShowTrendingEventsInTableView;
    BOOL shouldShowSearchResultsInTableView;
    
    BOOL didLoadInitially;
    
    BOOL didRecieveEventsResults;
    BOOL didRecieveProfilesResults;
    
    NSMutableArray *topEventScores;
    NSMutableArray *topOrganizationScores;
    
    id topResult; // can be either an event or an organization.
    
}

@property (strong, nonatomic) FIRStorage *storage;

@property (nonatomic, strong) FIRUser *user;

@property (strong, nonatomic) NSMutableArray <Event *> *trendingEvents;
@property (strong, nonatomic) NSMutableArray <SearchItem *> *recentSearches;

@end

@implementation DTSearchViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.title = NSLocalizedString(@"SEARCH_TITLE", nil);
}

#pragma mark - Configure

- (void)configureTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    _tableView.tableFooterView = [UIView new];
    
    _tableView.alpha = 1.0f;
    _tableView.tag = 0;
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTSectionTableViewCell class] forCellReuseIdentifier:@"SectionCell"];
    [_tableView registerClass:[DTInformationTableViewCell class] forCellReuseIdentifier:@"InfoCell"];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    searchResultError = nil;
    
    self.view.backgroundColor = [UIColor whiteColor]; // [UIColor colorWithRed:(239/255.0) green:(239/255.0) blue:(244/255.0) alpha:1.0];
    _storage = [FIRStorage storage];
    
    _user = [FIRAuth auth].currentUser;
    
    // Initialize Algolia Search.
    client = [[Client alloc] initWithAppID:@"GT4LQA7TYN" apiKey:@"00a3a06601a096f53057b836bbf7ca02"];
    
    // EVENTS
    eventIndex = [client indexWithName:EVENT_INDEX_NAME];
    eventSearcher = [[Searcher alloc] initWithIndex:eventIndex];
    eventSearcher.delegate = self;
    
    // Configure default search criteria.
    eventSearcher.params.hitsPerPage = @5;
    eventSearcher.params.getRankingInfo = @(true);
    eventSearcher.params.attributesToRetrieve = @[@"title.da", @"title.en", @"organizationName", @"organizationCode", @"organizationCity"];
    //eventSearcher.params.attributesToHighlight = @[@"localizedTitle"];
    
    // PROFILES
    profileIndex = [client indexWithName:PROFILES_INDEX_NAME];
    profileSearcher = [[Searcher alloc] initWithIndex:profileIndex];
    profileSearcher.delegate = self;
    
    // Configure default search criteria.
    profileSearcher.params.hitsPerPage = @5;
    profileSearcher.params.getRankingInfo = @(true);
    profileSearcher.params.attributesToRetrieve = @[@"name", @"city", @"postCode", @"municipality", @"region", @"generalManager", @"artisticDirector"];
    //eventSearcher.params.attributesToHighlight = @[@"localizedTitle"];
    
    // Reset data.
    events = [NSMutableArray array];
    organizations = [NSMutableArray array];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, 200, 37)];
    _searchBar.tintColor = DTPrimaryColor();
    _searchBar.showsCancelButton = false;
    
    _searchBar.delegate = self;
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.barTintColor = [UIColor lightGrayColor];
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_TITLE", nil);
    
    [self.navigationItem setTitleView:_searchBar];
    
    keyboardHeight = 0;
    
    // CONFIGURE THE TABLEVIEWS.
    _trendingEvents = [NSMutableArray array];
    _recentSearches = [NSMutableArray array];
    
    [self configureTableView];
    
    shouldShowTrendingEventsInTableView = true;
    shouldShowRecentSearchesInTableView = false;
    shouldShowSearchResultsInTableView = false;
    
    didLoadInitially = false;
    
    didRecieveEventsResults = false;
    didRecieveProfilesResults = false;
    
    
    // KEYBOARD NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    topEventScores = [NSMutableArray array];
    topOrganizationScores = [NSMutableArray array];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // check if trendingDidLoadInitially is false..
    if (!didLoadInitially && [[UIApplication sharedApplication] isOnline] && _user) {
        
        [self loadTrendingEventsWithCompletion:^(BOOL successful, NSError *error) {
            if (successful) {
                
                NSLog(@"did load trending events..");
                
                [self loadRecentSearchesForUserWithId:_user.uid completion:^(BOOL successful, NSError *error) {
                    NSLog(@"loading recent searches.");
                    
                    if (successful) {
                
                        didLoadInitially = true;
                        [_tableView reloadData];
                    }
                }];
            }
            
        }]; // make a completionhandler, and if success, loadRecentSearches -> then set didLoadInitially to true.
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Load Data
- (void)loadRecentSearchesForUserWithId:(NSString *)userId completion:(void (^)(BOOL successful, NSError *error))completion {
    
    FIRDatabaseReference *userRecentSearchesRef = [[[FIRDatabase database] referenceWithPath:@"user-recent-searches"] child:userId];
    [[[userRecentSearchesRef queryOrderedByChild:@"lastVisitAt"] queryLimitedToLast:20] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        // handle success.
        if (snapshot.exists) {
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                
                NSError *error = nil;
                SearchItem *item = [MTLJSONAdapter modelOfClass:SearchItem.class fromJSONDictionary:child.value error:&error];
                if (!error) {
                    item.searchItemId = child.key;
                    [_recentSearches addObject:item];
                }
            }
            
            _recentSearches = [NSMutableArray arrayWithArray:[[_recentSearches reverseObjectEnumerator] allObjects]];
        }
        
        completion(true, nil);
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        completion(false, error);
    }];
}


- (void)loadTrendingEventsWithCompletion:(void (^)(BOOL successful, NSError *error))completion {
    
    [DTQuery queryTrendingEventsLimitedToLast:50 success:^(NSArray<Event *> *trendingEvents) {
        
        if (trendingEvents.count <= 0) {
            // log error here.
        } else {
            [_trendingEvents addObjectsFromArray:trendingEvents];
        }
        completion(true, nil);
        
    } failure:^(NSError *error) {
        completion(false, error);
    }];
}


#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)notification {
    keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [_tableView reloadEmptyDataSet];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    keyboardHeight = 0; // [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [_tableView reloadEmptyDataSet];
}

#pragma mark - Actions

// this logic is incomplete and doesn't work.. hint: use tableview sections instead.
- (IBAction)more:(id)sender {
    
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (indexPath.section == 0) {
        [alertController presentFromViewController:self moreOptionsWithEvent:[events objectAtIndex:indexPath.row] completionHandler:nil];
    }
    
    else {
        [alertController presentFromViewController:self moreOptionsWithOrganization:[organizations objectAtIndex:indexPath.row]];
    }
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        return DTTableViewCellStyleThumbnailRowHeight();
    }
    
    return 200;
}

#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_searchBar resignFirstResponder];
}

#pragma mark - SearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:false animated:true];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (searchBar.text.length > 0) {
        return;
    }
    
    shouldShowTrendingEventsInTableView = false;
    shouldShowRecentSearchesInTableView = true;
    shouldShowSearchResultsInTableView = false;

    // _tableView.tableFooterView = nil;
    [_tableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    if (searchBar.text.length > 0) {
        return;
    }
    
    shouldShowTrendingEventsInTableView = true;
    shouldShowRecentSearchesInTableView = false;
    shouldShowSearchResultsInTableView = false;
    
    // _tableView.tableFooterView = nil;
    [_tableView reloadData];

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:true animated:true];
    return true;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:false animated:true];
    return true;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:false animated:true];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText length] == 0) {
        
        shouldShowTrendingEventsInTableView = false;
        shouldShowRecentSearchesInTableView = true;
        shouldShowSearchResultsInTableView = false;
        
        topResult = nil;
        events = [NSMutableArray array];
        organizations = [NSMutableArray array];
        
        // _tableView.tableFooterView = nil;
        [_tableView reloadData];
        
        return; // required?
    }
    
    shouldShowTrendingEventsInTableView = false;
    shouldShowRecentSearchesInTableView = false;
    shouldShowSearchResultsInTableView = true;
    
    //_tableView.tableFooterView = [self algoliaTableViewFooter];
    
    eventSearcher.params.query = searchText;
    [eventSearcher search];
    
    profileSearcher.params.query = searchText;
    [profileSearcher search];

}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    if (shouldShowTrendingEventsInTableView) {
        numberOfRows = (_trendingEvents.count > 0) ? 1 : 0;
        
    } else if (shouldShowRecentSearchesInTableView) {
        numberOfRows = ([_recentSearches count] > 0 ? 1 : 0);
        
    } else {
        NSInteger topResultRow = ([events count] > 0 || [organizations count] > 0 ? 1 : 0);
        numberOfRows = topResultRow + ([events count] > 0 ? 1 : 0) + ([organizations count] > 0 ? 1 : 0);
    }
    
    return numberOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
        
    if (shouldShowTrendingEventsInTableView) {
    
        DTSectionTableViewCell *trendingSectionCell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
        trendingSectionCell.delegate = self;
        
        trendingSectionCell.headerTitle = @"Trending";
        [trendingSectionCell setItems:_trendingEvents ofModelClass:[Event class]];
        
        cell = trendingSectionCell;
        
    } else if (shouldShowRecentSearchesInTableView) {
        
        DTInformationTableViewCell *recentSearchesCell = [[DTInformationTableViewCell alloc] initWithFrame:CGRectZero];
        recentSearchesCell.delegate = self;
        
        recentSearchesCell.headerTextLabel.text = @"Recent Searches";
        
        NSMutableArray <NSDictionary *> *items = [NSMutableArray array];
        
        for (SearchItem *item in _recentSearches) {
        
            [items addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeReveal),
                                @"Text" : item.title[@"da"],
                                @"TextLabelColor": [UIColor blackColor]
                                }];
        
        }
        
        [items addObject:@{
                            @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                            @"Text" : NSLocalizedString(@"CLEAR_ALL_ITEM_TITLE", nil),
                            @"TextLabelColor": self.view.tintColor
                            }];
        
        
        [recentSearchesCell setPieces:items];
        cell = recentSearchesCell;
        
    } else if (shouldShowSearchResultsInTableView) {
        
        if (indexPath.row == 0) {
            
            // NSInteger topEventScoreValue = INFINITY;
            // NSInteger topOrganizationScoreValue = INFINITY;
            
            NSDictionary *topEventScore = nil;
            NSDictionary *topOrganizationScore = nil;
            
            if (events.count > 0 && topEventScores.count > 0) {
                topEventScore = [NSDictionary dictionaryWithDictionary:topEventScores[0]];
                // topEventScoreValue = [[topEventScore objectForKey:@"score"] integerValue];
            }
            
            if (organizations.count > 0 && topOrganizationScores.count > 0) {
                topOrganizationScore = [NSDictionary dictionaryWithDictionary:topOrganizationScores[0]];
                // topOrganizationScoreValue = [[topOrganizationScore objectForKey:@"score"] integerValue];
            }
            
            if (events.count > 0 && ((topEventScore && !topOrganizationScore) || ([[topEventScore objectForKey:@"score"] integerValue] < [[topOrganizationScore objectForKey:@"score"] integerValue]))) { // pick event score
                
                NSString *topScoreCode = topEventScore[@"code"];
                NSUInteger topScoreResultIndex = [topEventScore[@"resultIndex"] unsignedIntegerValue];
                
                Event *candEvent = [events objectAtIndex:topScoreResultIndex];
                if ([candEvent.code isEqualToString:topScoreCode]) {
                    topResult = candEvent;
                }
                
            } else if (organizations.count > 0 && ((!topEventScore && topOrganizationScore) || ([[topEventScore objectForKey:@"score"] integerValue] > [[topOrganizationScore objectForKey:@"score"] integerValue]))) { // pick organization score.
                
                NSString *topScoreCode = topOrganizationScore[@"code"];
                NSUInteger topScoreResultIndex = [topOrganizationScore[@"resultIndex"] unsignedIntegerValue];
                
                Organization *candOrganization = [organizations objectAtIndex:topScoreResultIndex];
                if ([candOrganization.code isEqualToString:topScoreCode]) {
                    topResult = candOrganization;
                }
                
            } // account for even scores?

            DTSectionTableViewCell *topResultSectionCell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
            topResultSectionCell.tag = [topResult class] == [Event class] ? 0 : 1;
            topResultSectionCell.delegate = self;
            
            topResultSectionCell.headerTitle = NSLocalizedString(@"Top Result", nil);
            [topResultSectionCell setItems:@[topResult] ofModelClass:[topResult class]];
            
            cell = topResultSectionCell;
        }
        
        else if (indexPath.row == 1) { // EVENTS
            
            DTSectionTableViewCell *eventsSearchResultSectionCell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
            eventsSearchResultSectionCell.tag = 0;
            eventsSearchResultSectionCell.delegate = self;
            
            if (events.count == 5) {
                eventsSearchResultSectionCell.showsSeeMoreItem = true;
                [eventsSearchResultSectionCell setSeeMoreText:NSLocalizedString(@"SEE_MORE_RESULTS_TEXT", nil)];
            }
            
            eventsSearchResultSectionCell.headerTitle = NSLocalizedString(@"SEARCH_EVENTS_HEADER_SECTION_TITLE", nil);
            [eventsSearchResultSectionCell setItems:events ofModelClass:[Event class]];
            
            
            cell = eventsSearchResultSectionCell;
            
        } else { // PROFILES
            
            DTSectionTableViewCell *profilesSearchResultSectionCell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
            profilesSearchResultSectionCell.tag = 1;
            profilesSearchResultSectionCell.delegate = self;
            
            if (organizations.count == 5) {
                profilesSearchResultSectionCell.showsSeeMoreItem = true;
                [profilesSearchResultSectionCell setSeeMoreText:NSLocalizedString(@"SEE_MORE_RESULTS_TEXT", nil)];
            }
            
            profilesSearchResultSectionCell.headerTitle = NSLocalizedString(@"SEARCH_ORGANIZATIONS_HEADER_SECTION_TITLE", nil);
            [profilesSearchResultSectionCell setItems:organizations ofModelClass:[Organization class]];
            
            cell = profilesSearchResultSectionCell;
        }
    
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (IBAction)openAlgoliaWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.algolia.com"] options:@{} completionHandler:nil];
}

#pragma mark - DTSectionTableViewCellDelegate
- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSnippetWithIndexPath:(NSIndexPath *)indexPath {
    
    if (sectionTableViewCell.tag == 0) {
        
        Event *selectedEvent = nil;
        if (shouldShowTrendingEventsInTableView) {
            selectedEvent = [_trendingEvents objectAtIndex:indexPath.row];
            
        } else if (shouldShowSearchResultsInTableView) {
            selectedEvent = [events objectAtIndex:indexPath.row];
        }
        
        
        if (_user) {
        
            [self searchItemExistsWthContentId:selectedEvent.code forUserWithId:_user.uid completion:^(BOOL exists, SearchItem *item) {
                
                SearchItem *_item = nil;
                if (exists) {
                    
                    _item = item;
                    _item.title = selectedEvent.title;
                    _item.visitCount += 1;
                    _item.lastVisitAt = [[NSDate date] timeIntervalSince1970];
                    
                } else {
                    // before push.. communicate with the db, update || add a searchItem to a users recent-searches.
                    _item = [[SearchItem alloc] init];
                    _item.lastVisitAt = [[NSDate date] timeIntervalSince1970];
                    _item.title = selectedEvent.title;
                    _item.visitCount = 1;
                    _item.contentId = selectedEvent.code;
                    _item.contentType = DTSearchItemContentTypeEvent;
                }
                
                [self writeSearchItem:_item toRecentSearchesOfUserWithId:_user.uid];
                
            }];
        }
        
        
        DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEvent.code];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
        
    } else if (sectionTableViewCell.tag == 1) {
        
        Organization *selectedOrganization = [organizations objectAtIndex:indexPath.row];
        DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:selectedOrganization.code];
        [self.navigationController pushViewController:organizationDetailVC animated:YES];
        
    }
}

- (void)writeSearchItem:(SearchItem *)searchItem toRecentSearchesOfUserWithId:(NSString *)userId {

    NSError *error = nil;
    NSMutableDictionary *searchItemValue = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:searchItem error:&error]];
    
    if (error) {
        NSLog(@"oops.. an error occurred: %@", error);
        return;
    }
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRDatabaseReference *userRecentSearchesRef = [[ref child:@"user-recent-searches"] child:userId];
    FIRDatabaseReference *searchItemRef = nil;
    
    NSString *searchItemId = nil;
    
    if (searchItemValue[@"searchItemId"]) {
        searchItemId = searchItemValue[@"searchItemId"];
        [searchItemValue removeObjectForKey:@"searchItemId"];
    }
    
    if (![searchItemId isEqual:[NSNull null]]) {
        searchItemRef = [userRecentSearchesRef child:searchItemId];
    } else {
        searchItemRef = [userRecentSearchesRef childByAutoId];
    }

    [searchItemRef setValue:searchItemValue withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        [_recentSearches insertObject:searchItem atIndex:0];
    }];
    
}

- (void)searchItemExistsWthContentId:(NSString *)contentId forUserWithId:(NSString *)userId completion:(void (^)(BOOL exists, SearchItem *item))completion {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"user-recent-searches"] child:userId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            SearchItem *foundItem = nil;
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                if ([child.value[@"contentId"] isEqualToString:contentId]) {
                    
                    NSError *error = nil;
                    foundItem = [MTLJSONAdapter modelOfClass:SearchItem.class fromJSONDictionary:child.value error:&error];
                    if (!error) {
                        foundItem.searchItemId = child.key;
                    }
                    break;
                }
            }
            
            completion(foundItem != nil ? true : false, foundItem);
            
        } else {
            completion(false, nil);
        }
    }];
}

- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSecondaryButtonWithIndexPath:(NSIndexPath *)indexPath {

    if (sectionTableViewCell.tag == 0) { // EVENTS
        
        Event *selectedEvent = nil;
        if (shouldShowTrendingEventsInTableView) {
            selectedEvent = [_trendingEvents objectAtIndex:indexPath.row];
        
        } else if (shouldShowSearchResultsInTableView) {
            selectedEvent = [events objectAtIndex:indexPath.row];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController presentFromViewController:self moreOptionsWithEvent:selectedEvent completionHandler:nil];
        
    } else if (sectionTableViewCell.tag == 1) { // PROFILES
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController presentFromViewController:self moreOptionsWithOrganization:[organizations objectAtIndex:indexPath.row]];
    }
    
}

- (void)didSelectSeeMoreWithSectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell {

    DTSearchResultType searchResultType = DTSearchResultTypeEvent;
    if (sectionTableViewCell.tag == 1) {
        searchResultType = DTSearchResultTypeOrganization;
        
    }
    
    DTSearchResultsViewController *searchResultsVC = [[DTSearchResultsViewController alloc] initWithQueryText:_searchBar.text resultType:searchResultType];
    [self.navigationController pushViewController:searchResultsVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (UIView *)algoliaTableViewFooter {
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 42 + (2 * 8))];
    UIButton *algoliaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [algoliaBtn setImage:[[UIImage imageNamed:@"search-by-algolia-white"] tintedImageWithColor:[UIColor colorWithHex:@"#9E9E9E"]] forState:UIControlStateNormal];
    
    [algoliaBtn setFrame:containerView.bounds];
    algoliaBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [algoliaBtn addTarget:self action:@selector(openAlgoliaWebsite:) forControlEvents:UIControlEventTouchUpInside];
    
    [containerView addSubview:algoliaBtn];
    
    return containerView;
}

#pragma mark - SearcherDelegate

- (void)searcher:(Searcher *)searcher didReceiveResults:(SearchResults *)results error:(NSError *)error forParams:(SearchParameters *)params {
    
    if (error != nil) {
        searchResultError = error;
        return;
    }
    
    // Decode JSON.
    NSArray *hits = [results hits];
    NSMutableArray *tmp = [NSMutableArray array];
    NSMutableArray *tmpScores = [NSMutableArray array];
    
    if ([searcher.index.name isEqualToString:EVENT_INDEX_NAME]) {
        
        for (int i = 0; i < [hits count]; ++i) {
            
            Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:hits[i] error:nil];
            if (event) {
                event.code = hits[i][@"objectID"];
                [tmp addObject:event];
                
                NSInteger score = [results rankingInfoAt:i].userScore; //[_searchBar.text levenshteinDistanceTo:event.localizedTitle]; // [_searchBar.text compareWithString:event.localizedTitle matchGain:10 missingCost:1];
                [tmpScores addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:score], @"score", event.code, @"code", [NSNumber numberWithUnsignedInteger:i], @"resultIndex", nil]];
            }
        }
        
        // Reload view with the new data.
        if (results.page == 0) {
            [events removeAllObjects];
            [topEventScores removeAllObjects];
        }
        
        didRecieveEventsResults = true;
        [events addObjectsFromArray:tmp];
        // [topEventScores addObjectsFromArray:tmpScores];
        topEventScores = [NSMutableArray arrayWithArray:[tmpScores sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
            return [[obj1 valueForKey:@"score"] compare:[obj2 valueForKey:@"score"]];
        }]];
        
        // Scroll to top if not a "load more".
        if (results.page == 0) {
            self.tableView.contentOffset = CGPointZero;
        }
        
        
    } else if ([searcher.index.name isEqualToString:PROFILES_INDEX_NAME]) {
        
        for (int i = 0; i < [hits count]; ++i) {
            
            Organization *organization = [MTLJSONAdapter modelOfClass:Organization.class fromJSONDictionary:hits[i] error:nil];
            if (organization) {
                organization.code = hits[i][@"objectID"];
                [tmp addObject:organization];
                
                NSInteger score = [results rankingInfoAt:i].userScore; // [_searchBar.text levenshteinDistanceTo:organization.name]; // [_searchBar.text compareWithString:organization.code matchGain:10 missingCost:1];
                [tmpScores addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:score], @"score", organization.code, @"code", [NSNumber numberWithUnsignedInteger:i], @"resultIndex", nil]];
            }
        }
        
        // Reload view with the new data.
        if (results.page == 0) {
            [organizations removeAllObjects];
            [topOrganizationScores removeAllObjects];
        }
        
        didRecieveProfilesResults = true;
        [organizations addObjectsFromArray:tmp];
        //[topOrganizationScores addObjectsFromArray:tmpScores];
        
        topOrganizationScores = [NSMutableArray arrayWithArray:[tmpScores sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
            return [[obj1 valueForKey:@"score"] compare:[obj2 valueForKey:@"score"]];
        }]];
        
        // Scroll to top if not a "load more".
        if (results.page == 0) {
            self.tableView.contentOffset = CGPointZero;
        }
    }
    
    if (didRecieveEventsResults && didRecieveProfilesResults) {
        [self.tableView reloadData];
    }
}

- (void)handleTopResult {

    // events and profiles have been fetched.
    topResult = nil;
    
    NSMutableArray *topResultScores = [NSMutableArray arrayWithArray:topEventScores];
    [topResultScores addObjectsFromArray:topOrganizationScores];
    
    topResultScores = [NSMutableArray arrayWithArray:[topResultScores sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
        return [[obj1 valueForKey:@"score"] compare:[obj2 valueForKey:@"score"]];
    }]];
    
    if (topResultScores.count > 0) {
        
        NSDictionary *topScore = [topResultScores firstObject];
        NSLog(@"topResult scores:\n%@", topResultScores);
        
        NSString *topScoreCode = topScore[@"code"];
        int i = 0;
        while (!topResult) {
            
            if ([topScoreCode hasPrefix:@"EV"]) {
                
                Event *candEvent = [events objectAtIndex:i];
                if ([candEvent.code isEqualToString:topScoreCode]) {
                    topResult = candEvent;
                    break;
                }
                
            } else if ([topScoreCode hasPrefix:@"OR"]) {
                
                Organization *candOrganization = [organizations objectAtIndex:i];
                if ([candOrganization.code isEqualToString:topScoreCode]) {
                    topResult = candOrganization;
                    break;
                }
            }
            
            i++;
        }
    }
    
    didRecieveEventsResults = false;
    didRecieveProfilesResults = false;
}

#pragma mark - DZNEmptyDataSetSource

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    
    if (self.emptyDataSetState == DTEmptyDataSetStateLoading) {
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        return activityView;
    }
    
    return nil;
}

/*
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -keyboardHeight;
}
*/

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_TITLE", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_SEARCH_RESULTS_FOUND_EMPTY_DATA_SET_TITLE", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateAnErrorOccurred) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_TITLE", nil)];
    }
    
    return nil;
    
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_SEARCH_RESULTS_FOUND_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
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

- (DTEmptyDataSetState)emptyDataSetState {
    
    // if ( _searchBar.text.length > 0) {
    
        if ([[UIApplication sharedApplication] isOnline]) {
            
            if ((shouldShowTrendingEventsInTableView || shouldShowSearchResultsInTableView) && !didLoadInitially && !searchResultError) {
                return DTEmptyDataSetStateLoading;
            }
            
            else if (searchResultError) {
                return DTEmptyDataSetStateAnErrorOccurred;
            } else {
                return DTEmptyDataSetStateNoContent; // DTEmptyDataSetStateLoading;
            }
            
        } else if ([[UIApplication sharedApplication] isOffline]) {
            return DTEmptyDataSetStateOffline;
        }
    
    // }
    
    return DTEmptyDataSetStateUndefined;
}

#pragma mark - EmptyDataSetDelegate
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    if (self.emptyDataSetState != DTEmptyDataSetStateOffline) {
        [self loadTrendingEventsWithCompletion:^(BOOL successful, NSError *error) {
            // handle succes..
        }];
    }
    
}

#pragma mark - DZNEmptyDataSetDelegate

/* HANDFUL OF ISSUES WITH THIS DELEGATE METHOD: https://github.com/dzenbot/DZNEmptyDataSet/issues?utf8=%E2%9C%93&q=didTapView

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
 return YES;
}
 
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [_searchBar resignFirstResponder];
}
 
*/


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
