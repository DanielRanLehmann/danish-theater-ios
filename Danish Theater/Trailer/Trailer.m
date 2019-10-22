//
//  Trailer.m
//  Theatre
//
//  Created by Daniel Ran Lehmann on 2/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Trailer.h"
#import "Youtube.h" 
#import "Vimeo.h"

@implementation Trailer

+ (BOOL)isValidVideoURL:(NSURL *)videoURL {
    
    BOOL isValid = false;
    if ([[videoURL absoluteString] rangeOfString:@"youtube.com"].location != NSNotFound ||
         [[videoURL absoluteString] rangeOfString:@"youtu.be"].location != NSNotFound ||
         [[videoURL absoluteString] rangeOfString:@"vimeo.com"].location != NSNotFound) {
        isValid = true;
    }
        
    return isValid;
}

+ (NSString *)sourceOfVideoURL:(NSURL *)videoURL {
    
    NSString *source = nil;
    
    if ([[videoURL absoluteString] rangeOfString:@"youtube.com"].location != NSNotFound || [[videoURL absoluteString] rangeOfString:@"youtu.be"].location != NSNotFound) {
        source = @"youtube";
    }
    
    // VIMEO HANDLER
    else if ([[videoURL absoluteString] rangeOfString:@"vimeo.com"].location != NSNotFound) {
        source = @"vimeo";
    }
    
    return source;
}

+ (void)loadVideoWithURL:(NSURL *)videoURL completionHandler:(void (^)(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error))handler {

    // YT HANDLER
    if ([Trailer isValidVideoURL:videoURL]) {
      
        if ([[Trailer sourceOfVideoURL:videoURL] isEqualToString:@"youtube"]) {
            [Youtube loadVideoWithURL:videoURL completionHandler:^(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error) {
                handler(thumbnailURL, parsedVideoURL, error);
                return;
            }];
        }
        
        else { // can only be vimeo (remember first opening condition)
            [Vimeo loadVideoWithURL:videoURL completionHandler:^(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error) {
                handler(thumbnailURL, parsedVideoURL, error);
                return;
            }];
        }
        
    }
    
    handler(nil, nil, nil); // present custom error saying that the app only currently supports either yt or vimeo. and maybe at launch raw urls, that requires a head request to see the contentType.
}

+ (void)playTrailerWithVideoURL:(NSURL *)videoURL fromViewController:(UIViewController *)vc withHandler:(void (^)(NSError *error, BOOL finishedPlaying))handler {
    [Trailer loadVideoWithURL:videoURL completionHandler:^(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error) {
        if (parsedVideoURL) {
            AVPlayer *player = [AVPlayer playerWithURL:parsedVideoURL];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [vc.view addSubview: playerViewController.view];
            [vc presentViewController:playerViewController animated:YES completion:nil];
        }
        
        // should listen for the av callbacks, to let the vc, eventDetailvC know, when playback has finished.
        handler(nil, YES); // handler is useless right now.
    }];
}

@end
