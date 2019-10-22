//
//  DTPopupPlayerController.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/21/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

// FIX THIS::
// WHY IS THIS NOT LEGAL
// [DTPopupPlayerController playerControllerWithPlayer:[AVPlayer playerWithURL:[NSURL URLWithString:@"https://s3.amazonaws.com/kargopolov/kukushka.mp3"]]];

#import "DTPopupPlayerController.h"
#import "PureLayout.h"
#import "UIImageView+AFNetworking.h"
#import "PINCache.h"
#import "DTColorPalette.h"

@import LNPopupController;

#define INIT_PROGRESS 0.00

@interface DTPopupPlayerController () {

    NSTimer *timer;
}

@end

@implementation DTPopupPlayerController
@synthesize delegate;

- (instancetype)initWithPlayer:(AVPlayer *)player {
    self = [super init];
    if (self) {
        _player = player;
    }
    return self;
}

+ (instancetype)playerControllerWithPlayer:(AVPlayer *)player {
    return [[self alloc] initWithPlayer:player]; //[[super alloc] initWithPlayer:player];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self _setPopupItemButtonsWithTraitCollection:newCollection];
    } completion:nil];
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (UIBarButtonItem *)playBarButtonItem {

    UIBarButtonItem* play = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] style:UIBarButtonItemStylePlain target:self action:@selector(togglePlayPause)];
    play.accessibilityLabel = NSLocalizedString(@"Play", @"");
    play.accessibilityIdentifier = @"PlayButton";
    play.accessibilityTraits = UIAccessibilityTraitButton;
    
    return play;
}

- (UIBarButtonItem *)pauseBarButtonItem {

    UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pause"] style:UIBarButtonItemStylePlain target:self action:@selector(togglePlayPause)];
    pause.accessibilityLabel = NSLocalizedString(@"Pause", @"");
    pause.accessibilityIdentifier = @"PauseButton";
    pause.accessibilityTraits = UIAccessibilityTraitButton;
    
    return pause;
}

