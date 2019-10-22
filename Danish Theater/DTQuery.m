//
//  DTQuery.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 1/23/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTQuery.h"
#import "NSDate+Helpers.h"

@implementation DTQuery

#pragma mark - Queries

// SERACH -> TRENDING
+ (void)queryTrendingEventsLimitedToLast:(NSInteger)limitedToLast success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [[FIRDatabase database] referenceWithPath:@"event-snippets"];
    [DTQuery loadEventsWithReferencePath:ref startingWithCode:nil limitedToFirst:limitedToLast success:^(NSArray<Event *> *events) {
        success(events);
    } failure:^(NSError *error) {
        failure(error); 
    }];
}

// KIDS AGE RANGES

+ (void)queryEventSectionsForKidsAtRanges:(NSArray <NSString *> *)ageRanges limitedToFirst:(NSInteger)limitedToFirst success:(void (^)(NSArray <NSArray <Event *> *> *eventSections))success failure:(void (^)(NSError *error))failure {
    
    NSMutableArray *eventSections = [NSMutableArray arrayWithArray:ageRanges];
    
    for (int i = 0; i < ageRanges.count; i++) {
        
        NSString *ageRange = ageRanges[i];
        [DTQuery queryEventsForKidsAtRange:ageRange limitedToFirst:limitedToFirst success:^(NSArray<Event *> *events) {
            
            if (events.count <= 0) {
                success(nil);
            } else {
                [eventSections replaceObjectAtIndex:[eventSections indexOfObject:ageRange] withObject:events];
               
                if (i == ageRanges.count - 1) {
                    success(eventSections);
                }
            }
            
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

+ (void)queryEventsForKidsAtRange:(NSString *)ageRange limitedToFirst:(NSInteger)limitedToFirst success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [DTQuery loadEventsWithReferencePath:[[ref child:@"kids-event-snippets"] child:ageRange] startingWithCode:nil limitedToFirst:5 success:^(NSArray<Event *> *events) {
        
        if (events.count <= 0) {
            success(nil);
        } else {
            success(events);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

+ (void)queryKidsAgeRangesWithSuccess:(void (^)(NSArray <NSString *> *kidsAgeRanges))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"kids-age-ranges"] queryOrderedByChild:@"queryOrder"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            NSMutableArray *ageRanges = [NSMutableArray array];
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                [ageRanges addObject:child.key];
            }
            
            success([ageRanges copy]);
            
        } else {
            success(nil);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// USER FAVORITES

+ (void)queryFavoriteEventsForUserWithId:(NSString *)userId success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [[[[ref child:@"user-favorites"] child:userId] queryOrderedByKey] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
        
            NSMutableArray *events = [NSMutableArray array]; // requires sentinel / placeholder values.
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                [events addObject:child.key];
            }
            
            events = [[[events reverseObjectEnumerator] allObjects] mutableCopy];
            
            for (int i = 0; i < events.count; i++) {
                
                NSString *evCode = events[i];
                [DTQuery loadSingleEventWithCode:evCode success:^(Event *event) {
                    
                    [events replaceObjectAtIndex:[events indexOfObject:evCode] withObject:event];
                    
                    if (i == [events count] - 1) {
                        success(events);
                    }
                    
                } failure:^(NSError *error) {
                    // nullable this handler when possible, "internal error".
                }];
            }
            
        } else {
            success(nil);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// Genres
+ (void)queryGenresWithSuccess:(void (^)(NSArray <NSString *> *genres))success failure:(void (^)(NSError *error))failure {
    
    [DTQuery queryShallowChildWithReferencePath:[[FIRDatabase database] referenceWithPath:@"genres"] success:^(NSDictionary *child) {
        
        if (child) {
            NSArray <NSString *> *genres = child.allKeys;
            success(genres);
        } else {
            success(@[]); 
        }
        
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

// Podcasts
+ (void)queryEpisodesWithPodcastId:(NSString *)podcastId success:(void (^)(NSArray<Episode *> *))success failure:(void (^)(NSError *))failure {
    
    NSMutableArray <Episode *> *episodes = [NSMutableArray array];
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [[[ref child:@"podcast-episodes"] child:podcastId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                Episode *episode = [MTLJSONAdapter modelOfClass:Episode.class fromJSONDictionary:child.value error:nil];
                if (episode) {
                    episode.episodeId = child.key;
                    [episodes addObject:episode];
                }
            }
            
            success([[episodes reverseObjectEnumerator] allObjects]);
            return;
        }
        
        else {
            success(@[]); // return empty.. not an error?
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];

}

+ (void)querySinglePodcastWithId:(NSString *)podcastId success:(void (^)(Podcast *podcast))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"podcasts"] child:podcastId] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            Podcast *podcast = [MTLJSONAdapter modelOfClass:Podcast.class fromJSONDictionary:snapshot.value error:nil];
            if (podcast) {
                podcast.podcastId = podcastId;
                success(podcast);
            }
        } else {
            success(nil); // should be a custom failure.. 404 not found?
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// MUNICIPALITIES

+ (void)queryMunicipalitiesWithSuccess:(void (^)(NSArray <NSString *> *municipalities))success failure:(void (^)(NSError *error))failure {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] referenceWithPath:@"municipalities"];
    [DTQuery queryShallowChildWithReferencePath:ref success:^(NSDictionary *child) {
     
        success([child allKeys]);
        return;
    
    } failure:^(NSError *error) {
        failure(error);
    }];
}

// VENUE

+ (void)loadSingleVenueWithCode:(NSString *)venueCode success:(void (^)(Venue *venue))success failure:(void (^)(NSError *error))failure {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"venues"] child:venueCode] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            Venue *venue = [MTLJSONAdapter modelOfClass:Venue.class fromJSONDictionary:snapshot.value error:nil];
            if (venue) {
                venue.code = venueCode;
                success(venue);
            }
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}


// ORGANIZATION

+ (void)loadSingleOrganizationWithCode:(NSString *)organizationCode success:(void (^)(Organization *organization))success failure:(void (^)(NSError *error))failure {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"organizations"] child:organizationCode] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            NSError *organizationError = nil;
            Organization *organization = [MTLJSONAdapter modelOfClass:Organization.class fromJSONDictionary:snapshot.value error:&organizationError];
            if (!organizationError) {
                organization.code = organizationCode;
                success(organization);                
                
            } else {
                failure(organizationError);
            }
        
        } else {
            success(nil);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// EVENT

// evolve later on when working on explore city.
+ (void)queryEventsWithQuery:(FIRDatabaseQuery *)query startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {
    
    NSMutableArray <Event *> *events = [NSMutableArray array];
    /*
    if (!startingCode) {
        query = [query queryLimitedToFirst:limit];
        
    } else {
        query = [[query queryStartingAtValue:startingCode] queryLimitedToFirst:limit + 1]; // + 1 for the same startingCode.
    }
    */
    
    if (limit != 0) {
        query = [query queryLimitedToFirst:limit];
    }
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                if (![child.key isEqualToString:startingCode]) {
                    Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:child.value error:nil];
                    if (event) {
                        event.code = child.key;
                        [events addObject:event];
                    }
                }
            }
            
            success([events copy]);
            return;
        
        }
        
        else {
            success(@[]); // return empty.. not an error?
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

+ (void)loadSingleEventWithCode:(NSString *)eventCode success:(void (^)(Event *event))success failure:(void (^)(NSError *error))failure {
 
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    [[[ref child:@"events"] child:eventCode] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            NSError *eventError = nil;
            Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:snapshot.value error:&eventError];
            if (!eventError) {
                event.code = eventCode;
                success(event);
                
            } else {
                failure(eventError);
            }
        } else {
            success(nil);
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

+ (void)loadEventsWithReferencePath:(FIRDatabaseReference *)ref startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {
    
    NSMutableArray <Event *> *events = [NSMutableArray array];
    FIRDatabaseQuery *query = nil;
    
    if (!startingCode) {
        query = [[ref queryOrderedByKey] queryLimitedToFirst:limit];
        
    } else {
        query = [[[ref queryOrderedByKey] queryStartingAtValue:startingCode] queryLimitedToFirst:limit + 1]; // + 1 for the same startingCode.
    }
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                if (![child.key isEqualToString:startingCode]) {
                    Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:child.value error:nil];
                    if (event) {
                        event.code = child.key;
                        [events addObject:event];
                    
                    } // return failure here, and end the rest of the loading?
                }
            }
            
            success([events copy]);
            return;
        }
        
        else {
            success(@[]); // return empty.. not an error?
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// SHOWS

+ (void)loadShowsWithReferencePath:(FIRDatabaseReference *)ref includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray <Show *> *shows))success failure:(void (^)(NSError *error))failure {
    
    FIRStorage *storage = [FIRStorage storage];
    
    NSMutableArray <Show *> *shows = [NSMutableArray array];
    NSMutableArray <NSString *> *months = [NSMutableArray array];
    
    [[[[ref  queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(timestamp)] queryLimitedToFirst:limit] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            NSString *startingCode = nil;
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                Show *show = [MTLJSONAdapter modelOfClass:Show.class fromJSONDictionary:child.value error:nil];
                if (show) {
                    show.code = child.key;
                    show.imageRef = [storage referenceWithPath:[NSString stringWithFormat:@"thumbnails/events/%@/default.jpeg", show.eventCode]]; // should use the Thumbnail class?
                    if (!startingCode) {
                        startingCode = show.code;
                    }
                    
                    if (!includeMonths) {
                        [shows addObject:show];
                    }
                    
                    else {
                        
                        NSDate *showDate = [NSDate dateWithTimeIntervalSince1970:show.timestamp];
                        int updateAtIndex = -1;
                        NSString *sectionTitle = nil;
                        
                        // TODAY
                        if ([showDate isBetweenDate:[[NSDate date] beginningOfDay] andDate:[[NSDate date] endOfDay]]) {
                            updateAtIndex = 0;
                            sectionTitle = NSLocalizedString(@"TABLEVIEW_SECTION_TITLE_TODAY", nil);
                            
                        }
                        
                        // TOMORROW
                        else if ([showDate isBetweenDate:[[[NSDate date] appendDays:1] beginningOfDay] andDate:[[[NSDate date] appendDays:1] endOfDay]]) {
                            updateAtIndex = 1;
                            sectionTitle = NSLocalizedString(@"TABLEVIEW_SECTION_TITLE_TOMORROW", nil);
                        }
                        
                        // THIS WEEK
                        else if ([showDate isBetweenDate:[[[NSDate date] beginningOfWeek] beginningOfDay] andDate:[[[NSDate date] endOfWeek] endOfDay]]) {
                            updateAtIndex = 2;
                            sectionTitle = NSLocalizedString(@"TABLEVIEW_SECTION_TITLE_THIS_WEEK", nil);
                        }
                        
                        // THIS MONTH
                        else if ([showDate isBetweenDate:[[NSDate date] beginningOfMonth] andDate:[[NSDate date] endOfMonth]]) {
                            updateAtIndex = 3;
                            sectionTitle = NSLocalizedString(@"TABLEVIEW_SECTION_TITLE_THIS_MONTH", nil);
                        }
                        
                        
                        // ADD A MONTH / LIST OPERATION.
                        if (updateAtIndex == -1) {
                            
                            NSString *preferredLocalization = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
                            
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[preferredLocalization isEqualToString:@"da"] ? @"da" : @"en_US_POSIX"];
                            [dateFormatter setDateFormat:@"MMMM yyyy"];
                            
                            sectionTitle = [dateFormatter stringFromDate:showDate];
                        }
                        
                        NSUInteger sectionIndex = [months indexOfObject:sectionTitle];
                        if (sectionIndex != NSNotFound) {
                            
                            updateAtIndex = (int)sectionIndex;
                            
                            NSMutableArray *updatedMutArray = [NSMutableArray arrayWithArray:[shows objectAtIndex:updateAtIndex]];
                            [updatedMutArray addObject:show];
                            
                            [shows replaceObjectAtIndex:updateAtIndex withObject:updatedMutArray];
                        }
                        
                        else {
                            [months addObject:sectionTitle];
                            
                            NSArray *newSectionArr = @[show];
                            [shows addObject:newSectionArr];
                        }
                    }
                }
            }
            
            success(startingCode, months, shows);
            return;
        }
        
        else {
            success(nil, @[], @[]);
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
        return;
    }];
}


