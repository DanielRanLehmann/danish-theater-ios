//
//  DTOrganizationDetailViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/13/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTOrganizationDetailViewController.h"
//#import <TLYShyNavBar/TLYShyNavBarManager.h>

#import "Event.h" 
#import "Venue.h" 
#import "Show.h"

#import "DTOrganizationDetailTableHeaderView.h"
#import "UITableView+DetectFloatingHeader.h" 

#import <SDWebImage/UIImageView+WebCache.h>

#import "DTColorPalette.h"
#import "DTQuery.h"
@import Firebase;

#define DEFAULT_QUERY_LIMTIT 25
#define NUMBER_OF_STATIC_ABOUT_CELLS 6

@interface DTOrganizationDetailViewController () {
    
    BOOL shouldExpand;
    BOOL isTopSectionHeaderSticky;
    
    BOOL showsQueryIsEmpty;
    BOOL eventsQueryIsEmpty;
    
    BOOL organizationNotFound;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic, strong) Organization *organization;

@property (nonatomic, strong) NSMutableArray *shows;
@property (nonatomic, strong) NSMutableArray <NSString *> *months;

@property (nonatomic, strong) NSMutableArray <Event *> *events;
@property (nonatomic, strong) NSMutableArray <Venue *> *venues;

@property (nonatomic, getter=isDescriptionTextExpanded) BOOL descriptionTextExpanded;
@property NSMutableArray <NSNumber *> *didLoadInitializers;

@property (nonatomic, strong) DTOrganizationDetailTableHeaderView *headerView;

@property (nonatomic) NSTimeInterval lastShowTimestamp;
@property (nonatomic, strong) FIRDatabaseReference *showsRef;

@property (nonatomic, strong) NSString *lastEventCode;
@property (nonatomic, strong) FIRDatabaseReference *eventsRef;

@property DTEmptyDataSetState emptyDataSetState;

@end

@implementation DTOrganizationDetailViewController

#pragma mark - StatusBar Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Initializers

- (instancetype)initWithCode:(NSString *)organizationCode {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self = [storyboard instantiateViewControllerWithIdentifier:@"Organization Detail"];
    if (self) {
        self.organizationCode = organizationCode;
    }
    
    return self;
}

#pragma mark - Setters

- (void)setOrganizationCode:(NSString *)organizationCode {
    _organizationCode = organizationCode;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ref = [[FIRDatabase database] reference];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_UPCOMING", nil), NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_EVENTS", nil), NSLocalizedString(@"SEGMENTED_CONTROL_ITEM_TITLE_OTHER", nil)]];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    
    _shows = [NSMutableArray array];
    _events = [NSMutableArray array];
    _venues = [NSMutableArray array];
    
    _didLoadInitializers = [NSMutableArray arrayWithArray:@[@(0), @(0), @(0)]];
     
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    
    [self.navigationItem setRightBarButtonItem:share];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:200];
    
    _headerView = [[DTOrganizationDetailTableHeaderView alloc] init];
    _headerView.imageView.backgroundColor = [UIColor colorWithHex:@"#E0E0E0"];
    [_headerView updateConstraints];
    _tableView.tableHeaderView = nil;
    
    [_tableView registerClass:[DTTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView registerClass:[DTLoadingTableViewCell class] forCellReuseIdentifier:@"Loading Cell"];
    [_tableView registerClass:[DTInformationTableViewCell class] forCellReuseIdentifier:@"Information Cell"];
    [_tableView registerClass:[DTDescriptionTableViewCell class] forCellReuseIdentifier:@"Description Cell"];
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    _tableView.tableFooterView = [UIView new];
    
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    _descriptionTextExpanded = NO;
    
    _lastShowTimestamp = [[NSDate date] timeIntervalSince1970];
    _showsRef = [_ref child:[NSString stringWithFormat:@"organization-shows/%@", _organizationCode]];
    
    showsQueryIsEmpty = false;
    eventsQueryIsEmpty = false;
    
    organizationNotFound = true;
    
    _lastEventCode = nil;
    _eventsRef = [_ref child:[NSString stringWithFormat:@"organization-events/%@", _organizationCode]];
    
    //self.shyNavBarManager.scrollView = _tableView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![_didLoadInitializers containsObject:@(1)] && [[UIApplication sharedApplication] isOnline]) {
        [self loadData];
    } else {
        NSLog(@"user is offline..");
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    shouldExpand = NO;
}

#pragma mark - Load Data

