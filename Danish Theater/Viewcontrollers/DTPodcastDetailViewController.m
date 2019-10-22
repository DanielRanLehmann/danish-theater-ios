//
//  DTPodcastDetailViewController.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/19/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTPodcastDetailViewController.h"
#import "DTPodcastDetailTableViewHeaderView.h"
#import "DTDescriptionTableViewCell.h"
#import "AppDelegate.h"

@import LNPopupController;
#import "DTPopupPlayerController.h"

#import "PINCache.h"
#import "UIImageView+AFNetworking.h"

#import "Podcast.h"
#import "DTQuery.h"
#import "UIApplication+Reachability.h"

#define STATIC_CELLS 1 // just a description cell.

@import Firebase;

@interface DTPodcastDetailViewController () <DTPopupPlayerControllerDelegate> {

    DTPopupPlayerController *playerController;
    BOOL queryDidLoadInitially;
}

@property (strong, nonatomic) DTPodcastDetailTableViewHeaderView *headerView;
@property (nonatomic, readonly, copy) NSString *podcastId;
@property (nonatomic, readonly) Podcast *podcast;
@property (nonatomic, readonly) NSMutableArray <Episode *> *episodes;

@property (nonatomic, strong) NSIndexPath *playbackAtIndexPath;

@property (nonatomic, strong) FIRStorage *storage;
@property (nonatomic, strong) FIRStorageReference *storageRef;

@end

@implementation DTPodcastDetailViewController

- (instancetype)initWithPodcastId:(NSString *)podcastId {
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [main instantiateViewControllerWithIdentifier:@"PodcastDetailVC"]; //self = [super init];
    if (self) {
        _podcastId = podcastId;
        [self configure];
    }
    
    return self;
}

- (void)configure {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _storage = [FIRStorage storage];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [_tableView autoPinEdgesToSuperviewEdges];
    
    _headerView = [[DTPodcastDetailTableViewHeaderView alloc] initWithFrame:CGRectZero];
    [_headerView updateConstraints];
    _tableView.tableHeaderView = nil;
    
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    [_tableView setEstimatedRowHeight:200];
    
    [_tableView registerClass:[DTDescriptionTableViewCell class] forCellReuseIdentifier:@"DescriptionCell"];
    
    queryDidLoadInitially  = false;
    
    _episodes = [NSMutableArray array];
 }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[PINCache sharedCache] objectForKey:@"DTPodcastPlaybackAtIndexPath" block:^(PINCache *cache, NSString *key, id object) {
        if (object) {
            NSIndexPath *indexPath = (NSIndexPath *)object;
            _playbackAtIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!queryDidLoadInitially && [[UIApplication sharedApplication] isOnline]) {
        [self loadPodcastAndEpisodes];
    }
}

- (void)loadPodcastAndEpisodes {

    __block NSError *podcastError = nil;
    __block NSError *episodesError = nil;
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE FIRST SERVICE.
    dispatch_group_enter(serviceGroup);

    [DTQuery querySinglePodcastWithId:_podcastId success:^(Podcast *podcast) {
        _podcast = podcast;
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        // handle error
        podcastError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    // START THE SECOND SERVICE.
    dispatch_group_enter(serviceGroup);
                         
    [DTQuery queryEpisodesWithPodcastId:_podcastId success:^(NSArray<Episode *> *episodes) {
        
        [_episodes addObjectsFromArray:episodes];
        dispatch_group_leave(serviceGroup);
        
    } failure:^(NSError *error) {
        episodesError = error;
        dispatch_group_leave(serviceGroup);
    }];
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        NSError *overallError = nil;
        if (podcastError || episodesError) {
            overallError = podcastError ?: episodesError;
        };
        
        if (!overallError) {
            queryDidLoadInitially = true;
            
            _storageRef = [[_storage referenceWithPath:@"podcasts/"] child:[NSString stringWithFormat:@"%@/", _podcastId]];
            
            [self configureHeaderView];
            [self configurePlayerControllerWithCompletion:^(BOOL success) {
                if (success) {
                    [self.tableView reloadData];
                    _tableView.tableHeaderView = _headerView;
                }
            }];
        }
    
    });
    
}

