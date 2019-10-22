//
//  DTQuery.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/23/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Firebase;

#import "Event.h"
#import "Show.h"
#import "Organization.h"
#import "Venue.h"
#import "Podcast.h"
#import "Episode.h"

@interface DTQuery : NSObject

// SEARCH -> RECENT SEARCHES
+ (void)queryRecentSearchesForUserWithId:(NSString *)userId success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

// SEARCH -> TRENDING
+ (void)queryTrendingEventsLimitedToLast:(NSInteger)limitedToLast success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

// KIDS AGE RANGES

+ (void)queryEventSectionsForKidsAtRanges:(NSArray <NSString *> *)ageRanges limitedToFirst:(NSInteger)limitedToFirst success:(void (^)(NSArray <NSArray <Event *> *> *eventSections))success failure:(void (^)(NSError *error))failure;

+ (void)queryEventsForKidsAtRange:(NSString *)ageRange limitedToFirst:(NSInteger)limitedToFirst success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

+ (void)queryKidsAgeRangesWithSuccess:(void (^)(NSArray <NSString *> *kidsAgeRanges))success failure:(void (^)(NSError *error))failure;

// USER FAVORITES
+ (void)queryFavoriteEventsForUserWithId:(NSString *)userId success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

// Genres
+ (void)queryGenresWithSuccess:(void (^)(NSArray <NSString *> *genres))success failure:(void (^)(NSError *error))failure;

// Podcasts
+ (void)queryEpisodesWithPodcastId:(NSString *)podcastId success:(void (^)(NSArray <Episode *> *episodes))success failure:(void (^)(NSError *error))failure;

+ (void)querySinglePodcastWithId:(NSString *)podcastId success:(void (^)(Podcast *podcast))success failure:(void (^)(NSError *error))failure;

// MUNICIPALITIES
+ (void)queryMunicipalitiesWithSuccess:(void (^)(NSArray <NSString *> *municipalities))success failure:(void (^)(NSError *error))failure;

// VENUE

+ (void)loadSingleVenueWithCode:(NSString *)venueCode success:(void (^)(Venue *venue))success failure:(void (^)(NSError *error))failure;

// ORGANIZATION

+ (void)loadSingleOrganizationWithCode:(NSString *)organizationCode success:(void (^)(Organization *organization))success failure:(void (^)(NSError *error))failure;

// EVENT

+ (void)queryEventsWithQuery:(FIRDatabaseQuery *)query startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

+ (void)loadSingleEventWithCode:(NSString *)eventCode success:(void (^)(Event *event))success failure:(void (^)(NSError *error))failure;

+ (void)loadEventsWithReferencePath:(FIRDatabaseReference *)ref startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;

// SHOW

+ (void)loadShowsWithReferencePath:(FIRDatabaseReference *)ref includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray <Show *> *shows))success failure:(void (^)(NSError *error))failure;

// HELPER

+ (void)queryShallowChildWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSDictionary *child))success failure:(void (^)(NSError *error))failure;

+ (void)existsOrganizationWithCode:(NSString *)organizationCode completion:(void (^)(NSError *error, BOOL organizationExist))completion;

+ (void)totalNumberOfItemsWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSUInteger totalNumberOfItems))success failure:(void (^)(NSError *error))failure;

@end
