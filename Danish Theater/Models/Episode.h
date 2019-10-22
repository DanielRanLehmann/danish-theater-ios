//
//  Episode.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/25/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Episode : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *episodeId;

@property (nonatomic,  copy, readonly) NSString *localizedTitle;
@property (nonatomic, readonly) NSTimeInterval createdAt;
@property (nonatomic, copy, readonly) NSString *podcastName;
@property (nonatomic, copy, readonly) NSString *podcastId;

@property (nonatomic, readonly) NSUInteger durationInSeconds;

@end