- (UIBarButtonItem *)nextBarButtonItem {

    UIBarButtonItem* next = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nextFwd"] style:UIBarButtonItemStylePlain target:self action:@selector(next:)]; // how do I make this happen?
    next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
    next.accessibilityIdentifier = @"NextButton";
    next.accessibilityTraits = UIAccessibilityTraitButton;

    return next;
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection
{
   
    UIBarButtonItem *pause = [self pauseBarButtonItem];
    UIBarButtonItem *next = [self nextBarButtonItem];
    
    self.popupItem.leftBarButtonItems = @[ pause ];
    self.popupItem.rightBarButtonItems = @[ next ];
}

- (BOOL)prefersStatusBarHidden
{
    //	return YES;
    return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _artworkImageView = [[UIImageView alloc] init];
    _artworkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _artworkImageView.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    _artworkImageView.layer.cornerRadius = 6.0f;
    _artworkImageView.layer.masksToBounds = true; // set to false, if you want to apply shadow.
    
    // https://stackoverflow.com/questions/41094962/how-did-apple-create-the-blur-behind-the-album-cover-in-apple-music/41095369#41095369
    /*
    _artworkImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _artworkImageView.layer.shouldRasterize = true;
    _artworkImageView.layer.shadowOpacity = .30;
    _artworkImageView.layer.shadowOffset = CGSizeZero;
    _artworkImageView.layer.shadowRadius = 10;
    */
    
    [self.view addSubview:_artworkImageView];
    
    [_artworkImageView autoSetDimensionsToSize:CGSizeMake(self.view.frame.size.width - (32 * 2), self.view.frame.size.width - (32 * 2))];
    [_artworkImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:(32 + 32)];
    [_artworkImageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    //
    
    _currentLabel = [[UILabel alloc] initForAutoLayout];
    _currentLabel.text = @"0:00";
    _currentLabel.numberOfLines = 1;
    _currentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _currentLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:_currentLabel];
    
    //
    _durationLabel = [[UILabel alloc] initForAutoLayout];
    _durationLabel.text = @"-0:00";
    _durationLabel.numberOfLines = 1;
    _durationLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    //_durationLabel.textAlignment = NSTextAlignmentRight;
    _durationLabel.textColor = [UIColor blackColor];
   
    [self.view addSubview:_durationLabel];
    
    _slider = [[UISlider alloc] init];
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    _slider.tintColor = [UIColor darkGrayColor];
    
    [self.view addSubview:_slider];
    
    [_slider autoSetDimensionsToSize:CGSizeMake(self.view.frame.size.width - (32 * 2), 31)];
    [_slider addTarget:self action:@selector(sliderValueDidChange:forEvent:) forControlEvents:UIControlEventValueChanged];
    [_slider autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_slider autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_artworkImageView withOffset:16.0f];

    
    [_currentLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_slider withOffset:8.0];
    [_currentLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_slider];
    
    [_durationLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_slider withOffset:8.0];
    [_durationLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_slider];
    
    //
    _textLabel = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:8.0 andFadeLength:10.0f];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.holdScrolling = NO;
    _textLabel.numberOfLines = 1;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    
    [self.view addSubview:_textLabel];
    
    [_textLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_slider withOffset:32.0f];
    [_textLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_slider];
    [_textLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:_slider];

    //
    _detailTextLabel = [[UILabel alloc] initForAutoLayout];
    _detailTextLabel.numberOfLines = 1;
    _detailTextLabel.textAlignment = NSTextAlignmentCenter;
    _detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    _detailTextLabel.textColor = DTPrimaryColor();
    
    [self.view addSubview:_detailTextLabel];
    
    [_detailTextLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_detailTextLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_textLabel withOffset:8.0f];
    
    _previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_previousButton setImage:[UIImage imageNamed:@"nowPlaying_prev"] forState:UIControlStateNormal];
    [_previousButton addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
    
    _playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_playPauseButton setImage:[UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
    [_playPauseButton addTarget:self action:@selector(togglePlayPause) forControlEvents:UIControlEventTouchUpInside];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_nextButton setImage:[UIImage imageNamed:@"nowPlaying_next"] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    
    _playerControls = [[UIStackView alloc] initWithArrangedSubviews:@[_previousButton, _playPauseButton, _nextButton]];
    _playerControls.translatesAutoresizingMaskIntoConstraints = YES;
    _playerControls.alignment = UIStackViewAlignmentCenter;
    _playerControls.tintColor = [UIColor blackColor];
    _playerControls.spacing = 56.0f;
    
    [self.view addSubview:_playerControls];
    [_playerControls autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_playerControls autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_detailTextLabel withOffset:32.0f];
    
}

- (void)reset {
    _slider.value = 0.0f;
    _currentLabel.text = @"0:00";
    _durationLabel.text = @"-0:00";
    //[_playPauseButton setImage: [UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
    [_textLabel resetLabel];
}

- (void)playItemAtIndex:(NSUInteger)index {
    [self reset];
    
    _itemPlayingAtIndex = index;
    [[PINCache sharedCache] setObject:[NSIndexPath indexPathForRow:index inSection:0] forKey:@"DTPodcastPlaybackAtIndexPath"];
    
    if ([delegate respondsToSelector:@selector(playerController:didBeginPlayingItemAtIndex:)]) {
        [delegate playerController:self didBeginPlayingItemAtIndex:index]; 
    }
    
    self.popupItem.title = _titles[index];
    self.popupItem.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_artworkImageURLs[index]]];
    self.popupItem.subtitle = _authors[index];
    self.popupItem.progress = 0.0f;
    
    [_artworkImageView setImageWithURL:_artworkImageURLs[index]];
    
    [_textLabel setText:_titles[index]];
    [_textLabel triggerScrollStart];
    
    [_detailTextLabel setText:_authors[index]];
    
    _player = nil;
    timer = nil;
    
    _player = [AVPlayer playerWithURL:_itemURLs[index]];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    _player.volume = 0.25; // just set in debugging.
    [self togglePlayPause];
    
    _slider.minimumValue = 0.0;
    _slider.maximumValue = CMTimeGetSeconds(_player.currentItem.asset.duration);
}

// still not quiet right.
- (void)sliderValueDidChange:(UISlider *)slider forEvent:(UIEvent *)event {
    [_player pause];
    [_playPauseButton setImage:[UIImage imageNamed:@"nowPlaying_play"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:.75 delay:0
         usingSpringWithDamping:.80 initialSpringVelocity:.20
                        options:0 animations:^{
                            _artworkImageView.transform = CGAffineTransformMakeScale(.80, .80);
                            
                        } completion:^(BOOL finished) {
                            
                        }];
    
    [timer invalidate];
    CMTime newTime = CMTimeMakeWithSeconds(slider.value, _player.currentTime.timescale);
    
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
            
        case UITouchPhaseMoved:
            _currentLabel.text = [self stringWithFormattedTime:newTime];
            break;
            
        case UITouchPhaseEnded:
            [_player seekToTime:newTime];
            [self togglePlayPause];
            //[_player play];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
            
            break;
        default:
            break;
    }

}

