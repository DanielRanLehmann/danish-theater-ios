//
//  Youtube.m
//  Theatre
//
//  Created by Daniel Ran Lehmann on 1/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Youtube.h"

@implementation Youtube

+ (void)loadVideoWithURL:(NSURL *)videoUrl completionHandler:(void (^)(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error))handler {
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:videoUrl];
    handler([HCYoutubeParser thumbnailUrlForYoutubeURL:videoUrl thumbnailSize:YouTubeThumbnailDefaultMaxQuality], [NSURL URLWithString:[[videos allValues] firstObject]], nil);
    
}

@end
