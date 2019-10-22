//
//  DTEventDetailViewController.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTEventDetailViewController.h"

#import "NSString+FormatHelpers.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "DTColorPalette.h" 
#import "DTQuery.h"
@import Firebase;

#define DEFAULT_MAY_LIKE_QUERY_LIMIT 10

@interface DTEventDetailViewController () {
    UIImage *favoriteIcon;
    UIImage *favoriteIconBorder;
}

@property (nonatomic, strong) FIRUser *user;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSMutableArray <Event *> *mayLikeEventSnippets;
@property (strong, nonatomic) NSMutableArray *eventSectionContents;

@property (strong, nonatomic) DTEventDetailTableViewHeaderView *headerView; // put in public header?

@property (nonatomic, getter=isDescriptionTextExpanded) BOOL descriptionTextExpanded;
@property BOOL didLoadInitially;
@property (getter=isFavorited) BOOL favorited;

@property (nonatomic, strong) UIBarButtonItem *favoritesItem;

@end

@implementation DTEventDetailViewController

#pragma mark - Initializers

- (instancetype)initWithCode:(NSString *)eventCode {
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"Event Detail"];
    if (self) {
        _eventCode = eventCode;
    }
    
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"";
    
    self.ref = [[FIRDatabase database] reference];
    _didLoadInitially = false;
    
    _user = [FIRAuth auth].currentUser;
    if (_user) {
        [[[[_ref child:@"user-favorites"] child:_user.uid] child:_eventCode] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot.exists) { _favorited = YES; }
            else { _favorited = NO; }
            
            favoriteIcon = [[UIImage imageNamed:@"ic_heart_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            favoriteIconBorder = [[UIImage imageNamed:@"ic_heart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
            UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
            _favoritesItem = [[UIBarButtonItem alloc] initWithImage:_favorited ? favoriteIcon : favoriteIconBorder style:UIBarButtonItemStylePlain target:self action:@selector(toggleFavorite:)];
            
            self.navigationItem.rightBarButtonItems = @[shareItem, _favoritesItem];
            
        }];
    }
    
    self.navigationItem.backBarButtonItem.title = @"Back";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.emptyDataSetSource = self;
    _tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    _tableView.tableFooterView = [UIView new];
    
    [self.view addSubview:_tableView];
    
    [_tableView autoPinEdgesToSuperviewEdges];
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:200];
    
    _headerView = [[DTEventDetailTableViewHeaderView alloc] initWithFrame:CGRectZero];
    [_headerView updateConstraints];
    _tableView.tableHeaderView = nil;
    
    [_tableView registerClass:[DTDescriptionTableViewCell class] forCellReuseIdentifier:@"Description Cell"];
    [_tableView registerClass:[DTInformationTableViewCell class] forCellReuseIdentifier:@"Information Cell"];
    [_tableView registerClass:[DTSectionTableViewCell class] forCellReuseIdentifier:@"Event Sections Cell"];
    
    _descriptionTextExpanded = NO;
    
    _mayLikeEventSnippets = [NSMutableArray array];
    _eventSectionContents = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_didLoadInitially == false && [[UIApplication sharedApplication] isOnline]) {
        [self loadData];
    }
}

#pragma mark - Actions

- (IBAction)share:(id)sender {
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[_event.ticketInfo.ticketOperatorURL]
                                      applicationActivities:nil];
    
    [self presentViewController:activityViewController
                       animated:YES completion:^{
                           
                           [FIRAnalytics logEventWithName:@"share_event"
                                               parameters:@{
                                                            @"title": _event.localizedTitle,
                                                            @"code": _event.code
                                                            }];
                       }];
}

- (IBAction)toggleFavorite:(id)sender {
    
    if (_user) {
        if (!_favorited) {
            [[[[_ref child:@"user-favorites"] child:_user.uid] child:_eventCode] setValue:@(true)];
            _favorited = YES;
           
            [_favoritesItem setImage:favoriteIcon];
            
            [FIRAnalytics logEventWithName:@"add_to_favorites"
                                parameters:@{
                                             @"event_title": _event.localizedTitle,
                                             @"event_code": _event.code
                                             }];
        }
        
        else {
            [[[[_ref child:@"user-favorites"] child:_user.uid] child:_eventCode] setValue:nil];
            _favorited = NO;
            [_favoritesItem setImage:favoriteIconBorder];
        }
    }
}

