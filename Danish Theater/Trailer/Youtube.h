//
//  Youtube.h
//  Theatre
//
//  Created by Daniel Ran Lehmann on 1/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HCYoutubeParser.h"

@interface Youtube : NSObject

+ (void)loadVideoWithURL:(NSURL *)videoURL completionHandler:(void (^)(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error))handler;

@end
