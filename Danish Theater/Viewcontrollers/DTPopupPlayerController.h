//
//  DTPopupPlayerController.h
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/21/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MarqueeLabel.h"

@class DTPopupPlayerController;
@protocol DTPopupPlayerControllerDataSource <NSObject>

- (NSArray <NSURL *> *)artworkImageURLsInPlayerController:(DTPopupPlayerController *)playerController;

- (NSArray <NSString *> *)titlesInPlayerController:(DTPopupPlayerController *)playerController;

- (NSArray <NSString *> *)authorsInPlayerController:(DTPopupPlayerController *)playerController;

- (NSArray <NSURL *> *)itemURLsInPlayerController:(DTPopupPlayerController *)playerController;

@end

@protocol DTPopupPlayerControllerDelegate <NSObject>

- (void)playerController:(DTPopupPlayerController *)playerController didSkipToPreviousItem:(AVPlayerItem *)item;
- (void)playerController:(DTPopupPlayerController *)playerController didSkipToNextItem:(AVPlayerItem *)item;

- (void)playerController:(DTPopupPlayerController *)playController didBeginPlayingItemAtIndex:(NSUInteger)index;
- (void)playControllerDidReachEndOfItem:(DTPopupPlayerController *)playController;

- (void)playerControllerDidPause:(DTPopupPlayerController *)playerController;
- (void)playerControllerDidStartPlaying:(DTPopupPlayerController *)playerController;

@end

@interface DTPopupPlayerController : UIViewController

// not in use anyway.

// - (instancetype)initWithPlayer:(AVPlayer *)player;
// + (instancetype)playerControllerWithPlayer:(AVPlayer *)player;

@property (nonatomic, strong) AVPlayer *player; // consider it like a cursor.

@property (nonatomic, strong) UIImageView *artworkImageView;
@property (nonatomic, strong) MarqueeLabel *textLabel; // put title of episode and author here.
@property (nonatomic, strong) UILabel *detailTextLabel;

@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UISlider *slider;

@property (strong, nonatomic) UIStackView *playerControls;
@property (strong, nonatomic) UIButton *playPauseButton;
@property (strong, nonatomic) UIButton *previousButton;
@property (strong, nonatomic) UIButton *nextButton;

- (NSAttributedString *)attributedStringWithTitle:(NSString *)title author:(NSString *)author;

@property (nonatomic, weak) id <DTPopupPlayerControllerDelegate> delegate;
@property (nonatomic, weak) id <DTPopupPlayerControllerDataSource> dataSource;

// brand new.

@property (nonatomic, strong) NSArray <NSURL *> *artworkImageURLs;
@property (nonatomic, strong) NSArray <NSString *> *titles;
@property (nonatomic, strong) NSArray <NSString *> *authors;
@property (nonatomic, strong) NSArray <NSURL *> *itemURLs; // make it readonly once, the datasource works.

@property (nonatomic) NSUInteger itemPlayingAtIndex;
- (void)playItemAtIndex:(NSUInteger)index;

@end