- (IBAction)bookTickets:(id)sender {
    
    if (!_event.ticketInfo.ticketOperatorURL || !_event.ticketInfo.ticketOfficeURL) {
        return;
    }
    
    NSURL *bookingURL = nil;
    
    if (_event.ticketInfo.ticketOperatorURL) { bookingURL = _event.ticketInfo.ticketOperatorURL;}
    else if (_event.ticketInfo.ticketOfficeURL) { bookingURL = _event.ticketInfo.ticketOfficeURL;}
    
    if ([[UIApplication sharedApplication] canOpenURL:bookingURL]) {
        [[UIApplication sharedApplication] openURL:bookingURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                // log event.
                [FIRAnalytics logEventWithName:@"open_website"
                                    parameters:@{
                                                 @"event_code" : _event.code,
                                                 @"event_title" : _event.localizedTitle,
                                                 @"url" : bookingURL
                                                 }];
            }
        }];
    }
}

- (IBAction)playTrailer:(id)sender {
    
    NSString *videoSource = [Trailer sourceOfVideoURL:_event.videoURL];
    
    [FIRAnalytics logEventWithName:@"play_trailer"
                        parameters:@{
                                     @"event_title" : _event.localizedTitle,
                                     @"event_code" : _event.code,
                                     @"video_source" : videoSource != nil ? videoSource : @"unknown"
                                     }];
    
    [Trailer playTrailerWithVideoURL:_event.videoURL fromViewController:self withHandler:^(NSError *error, BOOL finishedPlaying) {
        NSLog(@"hasFinishedPlaying: %@", finishedPlaying ? @"yes" : @"no");
    }];
}