- (void)configurePlayerControllerWithCompletion:(void (^)(BOOL success))completion {
    if (self.tabBarController.popupContentViewController) {
        playerController = (DTPopupPlayerController *)self.tabBarController.popupContentViewController;
        return;
    }
    
    // CREATE SERVICE GROUP
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    // START THE FIRST SERVICE.
    dispatch_group_enter(serviceGroup);
    
    playerController = [DTPopupPlayerController new];
    playerController.delegate = self;
    
    self.tabBarController.popupBar.progressViewStyle = LNPopupBarProgressViewStyleBottom;

    // sync.
    NSMutableArray <NSString *> *authors = [NSMutableArray arrayWithCapacity:_episodes.count];
    NSMutableArray <NSString *> *titles = [NSMutableArray arrayWithCapacity:_episodes.count];
    NSMutableArray <NSURL *> *artworkImageURLs = [NSMutableArray arrayWithCapacity:_episodes.count];
    
    // async.
    NSMutableArray *itemURLs = [NSMutableArray arrayWithCapacity:_episodes.count];
    for (int i = 0; i < _episodes.count; i++) {
        Episode *episode = _episodes[i];
        
        
        [authors addObject:episode.podcastName];
        [titles addObject:episode.localizedTitle];
        [artworkImageURLs addObject:[NSURL URLWithString:@""]]; // do the same as with the mp3 files?
        
        [itemURLs addObject:episode.episodeId];
    }
    
    for (int i = 0; i < _episodes.count; i++) {
        
        Episode *episode = _episodes[i];
        
        FIRStorageReference *episodeRef = [[_storageRef child:@"episodes/"] child:[NSString stringWithFormat:@"%@.mp3", episode.episodeId]];
        [episodeRef downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (!error) {
                //[itemURLs addObject:URL];
                [itemURLs replaceObjectAtIndex:[itemURLs indexOfObject:episode.episodeId] withObject:URL];
            } else {
                [itemURLs addObject:[NSNull null]];
            }
            
            if (i == _episodes.count - 1) {
                dispatch_group_leave(serviceGroup);
            }
        }];
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        playerController.artworkImageURLs = artworkImageURLs;
        playerController.titles = titles;
        playerController.authors = authors;
        playerController.itemURLs = itemURLs;
        
        completion(true);
    });
}

- (void)configureHeaderView {

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%d", _podcast.name, _podcast.publicationYear] attributes:@{NSFontAttributeName : _headerView.textLabel.font, NSForegroundColorAttributeName: _headerView.textLabel.textColor}];
    
    NSRange newlineRange = [[attrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        
        // NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
        [attrStr addAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} range:NSMakeRange(newlineRange.location, [attrStr string].length - newlineRange.location)];
    }
    
    [_headerView.textLabel setAttributedText:attrStr];
}

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

# pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_podcast.localizedDescription != nil ? STATIC_CELLS : 0) + _episodes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        
        DTDescriptionTableViewCell *descriptionCell = [[DTDescriptionTableViewCell alloc] initWithFrame:CGRectZero];
        descriptionCell.descriptionText = _podcast.localizedDescription;
        cell = descriptionCell;
        
    } else {
        
        Episode *episode = [_episodes objectAtIndex:indexPath.row - 1];
        
        UITableViewCell *episodeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EpisodeCell"];
        
        episodeCell.textLabel.text = episode.localizedTitle;
        episodeCell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        episodeCell.detailTextLabel.text = [NSString stringWithFormat:@"%lu secs", episode.durationInSeconds];
        episodeCell.textLabel.textColor = !([indexPath isEqual:_playbackAtIndexPath]) ? [UIColor blackColor] : self.view.tintColor;
        
        cell = episodeCell;
    }
    
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tabBarController presentPopupBarWithContentViewController:playerController animated:YES completion:nil];
    self.tabBarController.popupBar.marqueeScrollEnabled = YES;
    [playerController playItemAtIndex:indexPath.row-1];
    
    if (_playbackAtIndexPath) {
        UITableViewCell *prevSelectedCell = [_tableView cellForRowAtIndexPath:_playbackAtIndexPath];
        prevSelectedCell.textLabel.textColor = [UIColor blackColor];
    }
    
    UITableViewCell *selectedCell = [_tableView cellForRowAtIndexPath:_playbackAtIndexPath];
    selectedCell.textLabel.textColor = self.view.tintColor;
    
}

#pragma mark - DTPopupPlayerControllerDelegate
- (void)playerController:(DTPopupPlayerController *)playController didBeginPlayingItemAtIndex:(NSUInteger)index {
    _playbackAtIndexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    [_tableView reloadData];
}

- (void)playControllerDidReachEndOfItem:(DTPopupPlayerController *)playController {
    _playbackAtIndexPath = nil;
    [_tableView reloadData];
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