- (NSString *)stringWithFormattedTime:(CMTime)time {
    int timeInSeconds = CMTimeGetSeconds(time);
    
    NSUInteger h = timeInSeconds / 3600;
    NSUInteger m = (timeInSeconds / 60) % 60;
    NSUInteger s = timeInSeconds % 60;
    
    NSString *formattedTime = [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
    return formattedTime;
}

- (void)updateProgress {
    
    self.popupItem.progress = MAX(INIT_PROGRESS, [self progressForPlayer:_player]);
    _slider.value = CMTimeGetSeconds(_player.currentTime); // self.popupItem.progress;
    
    _currentLabel.text = [self stringWithFormattedTime:[_player currentTime]];
    _durationLabel.text = [self stringWithFormattedTime:_player.currentItem.asset.duration];
    
    if (self.popupItem.progress >= 1.0) {
        _player = nil;
        [timer invalidate];
        
        [[PINCache sharedCache] removeObjectForKey:@"DTPodcastPlaybackAtIndexPath"];
        
        if ([delegate respondsToSelector:@selector(playerController:didBeginPlayingItemAtIndex:)]) {
            [delegate playControllerDidReachEndOfItem:self];
        }

        [self.popupPresentationContainerViewController dismissPopupBarAnimated:YES completion:nil];
    }
}

- (BOOL)canSkipToNextItemAtIndex:(NSUInteger)index { // fix this.
    BOOL canSkip = false;
    
    if ((int)index <= _itemURLs.count - 1) {
        canSkip = true;
    }
    return canSkip;
}

- (BOOL)canSkipToPreviousItemAtIndex:(NSUInteger)index {
    BOOL canSkip = false;
    if ((int)index >= 0) {
        canSkip = true;
    }
    return canSkip;
}

#pragma mark - Player Controls
- (IBAction)previous:(id)sender {
    NSUInteger prevItem = _itemPlayingAtIndex - 1;
    if ([self canSkipToPreviousItemAtIndex:prevItem]) {
        [self playItemAtIndex:prevItem];
    }
}
     
- (IBAction)next:(id)sender {
    NSUInteger nextItem = _itemPlayingAtIndex + 1;
    if ([self canSkipToNextItemAtIndex:nextItem]) {
        [self playItemAtIndex:nextItem];
    }
}

// player controls &
// helper
- (float)progressForPlayer:(AVPlayer *)player {
    
    CMTime t1 = [player currentTime];
    CMTime t2 = player.currentItem.asset.duration;
    
    float myCurrentTime = CMTimeGetSeconds(t1);
    float myDuration = CMTimeGetSeconds(t2);
    
    float percent = (myCurrentTime / myDuration); // *100.0f;
    return percent;
}

- (void)togglePlayPause {

    UIBarButtonItem *newItem = nil;
    CGAffineTransform artworkTransform;
    UIImage *nowPlayingImg = nil;
    
    if (![self isPlaying:_player]) {
        artworkTransform = CGAffineTransformIdentity;
        [_player play];
        newItem = [self pauseBarButtonItem];
        nowPlayingImg = [UIImage imageNamed:@"nowPlaying_pause"];
        
    } else {
        artworkTransform = CGAffineTransformMakeScale(.80, .80);
        [_player pause];
        newItem = [self playBarButtonItem];
        nowPlayingImg = [UIImage imageNamed:@"nowPlaying_play"];
    }
    
    [UIView animateWithDuration:.75 delay:0
         usingSpringWithDamping:.80 initialSpringVelocity:.20
                        options:0 animations:^{
                            _artworkImageView.transform = artworkTransform;
                            
                        } completion:^(BOOL finished) {
                            
                        }];
    
    [_playPauseButton setImage:nowPlayingImg forState:UIControlStateNormal];
    self.popupItem.leftBarButtonItems = @[ newItem ];
}

// make extension for avplayer, if this works as advertised:
// https://stackoverflow.com/questions/5655864/check-play-state-of-avplayer

- (BOOL)isPlaying:(AVPlayer *)player {
    BOOL playing = false;
    if ((player.rate != 0) && (player.error == nil)) {
        playing = true;
    }
    return playing;
}

// attributed title string helper
- (NSAttributedString *)attributedStringWithTitle:(NSString *)title author:(NSString *)author {
    NSString *astr = [NSString stringWithFormat:@"%@\n%@", title, author];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc] initWithString:astr attributes:@{NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    NSRange newlineRange = [astr rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange.location != NSNotFound) {
        [mutAttrStr addAttributes:@{NSForegroundColorAttributeName : self.view.tintColor} range:NSMakeRange(newlineRange.location, astr.length - newlineRange.location)];
    }
    
    return mutAttrStr;
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