- (void)loadData {
    
    [DTQuery loadSingleOrganizationWithCode:_organizationCode success:^(Organization *organization) {
        
        if (organization) {
            
            organizationNotFound = false;
            
            _organization = organization;
            [self configureHeaderView];
            
            switch (_segmentedControl.selectedSegmentIndex) {
                case 0:
                    [self loadShows];
                    break;
                    
                case 1:
                    [self loadEvents];
                    break;
                    
                case 2:
                    [self loadVenues];
                    break;
            }
            
            
            [FIRAnalytics logEventWithName:kFIREventViewItem
                                parameters:@{
                                             kFIRParameterItemID:_organization.code,
                                             kFIRParameterItemName:_organization.name,
                                             kFIRParameterContentType:@"organization"
                                             }];
            
            [_tableView reloadData];
            _tableView.tableHeaderView = _headerView;
            
        } else {
            organizationNotFound = true;
            
            // hack to make the EMPTYDATASET dissappear.
            
            _didLoadInitializers[_segmentedControl.selectedSegmentIndex] = @(true);
            
            [self.tableView reloadEmptyDataSet];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"ORGANIZATION_NOT_FOUND_DATA_SET_DESCRIPTION", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
            [alertController addAction:okAction];
            
            
            [self presentViewController:alertController animated:YES completion:nil];

        }
        
    } failure:^(NSError *error) {
       
        // hack to make the EMPTYDATASET dissappear.
        _didLoadInitializers[_segmentedControl.selectedSegmentIndex] = @(true);
        [self.tableView reloadEmptyDataSet];
        
        // An Error Occurred.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_TITLE", nil) message:NSLocalizedString(@"ORGANIZATION_NOT_FOUND_DATA_SET_DESCRIPTION", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)loadEvents {
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    [DTQuery loadEventsWithReferencePath:_eventsRef startingWithCode:_lastEventCode limitedToFirst:DEFAULT_QUERY_LIMTIT success:^(NSArray<Event *> *events) {
        
        if (events.count <= 0) {
            eventsQueryIsEmpty = true;
        
        } else {
        
            [_events addObjectsFromArray:events];
            
            Event *lastEvent = [_events lastObject];
            _lastEventCode = lastEvent.code;
        }
        
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        // handle failure
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        [_didLoadInitializers replaceObjectAtIndex:1 withObject:@(1)];
        [_tableView reloadData];

    });
}

- (void)loadShows {
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    [DTQuery loadShowsWithReferencePath:_showsRef includeMonths:NO startingWithTimestamp:_lastShowTimestamp+1 limitedToFirst:DEFAULT_QUERY_LIMTIT success:^(NSString * _Nonnull startingCode, NSArray<NSString *> * _Nonnull months, NSArray * _Nonnull shows) {
        
        if (shows.count <= 0) {
            showsQueryIsEmpty = true;
        } else {
        
            [_shows addObjectsFromArray:shows];
            
            Show *lastShow = (Show *)[shows lastObject];
            _lastShowTimestamp = lastShow.timestamp;
        }
        
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError * _Nonnull error) {
        // handle failure.
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        [_didLoadInitializers replaceObjectAtIndex:0 withObject:@(1)];
        [self.tableView reloadData];
    });
}

- (void)loadVenues {
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    if ([_didLoadInitializers[2] isEqual:@(0)] && _organization.venueCodes.count > 0) {
        
        // START THE FIRST SERVICE.
        dispatch_group_enter(serviceGroup);
        
        for (int i = 0; i < _organization.venueCodes.count; i++) {
            
            [DTQuery loadSingleVenueWithCode:_organization.venueCodes[i] success:^(Venue *venue) {
                
                [_venues addObject:venue];
                
                if (i == _organization.venueCodes.count - 1) {
                    dispatch_group_leave(serviceGroup);
                }
                
            } failure:^(NSError *error) {
                // handle failure.
                dispatch_group_leave(serviceGroup);
            }];
        }
        
        dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
            [_didLoadInitializers replaceObjectAtIndex:2 withObject:@(1)];
            [_tableView reloadData];
        });
    }
}

#pragma mark - Convenience Methods

- (void)sizeHeaderToFit
{
    UIView *header = self.tableView.tableHeaderView;
    
    [header setNeedsLayout];
    [header layoutIfNeeded];
    
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = header.frame;
    
    frame.size.height = height;
    header.frame = frame;
    
    self.tableView.tableHeaderView = header;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self sizeHeaderToFit];
}

- (void)configureHeaderView {
    
    if (_organization.thumbnail.maxresImageRef) {
        
        [_organization.thumbnail.maxresImageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (!error) {
                [_headerView.imageView sd_setImageWithURL:URL];
            }
        }];
    }
    
    _headerView.titleLabel.attributedText = [self attributedStringWithTitleText:_organization.name detailText:_organization.city];
}