# pragma mark - Convenience Methods

+ (void)queryShallowChildWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSDictionary *child))success failure:(void (^)(NSError *error))failure {
    
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            success(snapshot.value);
        } else {
            success(nil);
        }
        return;
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
        return;
    }];
}


+ (void)existsOrganizationWithCode:(NSString *)organizationCode completion:(void (^)(NSError *error, BOOL organizationExist))completion {

    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [[[ref child:@"organizations"] child:organizationCode] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        BOOL organizationExist = false;
        if (snapshot.exists) {
            
            organizationExist = true;
        }
        completion(nil, organizationExist);
        return;
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        completion(error, nil);
        return;
    }];
}

+ (void)totalNumberOfItemsWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSUInteger totalNumberOfItems))success failure:(void (^)(NSError *error))failure {
    
    FIRUser *user = [FIRAuth auth].currentUser;
    [user getIDTokenWithCompletion:^(NSString * _Nullable token, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.json?shallow=true&auth=%@", ref.URL, token]]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10.0];
            [request setHTTPMethod:@"GET"];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                failure(error);
                                                                return;
                                                                
                                                            } else {
                                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                     options:kNilOptions
                                                                                                                       error:nil];
                                                                
                                                                success([[json allKeys] count]);
                                                                return;
                                                            }
                                                        }];
            [dataTask resume];
        });
        
    }];
}


@end