- (IBAction)pushOrganization:(id)sender {
    
    DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:_event.organizationCode];
    [[self navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[self.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : self.title style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationController pushViewController:organizationDetailVC animated:YES];
}

#pragma mark - Load Data

- (void)loadData {
    
    [DTQuery loadSingleEventWithCode:_eventCode success:^(Event *event) {
        
        if (event) {
        
            _event = event;
            
            [self configureWithCompletion:^(BOOL successful, NSError *error) {
                if (!error) {
                    _didLoadInitially = true;
                    
                    [FIRAnalytics logEventWithName:kFIREventViewItem
                                        parameters:@{
                                                     kFIRParameterItemID:_event.code ,
                                                     kFIRParameterItemName:_event.localizedTitle,
                                                     kFIRParameterContentType:@"event"
                                                     }];
                    
                    [_tableView reloadData];
                    _tableView.tableHeaderView = _headerView;
                }
            }];
            
        } else { // NO CONTENT FOUND. (SNAPSHOT DOESN'T EXIST)
            
            // hack to make the EMPTYDATASET dissappear.
            _didLoadInitially = true;
            [self.tableView reloadEmptyDataSet];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"EVENT_NOT_FOUND_DATA_SET_DESCRIPTION", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
            [alertController addAction:okAction];
            
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    } failure:^(NSError *error) {
        
        // hack to make the EMPTYDATASET dissappear.
        _didLoadInitially = true;
        [self.tableView reloadEmptyDataSet];
        
        // An Error Occurred.
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_TITLE", nil) message:NSLocalizedString(@"AN_ERROR_OCCURRED_EMPTY_DATA_SET_DESCRIPTION", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
        [alertController addAction:okAction];
        
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
}

#pragma mark - Configure
- (void)configureHeaderView {

    // COVER IMAGE
    if (_event.thumbnail.maxresImageRef) {
        [_event.thumbnail.maxresImageRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (!error) {
                [_headerView.imageView sd_setImageWithURL:URL];
            }
        }];
    }
    
    // PLAY TRAILER BTN
    BOOL hiddenPlayButton = YES;
    if (_event.videoURL) {
        [_headerView.playButton addTarget:self action:@selector(playTrailer:) forControlEvents:UIControlEventTouchUpInside];
        hiddenPlayButton = NO;
    }
    
    _headerView.playButton.hidden = hiddenPlayButton;
    _headerView.playButtonEffectView.hidden = hiddenPlayButton;
    
    // ORGANIZATION BTN
    [_headerView.organizationBtn addTarget:self action:@selector(pushOrganization:) forControlEvents:UIControlEventTouchUpInside];
    _headerView.titleLabel.text = _event.localizedTitle;
    
    if (_event.organizationName) {
        [_headerView.organizationBtn setTitle:_event.organizationName forState:UIControlStateNormal];
        
    } else {
        _headerView.organizationBtn.enabled = NO;
        [_headerView.organizationBtn setTitle:@"Unkown Theater" forState:UIControlStateDisabled];
    }
    
    [_headerView.organizationBtn sizeToFit];
    
    // BOOK BTN.
    _headerView.bookBtn.title = NSLocalizedString(@"BOOK_BTN_TITLE", nil);
    _headerView.bookBtn.priceRange = [NSString stringWithNormalPriceRangeForEventWithTickets:_event.tickets];
    if (![_headerView.bookBtn.priceRange isEqualToString:NSLocalizedString(@"FREE_TEXT", nil).uppercaseString]) { // again, should be localized.
        _headerView.bookBtn.currency = @"DKK";
    }
    
    [_headerView.bookBtn addTarget:self action:@selector(bookTickets:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView.bookBtn setAttributedTitle:[_headerView.bookBtn attributedText] forState:UIControlStateNormal];
}

- (void)configureWithCompletion:(void (^)(BOOL successful, NSError *error))completion {
    
    __block NSError *organizationExistsError = nil;
    __block NSError *mayLikeEventsError = nil;
    
    // CREATE SERVICE GROUP
     dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE FIRST SERVICE.
    dispatch_group_enter(serviceGroup);
    
    if (_event.organizationCode) {
        [DTQuery existsOrganizationWithCode:_event.organizationCode completion:^(NSError *error, BOOL organizationExist) {
            if (!organizationExist) {
                [_headerView.organizationBtn setEnabled:NO];
            }
            
            organizationExistsError = error;
            dispatch_group_leave(serviceGroup);
        }];
    }
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
    
    FIRDatabaseQuery *query = [[[_ref child:@"event-snippets"] queryOrderedByChild:@"categoryName-subcategoryName"] queryEqualToValue:_event.categoryNameSubCategoryName];
    
    [DTQuery queryEventsWithQuery:query startingWithCode:nil limitedToFirst:DEFAULT_MAY_LIKE_QUERY_LIMIT success:^(NSArray<Event *> *events) {
        [_mayLikeEventSnippets addObjectsFromArray:events];
        dispatch_group_leave(serviceGroup);
  
    } failure:^(NSError *error) {
        mayLikeEventsError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    /*
    [DTQuery queryEventsWithQuery:[[[[_ref child:@"event-snippets"] queryOrderedByChild:@"categoryName-subcategoryName"] queryEqualToValue:_event.categoryNameSubCategoryName] queryLimitedToFirst:DEFAULT_MAY_LIKE_QUERY_LIMIT] success:^(NSArray<Event *> *events) {
        
        [_mayLikeEventSnippets addObjectsFromArray:events];
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        mayLikeEventsError = error;
        dispatch_group_leave(serviceGroup);
    }];
    */
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        NSError *overallError = nil;
        if (organizationExistsError || mayLikeEventsError) {
            overallError = organizationExistsError ?: mayLikeEventsError;
        }
        
        completion(overallError == nil ? YES : NO, overallError);
    });
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        [self configureHeaderView];
        
        NSError *overallError = nil;
        if (organizationExistsError || mayLikeEventsError) {
            overallError = organizationExistsError ?: mayLikeEventsError;
        }
        
        completion(overallError == nil ? YES : NO, overallError);
    });
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _didLoadInitially == false ? 0 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    // DESCRIPTION
    if (indexPath.row == 0) {
        DTDescriptionTableViewCell *descriptionCell = [[DTDescriptionTableViewCell alloc] initWithFrame:CGRectZero];
        descriptionCell.delegate = self;
        
        descriptionCell.headerText = NSLocalizedString(@"DESCRIPTION_HEADER_TITLE", nil);
        
        NSString *descriptionText = NSLocalizedString(@"DESCRIPTION_TEXT_EMPTY", nil);
        if (_event.localizedDescription) {
            descriptionText = _event.localizedDescription;
        }
        
        descriptionCell.descriptionText = descriptionText;
        // descriptionCell.previewDescriptionLength = 300;
        
        descriptionCell.descriptionTextExpanded = _descriptionTextExpanded;
        
        cell = descriptionCell;
    }
    
    // INFORMATION
    else if (indexPath.row == 1) {
        
        NSMutableArray <NSDictionary *> *pieces = [NSMutableArray array];
        
        DTInformationTableViewCell *infoCell = [[DTInformationTableViewCell alloc] initWithFrame:CGRectZero];
        infoCell.delegate = self;
        infoCell.headerTextLabel.text = NSLocalizedString(@"INFORMATION_HEADER_TITLE", nil);
        
        // PLAYING PERIOD
        if (_event.playsFrom && _event.playsTo) {
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                @"Text" : NSLocalizedString(@"PLAYING_PERIOD_TEXT", nil),
                                @"DetailText" : [NSString stringWithPlayingPeriodFromPlaysFrom:_event.playsFrom andPlaysTo:_event.playsTo]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"PLAYING_PERIOD_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        
        // DURATION
        if (_event.durationInMinutes != 0) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                @"Text" : NSLocalizedString(@"DURATION_TEXT", nil),
                                @"DetailText" : [NSString stringWithFormat:@"%lu %@", _event.durationInMinutes, NSLocalizedString(@"DURATION_DETAIL_TEXT_SUFFIX", nil)]
                                }];
        }
        
        else {
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"DURATION_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        
        // AGE Range
        [pieces addObject:@{
                            @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                            @"Text" : NSLocalizedString(@"AGE_RANGE_TEXT", nil),
                            @"DetailText" : [NSString stringWithAgeRangeFromAgeBegin:_event.ageBegin ageEnd:_event.ageEnd]
                            }];
        
        // GENRE AND SUBGENRE
        if (_event.categoryName) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                @"Text" : NSLocalizedString(@"GENRE_TEXT", nil),
                                @"DetailText" : _event.categoryName
                                }];
        }
        
        else {
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"GENRE_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        
        
        
        if (_event.subcategoryName) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                @"Text" : NSLocalizedString(@"SUBGENRE_TEXT", nil),
                                @"DetailText" : _event.subcategoryName
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"SUBGENRE_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];

        }
        
        // INTERMISSION
        /*
        
        [pieces addObject:@{
                            @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                            @"Text" : NSLocalizedString(@"INTERMISSION_TEXT", nil),
                            @"DetailText" : [NSString stringWithFormat:@"%@", _event.intermissionIndicator ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil)]
                            }];
        
        // VERBAL
        
        [pieces addObject:@{
                            @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                            @"Text" : NSLocalizedString(@"VERBAL_TEXT", nil),
                            @"DetailText" : [NSString stringWithFormat:@"%@", _event.nonVerbal ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil)]
                            }];
        
        // NUMBERED SEATS
        
        [pieces addObject:@{
                            @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                            @"Text" : NSLocalizedString(@"NUMBERED_SEATS_TEXT", nil),
                            @"DetailText" : [NSString stringWithFormat:@"%@", _event.numberedSeats ? NSLocalizedString(@"YES", nil) : NSLocalizedString(@"NO", nil)]
                            }];
        */
        
        // RELEASE DATE
        if (_event.releaseDate && ![_event.releaseDate isDateUndefined]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd"];
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDefault),
                                @"Text" : NSLocalizedString(@"RELEASE_DATE_TEXT", nil),
                                @"DetailText" : [df stringFromDate:_event.releaseDate]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"RELEASE_DATE_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];

        }
        
        // SERVICES
        /*
        if (_event.services.count > 0) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeReveal),
                                @"Text" : NSLocalizedString(@"SERVICES_TEXT", nil),
                                @"DetailText" : [NSString stringWithFormat:@"%lu", _event.services.count]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"SERVICES_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        */
        
        // ACCREDITATIONS
        
        if (_event.accreditations.count > 0) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeReveal),
                                @"Text" : NSLocalizedString(@"CREDITS_TEXT", nil),
                                @"DetailText" : [NSString stringWithFormat:@"%lu", _event.accreditations.count]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"CREDITS_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        
        // SHOWS
        
        if (_event.totalNumberOfShows > 0) {
        
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeReveal),
                                @"Text" : NSLocalizedString(@"SHOWS_TEXT", nil),
                                @"DetailText" : [NSString stringWithFormat:@"%lu", _event.totalNumberOfShows]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"SHOWS_TEXT", nil),
                                @"DetailText" : NSLocalizedString(@"NONE_TEXT", nil)
                                }];
        }
        
        // Website.
        if (_event.ticketInfo.ticketOfficeURL) {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeAction),
                                @"Text" : [_event.ticketInfo.ticketOfficeURL host],
                                @"moreButtonIcon" : [[UIImage imageNamed:@"ic_compass"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                }];
            
        }
        
        else {
            // need to be able to set a [disabled] state of a piece of into.
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"WEBSITE_TEXT", nil),
                                @"moreButtonIcon" : [[UIImage imageNamed:@"ic_compass"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                }];
        }
        // CALL TICKET OFFICE
        
        if (_event.ticketOffice.name && _event.ticketOffice.ticketPhone) {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeAction),
                                @"Text" : [NSString stringWithFormat:@"%@", _event.ticketOffice.name],
                                //@"DetailText" : [NSString stringWithFormattedPhoneNumber:_event.ticketOffice.ticketPhone]
                                @"moreButtonIcon" : [[UIImage imageNamed:@"ic_phone_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                }];
        }
        
        else {
            
            [pieces addObject:@{
                                @"DTInformationPieceType" : @(DTInformationPieceTypeDisabled),
                                @"Text" : NSLocalizedString(@"TICKET_OFFICE", nil),
                                @"moreButtonIcon" : [[UIImage imageNamed:@"ic_phone_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                }];
            
        }
        
        
        
        [infoCell setPieces:pieces];
        cell = infoCell;
    }
    
    // YOU MAY ALSO LIKE
    else {
        
        DTSectionTableViewCell *sectionCell = [[DTSectionTableViewCell alloc] initWithFrame:CGRectZero];
        sectionCell.delegate = self;
        sectionCell.headerTitle = NSLocalizedString(@"YOU_MAY_ALSO_LIKE_HEADER_TITLE", nil);
        [sectionCell setItems:_mayLikeEventSnippets ofModelClass:[Event class]];
        
        cell = sectionCell;
    }
    
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - DTInformationTableViewCellDelegate
- (void)informationTableViewCell:(DTInformationTableViewCell *)cell didSelectSecondaryActionWithIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger websiteRow = 8;
    NSUInteger ticketOfficeRow = 9;
    
    if (indexPath.row == websiteRow) {
        
        [[UIApplication sharedApplication] openURL:_event.ticketInfo.ticketOfficeURL options:@{} completionHandler:^(BOOL success) {
            if (success) {
                
                [FIRAnalytics logEventWithName:@"open_website"
                                    parameters:@{
                                                 @"event_code" : _event.code,
                                                 @"event_title" : _event.localizedTitle,
                                                 @"url" : _event.ticketInfo.ticketOfficeURL
                                                 }];
            }
        }];
    }
    
    else if (indexPath.row == ticketOfficeRow) {
        UIAlertController *alert = [UIAlertController alertControllerWithTicketOfficeName:_event.ticketOffice.name ticketPhone:_event.ticketOffice.ticketPhone];
        [self presentViewController:alert animated:YES completion:^{
            [FIRAnalytics logEventWithName:@"call_ticket_office"
                                parameters:@{
                                             @"name" : _event.ticketOffice.name,
                                             @"ticket_phone" : _event.ticketOffice.ticketPhone
                                             }];
        }];
    }
}

- (void)informationTableViewCell:(DTInformationTableViewCell *)cell didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // .type (DEFAULT)
    /*
    NSUInteger durationRow = 0;
    NSUInteger ageGroupRow = 1;
    NSUInteger genreRow = 2;
    NSUInteger subGenreRow = 3;
    NSUInteger intermissionRow = 4;
    NSUInteger verbalRow = 5;
    NSUInteger numberedSeatsRow = 6;
    NSUInteger releaseDateRow = 7;
    */
    
    // .type (REVEAL)
    NSUInteger servicesRow = 9; // Discontinued (for now)
    NSUInteger creditsRow = 6;
    NSUInteger showsRow = 7;
    
    NSDictionary *piece = [[cell pieces] objectAtIndex:indexPath.row];
    DTInformationPieceType informationPieceType = [piece[@"DTInformationPieceType"] unsignedIntegerValue];
    
    if (informationPieceType == DTInformationPieceTypeReveal) {
        
        if (indexPath.row == servicesRow) {
            DTServicesViewController *servicesVC = [[DTServicesViewController alloc] initWithServices:_event.services];
            servicesVC.includeCountInHeader = NO;
            [[self navigationItem] setBackBarButtonItem:[UIBarButtonItem backItem]];
            [self.navigationController pushViewController:servicesVC animated:YES];
        }
        
        else if (indexPath.row == creditsRow) {
            DTCreditsViewController *creditsVC = [[DTCreditsViewController alloc] initWithAccreditations:_event.accreditations];
            creditsVC.includeCountInHeader = NO;
            [[self navigationItem] setBackBarButtonItem:[UIBarButtonItem backItem]];
            [self.navigationController pushViewController:creditsVC animated:YES];
        }
        
        else if (indexPath.row == showsRow) {
            DTShowsViewController *showsVC = [[DTShowsViewController alloc] initWithEventCode:_eventCode];
            // showsVC.title = [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"SHOWS_TEXT", nil), _event.totalNumberOfShows];
            [[self navigationItem] setBackBarButtonItem:[UIBarButtonItem backItem]];
            [self.navigationController pushViewController:showsVC animated:YES];
        }
    }
}

#pragma mark - UITableViewDelegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DTDescriptionTableViewCellDelegate
- (void)didSelectMoreWithDescriptionTableViewCell:(DTDescriptionTableViewCell *)cell {

    _descriptionTextExpanded = YES;
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    
    if ([[UIApplication sharedApplication] isOnline] && !_didLoadInitially) {
        return DTEmptyDataSetStateLoading;
    } else if ([[UIApplication sharedApplication] isOffline]) {
        return DTEmptyDataSetStateOffline;
    }
    
    return DTEmptyDataSetStateUndefined;
}

#pragma mark - DZNEmptyDataSetDelegate

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    if (self.emptyDataSetState != DTEmptyDataSetStateOffline) {
        [self loadData];
    }
    
}

#pragma mark - DTEventSnippetsSectionDelegate
- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSnippetWithIndexPath:(NSIndexPath *)indexPath {
    
    DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:[[_mayLikeEventSnippets objectAtIndex:indexPath.row] code]];
    [[self navigationItem] setBackBarButtonItem:[UIBarButtonItem backItem]];
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

- (void)sectionTableViewCell:(DTSectionTableViewCell *)sectionTableViewCell didSelectSecondaryButtonWithIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController presentFromViewController:self moreOptionsWithEvent:[_mayLikeEventSnippets objectAtIndex:indexPath.row] completionHandler:nil];
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