- (NSAttributedString *)attributedStringWithTitleText:(NSString *)titleText detailText:(NSString *)detailText {
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", titleText, detailText] attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSRange newlineRange = [[mutAttrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName : [UIColor lightGrayColor]} range:NSMakeRange(newlineRange.location, [mutAttrStr string].length - newlineRange.location)];
    }
    
    return mutAttrStr;
}

#pragma mark - Actions

- (void)toggleTopSectionHeaderViewBlur {
    
    BOOL shouldHideSectionHeaderViewBlur;
    
    if (isTopSectionHeaderSticky) {
        shouldHideSectionHeaderViewBlur = false;
    } else {
        shouldHideSectionHeaderViewBlur = true;
    }
    _blurToolbar.hidden = shouldHideSectionHeaderViewBlur;
}

- (IBAction)segmentChanged:(id)sender {
    
    if ([[_didLoadInitializers objectAtIndex:_segmentedControl.selectedSegmentIndex] boolValue] == false) {
        switch (_segmentedControl.selectedSegmentIndex) {
            case 0:
                [self loadShows];
                break;
                
            case 1:
                [self loadEvents];
                break;
                
            case 2:
                [self loadVenues];
                break;
        }
    }
    
    [_tableView reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)share:(id)sender {
    
    // redirect to --> teaterbilletter --> teater /
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://www.google.com"]] // requires some google crawler work first.
                                      applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES completion:^{
                           
                           [FIRAnalytics logEventWithName:@"share_event"
                                               parameters:@{
                                                            @"name": _organization.name,
                                                            @"code": _organization.code
                                                            }];
                       }];
}

