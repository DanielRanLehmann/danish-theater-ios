//
//  Podcast.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/25/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

typedef NS_ENUM(NSInteger, DTPodcastType) {
    DTPodcastTypeAudio,
    DTPodcastTypeVideo
};

@interface Podcast : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *podcastId;

@property (nonatomic,  copy, readonly) NSString *localizedDescription;
@property (nonatomic,  copy, readonly) NSString *name;
@property (nonatomic,  copy, readonly) NSString *email;
@property (nonatomic, readonly) int publicationYear;
@property (nonatomic, readonly) DTPodcastType type;

@end
