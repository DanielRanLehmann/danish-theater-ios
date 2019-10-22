//
//  DTSearchResultsViewController.m
//  DTSearchTest
//
//  Created by Daniel Ran Lehmann on 11/16/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTSearchResultsViewController.h"
#import "TLYShyNavBarManager.h"

#define EVENT_INDEX_NAME @"dev_danish_theater_events"
#define PROFILES_INDEX_NAME @"dev_danish_theater_profiles"

@import AFNetworking;
@import AlgoliaSearch;
@import InstantSearchCore;

#import <PureLayout/PureLayout.h>

#import "Event.h"
#import "Organization.h"

#import "DTTableViewCell.h" 
#import "UIAlertController+Helpers.h"

#import "DTEventDetailViewController.h"
#import "DTOrganizationDetailViewController.h"

@import Firebase;

@interface DTSearchResultsViewController () <SearcherDelegate> {
    
    Client* client;
    Index *index;
    Searcher *searcher;
    
    NSMutableArray *searchResults; // come up with a better name?
    
}

@property (strong, nonatomic) FIRStorage *storage;

@end

@implementation DTSearchResultsViewController

- (instancetype)initWithQueryText:(NSString *)queryText resultType:(DTSearchResultType)searchResultType {
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Search Results"];
    if (self) {
        _queryText = queryText;
        _searchResultType = searchResultType;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"%@", _queryText];
    _storage = [FIRStorage storage];
    
    // CREATE TABLEVIEW
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    self.shyNavBarManager.scrollView = _tableView; // tableview inherits from scrollview class.
    
    // Initialize Algolia Search.
    client = [[Client alloc] initWithAppID:@"GT4LQA7TYN" apiKey:@"00a3a06601a096f53057b836bbf7ca02"];
    
    switch (_searchResultType) {
        case DTSearchResultTypeEvent:
        {
            index = [client indexWithName:EVENT_INDEX_NAME];
        }
            break;
            
        case DTSearchResultTypeOrganization:
        {
            index = [client indexWithName:PROFILES_INDEX_NAME];
        }
            break;
            
    }
    
    searcher = [[Searcher alloc] initWithIndex:index];
    searcher.delegate = self;
    
    // Configure default search criteria.
    searcher.params.hitsPerPage = @15;
    
    switch (_searchResultType) {
        case DTSearchResultTypeEvent:
        {
                searcher.params.attributesToRetrieve = @[@"title.da", @"title.en", @"organizationName", @"organizationCode", @"organizationCity"];
        }
            break;
            
        case DTSearchResultTypeOrganization:
        {
            searcher.params.attributesToRetrieve = @[@"name", @"city", @"postCode", @"municipality", @"region", @"generalManager", @"artisticDirector"];
        }
            break;
    }
    
    // RESET DATA
    searchResults = [NSMutableArray array];
    
    // SEARCH
    searcher.params.query = _queryText;
    [searcher search];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - Actions

- (IBAction)more:(id)sender {
    
    DTTableViewCell *selectedCell = (DTTableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (_searchResultType == DTSearchResultTypeEvent) {
        [alertController presentFromViewController:self moreOptionsWithEvent:[searchResults objectAtIndex:indexPath.row] completionHandler:nil];
    } else {
        [alertController presentFromViewController:self moreOptionsWithOrganization:[searchResults objectAtIndex:indexPath.row]];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && searchResults.count > 0) {
        return searchResults.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DTTableViewCellStyleThumbnailRowHeight();
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row + 5 >= [searchResults count]) {
        [searcher loadMore];
    }
    
    switch (_searchResultType) {
        case DTSearchResultTypeEvent:
        {
            
            Event *event = [searchResults objectAtIndex:indexPath.row];
            
            DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            eventCell.style = DTTableViewCellStyleThumbnail;
            eventCell.fallbackImageURL = [NSURL terebaImageURLWithCode:event.code orientaion:TerebaImageOrientationLandscape];
            eventCell.imageRef = event.thumbnail.highImageRef;
            
            eventCell.title = event.localizedTitle; // event.localizedTitle;
            
            eventCell.contentDescriptions = @[event.organizationName, event.organizationCity]; // [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]
            
            cell = eventCell;
            
        }
            break;
            
        case DTSearchResultTypeOrganization:
        {
            
            Organization *organization = [searchResults objectAtIndex:indexPath.row];
            
            DTTableViewCell *organizationCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [organizationCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            organizationCell.style = DTTableViewCellStyleThumbnail;
            organizationCell.fallbackImageURL = [NSURL terebaImageURLWithCode:organization.code orientaion:TerebaImageOrientationLandscape];
            organizationCell.imageRef = organization.thumbnail.highImageRef;
            
            organizationCell.title = organization.name; // organization.name;
            organizationCell.contentDescriptions = @[organization.city];
            
            cell = organizationCell;
        }
            break;
            
        default:
            break;
    }
    
    [cell updateConstraints];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_searchResultType == DTSearchResultTypeEvent) {
        
        Event *event = searchResults[indexPath.row];
        DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:event.code];
        [self.navigationController pushViewController:eventDetailVC animated:YES];
        
    } else { // DTSearchResultTypeOrganization
        
        Organization *organization = searchResults[indexPath.row];
        DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:organization.code];
        [self.navigationController pushViewController:organizationDetailVC animated:YES];
    }
}

#pragma mark - SearcherDelegate
- (void)searcher:(Searcher *)searcher didReceiveResults:(SearchResults *)results error:(NSError *)error forParams:(SearchParameters *)params {
    if (error != nil) {
        return;
    }
    
    // Decode JSON.
    NSArray *hits = [results hits];
    NSMutableArray *tmp = [NSMutableArray array];
    
    for (int i = 0; i < [hits count]; ++i) {
        
        switch (_searchResultType) {
            case DTSearchResultTypeEvent:
            {
                Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:hits[i] error:nil];
                if (event) {
                    event.code = hits[i][@"objectID"];
                    [tmp addObject:event];
                }
            }
                break;
                
            case DTSearchResultTypeOrganization:
            {
                Organization *organization = [MTLJSONAdapter modelOfClass:Organization.class fromJSONDictionary:hits[i] error:nil];
                if (organization) {
                    organization.code = hits[i][@"objectID"];
                    [tmp addObject:organization];
                }
            }
                break;
                
            default:
                break;
        }
    }
    
    // Reload view with the new data.
    if (results.page == 0) {
        [searchResults removeAllObjects];
    }
    [searchResults addObjectsFromArray:tmp];
    [self.tableView reloadData]; // reload specific section => 0
    
    // Scroll to top if not a "load more".
    if (results.page == 0) {
        self.tableView.contentOffset = CGPointZero;
    }

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