- (IBAction)more:(id)sender {
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
    
        DTShowTableViewCell *cell = (DTShowTableViewCell *)[[(sender) superview] superview];
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController presentFromViewController:self moreOptionsWithShow:[_shows objectAtIndex:indexPath.row]];
    }
    
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        
        DTTableViewCell *selectedCell = (DTTableViewCell *)[[(sender) superview] superview];
        NSIndexPath *indexPath = [_tableView indexPathForCell:selectedCell];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController presentFromViewController:self moreOptionsWithEvent:[_events objectAtIndex:indexPath.row] completionHandler:nil];
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_segmentedControl.selectedSegmentIndex == 0 &&
        showsQueryIsEmpty != true &&
        indexPath.row == [self.shows count] - 1) {
       
        [self loadShows];
        
    } else if (_segmentedControl.selectedSegmentIndex == 1 &&
               eventsQueryIsEmpty != true &&
               indexPath.row == [self.events count] - 1) {
        
        [self loadEvents];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_segmentedControl.selectedSegmentIndex) {
        case 1:
        {
            Event *selectedEvent = [_events objectAtIndex:indexPath.row];
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEvent.code];
            [self.navigationController pushViewController:eventDetailVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat estimatedRowHeight = DTLoadingTableViewCellRowHeight; // about cells heights
    
    if (_segmentedControl.selectedSegmentIndex == 0 && indexPath.row == self.shows.count) {
        estimatedRowHeight = DTShowTableViewCellRowHeight;
        
    } else if (_segmentedControl.selectedSegmentIndex == 1 && indexPath.row == self.events.count) {
        estimatedRowHeight = DTTableViewCellStyleThumbnailRowHeight();
    }
    
    return estimatedRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([[UIApplication sharedApplication] isOnline]) ? 44.0 : 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *containerView = nil;
    
    if ([[UIApplication sharedApplication] isOnline]) {
    
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
        _blurToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        _blurToolbar.translucent = YES;
        _blurToolbar.clipsToBounds = TRUE;
        _blurToolbar.hidden = YES;
        
        
        [containerView addSubview:_blurToolbar];
        [containerView addSubview:_segmentedControl];
        [_segmentedControl autoPinEdgesToSuperviewMargins];
        
        _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44-.5, self.view.frame.size.width, .5)];
        _separatorLine.backgroundColor = [UIColor colorWithRed:(200/255.0) green:(199/255.0) blue:(204/255.0) alpha:1.0];
        
        [containerView addSubview:_separatorLine];
    }

    return containerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
        {
            numberOfRows = _shows.count;
            if (showsQueryIsEmpty != true) {
                numberOfRows += 1;
            }
        }
            break;
            
        case 1:
        {
            numberOfRows = _events.count;
            if (eventsQueryIsEmpty != true) {
                numberOfRows += 1;
            };
        }
            break;
            
        case 2:
        {
            numberOfRows = 2; // a static calculation.
        }
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (_segmentedControl.selectedSegmentIndex == 0) {
        
        if (indexPath.row == self.shows.count) {
            
            DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
            cell = loadingCell;
        }
        
        else {
            
            DTShowTableViewCell *showCell = [[DTShowTableViewCell alloc] initWithFrame:CGRectZero];
            
            Show *show = [_shows objectAtIndex:indexPath.row];
            
            NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.locale = [NSLocale localeWithLocaleIdentifier:[preferredLocalization isEqualToString:@"da"] ? @"da" : @"en_US_POSIX"];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *date = [df dateFromString:[NSString stringWithFormat:@"%@ %@", show.date, show.time]];
            
            NSDateFormatter *newDf = [[NSDateFormatter alloc] init];
            [newDf setDateStyle:NSDateFormatterNoStyle];
            [newDf setTimeStyle:NSDateFormatterShortStyle];
            
            showCell.date = date;
            
            showCell.fallbackImageURL = [NSURL terebaImageURLWithCode:show.eventCode orientaion:TerebaImageOrientationLandscape];
            showCell.imageRef = show.imageRef;
            showCell.titleText = show.localizedEventTitle;
            NSMutableString *showTimeStr = [NSMutableString string];
            if ([preferredLocalization isEqualToString:@"da"]) {
                [showTimeStr appendString:@"kl. "];
            }
            
            [showTimeStr appendString:[newDf stringFromDate:date]];
            showCell.contentDescriptions = @[show.venueName, showTimeStr];
            
            [showCell.moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = showCell;
        }
        
    }
    
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        
        if (indexPath.row == self.events.count) {
            
            DTLoadingTableViewCell *loadingCell = [[DTLoadingTableViewCell alloc] initWithFrame:CGRectZero];
            cell = loadingCell;
        }
        
        else {
        
            Event *event = [_events objectAtIndex:indexPath.row];
            
            DTTableViewCell *eventCell = [[DTTableViewCell alloc] initWithFrame:CGRectZero];
            [eventCell.moreButton addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
            
            eventCell.style = DTTableViewCellStyleThumbnail;
            eventCell.imageRef = event.thumbnail.maxresImageRef;
            eventCell.title = event.localizedTitle;
            eventCell.contentDescriptions = @[event.organizationName, [NSString stringWithCompactPriceRangeForEventWithTickets:event.tickets]];
            
            cell = eventCell;
        }
        
    }
    
    else if (_segmentedControl.selectedSegmentIndex == 2) {
        
        if (indexPath.row == 0) {
            DTDescriptionTableViewCell *descriptionCell = [[DTDescriptionTableViewCell alloc] initWithFrame:CGRectZero];
            descriptionCell.delegate = self;
            descriptionCell.headerText = @"Description";
            
            NSString *descriptionText = @"No description";
            if (_organization.localizedDescription) {
                descriptionText = _organization.localizedDescription;
            }
            
            descriptionCell.descriptionText = descriptionText;
            descriptionCell.descriptionTextExpanded = _descriptionTextExpanded;
            
            cell = descriptionCell;
        }
        
        else  {
            NSMutableArray <NSDictionary *> *pieces = [NSMutableArray array];
            
            DTInformationTableViewCell *infoCell = [[DTInformationTableViewCell alloc] initWithFrame:CGRectZero];
            infoCell.delegate = self;
            infoCell.headerTextLabel.text = NSLocalizedString(@"INFORMATION_HEADER_TITLE", nil);
            
            if (_organization.generalManager) {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                    @"Text" : NSLocalizedString(@"GENERAL_MANANGER_TEXT", nil),
                                    @"DetailText" : _organization.generalManager
                                    }];
            } else {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                    @"Text" : NSLocalizedString(@"GENERAL_MANANGER_TEXT", nil),
                                    @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                    }];
            }
            
            if (_organization.artisticDirector) {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                    @"Text" : NSLocalizedString(@"ARTISTIC_DIRECTOR_TEXT", nil),
                                    @"DetailText" : _organization.artisticDirector
                                    }];
            } else {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                    @"Text" : NSLocalizedString(@"ARTISTIC_DIRECTOR_TEXT", nil),
                                    @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                    }];
            }
            
            if (_organization.artisticDirector) {
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateStyle:NSDateFormatterLongStyle];
                [df setTimeStyle:NSDateFormatterNoStyle];
                
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                    @"Text" : NSLocalizedString(@"FOUNDED_ON_TEXT", nil),
                                    @"DetailText" : [df stringFromDate:_organization.foundedDate]
                                    }];
            }
            
            if (_organization.landline) {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeAction),
                                    @"Text" : NSLocalizedString(@"TICKET_OFFICE_TEXT", nil),
                                    @"moreButtonIcon" : [[UIImage imageNamed:@"ic_phone_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                    }];
            } else {
                [pieces addObject:@{
                                    @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                    @"Text" : NSLocalizedString(@"TICKET_OFFICE_TEXT", nil),
                                    @"moreButtonIcon" : [[UIImage imageNamed:@"ic_phone_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                    }];
            }
            
            if (_venues.count > 0) {
                for (Venue *venue in _venues) {
                    [pieces addObject:@{
                                        @"DTInformationPieceType" : @(DTInformationPieceTypeAction),
                                        @"Text" : venue.name,
                                        @"moreButtonIcon" : [[UIImage imageNamed:@"ic_arrow_up_right_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                        }];
                }
            }
            
            [infoCell setPieces:pieces];
            cell = infoCell;
        }
        
    }

    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - DTDescriptionTableViewCellDelegate
- (void)didSelectMoreWithDescriptionTableViewCell:(DTDescriptionTableViewCell *)cell {
    
    _descriptionTextExpanded = YES;
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - DTInformationTableViewCellDelegate
- (void)informationTableViewCell:(DTInformationTableViewCell *)cell didSelectSecondaryActionWithIndexPath:(NSIndexPath *)indexPath {
    
    for (Venue *venue in _venues) {
        if ([[[cell.pieces objectAtIndex:indexPath.row] objectForKey:@"Text"] isEqualToString:venue.name]) {
            
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(venue.latitude, venue.longitude)]];
            
            mapItem.name = venue.name;
            
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving}];
        }
    }
    
    if ([[[cell.pieces objectAtIndex:indexPath.row] objectForKey:@"Text"] isEqualToString:NSLocalizedString(@"TICKET_OFFICE_TEXT", nil)]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTicketOfficeName:_organization.name ticketPhone:_organization.landline];
        [self presentViewController:alert animated:YES completion:^{
            [FIRAnalytics logEventWithName:@"call_ticket_office"
                                parameters:@{
                                             @"name" : _organization.name,
                                             @"ticket_phone" : _organization.landline
                                             }];
        }];
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
    }
    
    return nil;
    
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    if (self.emptyDataSetState == DTEmptyDataSetStateOffline) {
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"OFFLINE_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
    } else if (self.emptyDataSetState == DTEmptyDataSetStateNoContent) {
        
        if (_segmentedControl.selectedSegmentIndex == 0 && showsQueryIsEmpty) {
            return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_SHOWS_EMPTY_DATA_SET_DESCRIPTION", nil)];
        
        } else if (_segmentedControl.selectedSegmentIndex == 1 && eventsQueryIsEmpty) {
            return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO_EVENTS_EMPTY_DATA_SET_DESCRIPTION", nil)];
        }
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
    
    if ([[UIApplication sharedApplication] isOnline]) {
        
        if (!organizationNotFound && ![_didLoadInitializers[_segmentedControl.selectedSegmentIndex] boolValue]) { // query experienced an error.
            return DTEmptyDataSetStateLoading;
        }
        
        else if (!organizationNotFound && [_didLoadInitializers[_segmentedControl.selectedSegmentIndex] boolValue] && (showsQueryIsEmpty || eventsQueryIsEmpty)) {
            
            return DTEmptyDataSetStateNoContent;
       
        }
        
        // else {
        //    return DTEmptyDataSetStateNoContent; // query did load intially and expereinced no error, but no content was found at [child] path.
        //}
        
    } else if ([[UIApplication sharedApplication] isOffline]) {
        return DTEmptyDataSetStateOffline;
        
    }
    
    return DTEmptyDataSetStateUndefined;
    
    /*
    if ([[UIApplication sharedApplication] isOnline] && ![_didLoadInitializers[_segmentedControl.selectedSegmentIndex] boolValue]) {
        return DTEmptyDataSetStateLoading;
    } else if ([[UIApplication sharedApplication] isOffline]) {
        return DTEmptyDataSetStateOffline;
    }
    
    return DTEmptyDataSetStateUndefined;
    */
}

#pragma mark - DZNEmptyDataSetDelegate

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    if (self.emptyDataSetState != DTEmptyDataSetStateOffline) {
        [self loadData];
    }
    
}
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return (self.emptyDataSetState == DTEmptyDataSetStateLoading || self.emptyDataSetState == DTEmptyDataSetStateOffline) ? 0.0 : 67.0;
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if ([_didLoadInitializers[_segmentedControl.selectedSegmentIndex] boolValue] == true) {
        isTopSectionHeaderSticky = [_tableView isFloatingHeaderInSection:0];
        [self toggleTopSectionHeaderViewBlur];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
