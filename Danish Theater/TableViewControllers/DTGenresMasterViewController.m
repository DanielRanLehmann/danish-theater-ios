//
//  DTGenresMasterViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/4/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTGenresMasterViewController.h"
#import "DTGenresDetailViewController.h"
#import "TLYShyNavBarManager.h"

#import "DTColorPalette.h" 
#import "DTQuery.h"
@import Firebase;

@interface DTGenresMasterViewController () {
    
    NSError *initialLoadingError;
}

@property (nonatomic, strong) FIRDatabaseReference *ref;
@property BOOL didLoadInitially;
@property (nonatomic, strong) NSArray <NSString *> *genres;

@end

@implementation DTGenresMasterViewController

#pragma mark - Initializers
- (instancetype)init {
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Genres Master"];
    if (self) {
        
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"GENRES_TITLE", nil);
    
    UIBarButtonItem *favoritesItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"FAVORITES_ITEM_TITLE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(favorites:)];
    self.navigationItem.rightBarButtonItem = favoritesItem;
    
    self.ref = [[FIRDatabase database] referenceWithPath:@"genres"];
    
    
    _didLoadInitially = false;
    initialLoadingError = nil;
    
    // Empty Data Set
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // issue with shynavbar when using it in a UITableViewController.
    // #11 https://github.com/telly/TLYShyNavBar/issues/11
    //self.shyNavBarManager.scrollView = self.tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadGenres];
    }
}

#pragma mark - Load Data
- (void)loadGenres {
    
    __block NSError *genresError = nil;
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    dispatch_group_enter(serviceGroup);
    [[DanishTheater sharedInstance] loadGenresWithSuccess:^(NSArray<NSString *> * _Nonnull genres) {
        
        if (genres.count <= 0) {
            // genres query is empty.. set a global bool?
        } else {
            _genres = [NSArray arrayWithArray:genres];
        }
        
        dispatch_group_leave(serviceGroup);

    } failure:^(NSError * _Nonnull error) {
        genresError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        NSError *overallError = genresError;
        if (!overallError) {
            _didLoadInitially = true;
        } else {
            initialLoadingError = genresError;
        }
        
        [self.tableView reloadData];
        
    });
}

#pragma mark - Actions

- (IBAction)favorites:(id)sender {
    [DanishTheater presentFavoritesFromViewController:self animated:YES completion:^(BOOL cancelled, NSString * _Nonnull selectedEventCode) {
        if (!cancelled) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEventCode];
            [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"GENRES_TITLE", nil) style:UIBarButtonItemStylePlain target:nil action:nil]];
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *genre = self.genres[indexPath.row];
        
        DTGenresDetailViewController *genresDetailVC = (DTGenresDetailViewController *)[[segue destinationViewController] topViewController];
        [genresDetailVC setGenreDetailItem:genre];
        genresDetailVC.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        genresDetailVC.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _genres.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.genres[indexPath.row].capitalizedString;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
        [self loadGenres];
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
