//
//  Trailer.h
//  Theatre
//
//  Created by Daniel Ran Lehmann on 2/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Trailer : NSObject

+ (BOOL)isValidVideoURL:(NSURL *)videoURL;
+ (NSString *)sourceOfVideoURL:(NSURL *)videoURL;

+ (void)loadVideoWithURL:(NSURL *)videoURL completionHandler:(void (^)(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error))handler;

+ (void)playTrailerWithVideoURL:(NSURL *)videoURL fromViewController:(UIViewController *)vc withHandler:(void (^)(NSError *error, BOOL finishedPlaying))handler;

@end
