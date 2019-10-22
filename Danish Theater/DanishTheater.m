//
//  DanishTheater.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/7/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DanishTheater.h"
#import "OrderedDictionary.h"

#define DEFAULT_QUERY_LIMIT 25 // make this const vars. instead of this. specific for the different queries too.

UIColor *DTGlobalTintColor = nil;

@interface DanishTheater ()

- (FIRDatabaseReference *)databaseReferenceWithPath:(NSString *)path;

@end

@implementation DanishTheater

+ (instancetype)sharedInstance
{
    static DanishTheater *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DanishTheater alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

#pragma mark - Private
- (FIRDatabaseReference *)databaseReferenceWithPath:(NSString *)path {
    FIRDatabaseReference *ref = nil;
    NSArray *separatedPaths = [path componentsSeparatedByString:@"/"];
    if (separatedPaths.count >= 2) {
        ref = [[[FIRDatabase database] referenceWithPath:[separatedPaths firstObject]] child:[separatedPaths lastObject]];
    } else {
        ref = [[FIRDatabase database] referenceWithPath:[separatedPaths firstObject]];
    }
    
    return ref;
}

#pragma mark - Present ViewControllers
+ (void)presentFavoritesFromViewController:(UIViewController *)vc animated:(BOOL)animated completion:(DTFavoritesCompletion)completion {
    
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DTFavoritesViewController *favoritesVC = [main instantiateViewControllerWithIdentifier:@"Favorites"];
    favoritesVC.completion = completion;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:favoritesVC];
    [vc presentViewController:navigationController animated:YES completion:nil];
}

+ (void)pickMunicipalityFromViewController:(UIViewController *)vc selectedMunicipality:(NSString *)selectedMunicipality usersLocalMunicipality:(NSString *)usersLocalMunicipality animated:(BOOL)animated completion:(DTMunicipalityPickerCompletion)completion {
    
    [[DanishTheater sharedInstance] loadMunicipalitiesWithSuccess:^(NSArray<NSString *> *municipalities) {
       
        DTMunicipalityPickerController *municipalityPicker = [[DTMunicipalityPickerController alloc] initWithMunicipalities:municipalities];
        municipalityPicker.selectedMunicipality = selectedMunicipality;
        municipalityPicker.usersLocalMunicipaltiy = usersLocalMunicipality;
        municipalityPicker.completion = completion;
        [vc presentViewController:municipalityPicker animated:animated completion:nil];
    
    } failure:nil];
}

#pragma mark - Queries

- (void)loadEventsWithReferencePath:(FIRDatabaseReference *)ref startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure {

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
                    }
                }
            }
            
            success([events copy]);
            return;
        }
        
        else {
            success(events); // return empty.. not an error?
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}



// ONLY TESTING PURPOSES.

- (void)loadEventSnippetsAtRefPath:(NSString *)path startingWithCode:(NSString *)code limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray *eventSnippets))success failure:(void (^)(NSError *error))failure {
    
    NSMutableArray *eventSnippets = [NSMutableArray array];
    
    FIRDatabaseReference *ref = [self databaseReferenceWithPath:path];
    FIRDatabaseQuery *query = nil;
    if (code == nil) {
        query = [[ref queryOrderedByKey] queryLimitedToFirst:limit];
        
    } else {
        query = [[[ref queryOrderedByKey] queryStartingAtValue:code] queryLimitedToFirst:limit];
    }
    
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            
            //[eventSnippets removeLastObject]; // removing the loadingCell
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                if (![child.key isEqualToString:code]) {
                    Event *event = [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:child.value error:nil];
                    if (event) {
                        event.code = child.key;
                        [eventSnippets addObject:event];
                    }
                }
            }
            
            NSLog(@"number of children in batch: %lu", [eventSnippets count]);
            success([eventSnippets copy]);
            return;
        }
        
        else {
            success(@[]);
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

// DTCalendarViewController, DTShowsViewController, DTOrganizationDetailViewController

- (void)loadShowsWithReferencePath:(FIRDatabaseReference *)ref includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray <Show *> *shows))success failure:(void (^)(NSError *error))failure {

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

- (void)loadShowsAtRefPath:(NSString *)path includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray *shows))success failure:(void (^)(NSError *error))failure {
    
    FIRStorage *storage = [FIRStorage storage];
    FIRDatabaseReference *ref = [self databaseReferenceWithPath:path];
    
    NSMutableArray *shows = [NSMutableArray array];
    NSMutableArray <NSString *> *months = [NSMutableArray array];
    
    [[[[ref  queryOrderedByChild:@"timestamp"] queryStartingAtValue:@(timestamp)] queryLimitedToFirst:limit] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            
            NSString *startingCode = nil;
            
            NSEnumerator *children = [snapshot children];
            FIRDataSnapshot *child;
            while (child = [children nextObject]) {
                
                // LOGIC
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
            success(nil, nil, nil);
            return;
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
        return;
    }];
}

// DTCalendarViewController, DTMunicipalityPickerController

- (void)loadMunicipalitiesWithSuccess:(void (^)(NSArray <NSString *> *municipalities))success failure:(void (^)(NSError *error))failure {
    
    [[DanishTheater sharedInstance] loadKeysAtRefPath:@"municipalities" sortedAlphabetically:YES success:^(NSArray<NSString *> *keys) {
        success(keys);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

// DTGenresMasterViewController

- (void)loadGenresWithSuccess:(void (^)(NSArray <NSString *> *genres))success failure:(void (^)(NSError *error))failure {
    
    [[DanishTheater sharedInstance] loadKeysAtRefPath:@"genres" sortedAlphabetically:YES success:^(NSArray<NSString *> *keys) {
        success(keys);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)loadKidsAgeRangesWithSuccess:(void (^)(NSArray <NSString *> *kidsAgeRanges))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [self databaseReferenceWithPath:@"kids-age-ranges"];
    FIRDatabaseQuery *query = [ref queryOrderedByChild:@"queryOrder"];
    [query observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSMutableArray *tempKeys = [NSMutableArray array];
        NSEnumerator *children = [snapshot children];
        FIRDataSnapshot *child;
        while (child = [children nextObject]) {
            [tempKeys addObject:child.key];
        }
        
        success([tempKeys copy]);
        return;
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
        return;
    }];

    /*
    [[DanishTheater sharedInstance] loadKeysAtRefPath:[[self databaseReferenceWithPath:@"kids-age-ranges"] queryOrderedByChild:@"orderPriority"] sortedAlphabetically:NO success:^(NSArray<NSString *> *keys) {
        success(keys);
    } failure:^(NSError *error) {
        failure(error);
    }];
    */
}

// this method should REPLACE the extension of the class 'FIRDatabase + childrenCount "
- (void)countNumberOfKeysAtRefPath:(NSString *)path startingWithKey:(NSString * _Nullable)startingKey success:(void (^)(NSUInteger numberOfKeys))success {
    
    [self countNumberOfKeysAtRefPath:path startingWithKey:startingKey success:^(NSUInteger numberOfKeys) {
        success(numberOfKeys);
    } failure:nil];
}

- (void)totalNumberOfItemsWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSUInteger totalNumberOfItems))success failure:(void (^)(NSError *error))failure {
    
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

// ONLY FOR TESTING PURPOSES.
- (void)countNumberOfKeysAtRefPath:(NSString *)path startingWithKey:( NSString * _Nullable)startingKey success:(void (^)(NSUInteger numberOfKeys))success failure:(nullable void (^)(NSError *error))failure {
    
    FIRDatabaseReference *ref = [self databaseReferenceWithPath:path];
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
                                                                
                                                               
                                                                NSUInteger numberOfKeys = [[json allKeys] count];
                                                                /*
                                                                if (startingKey) {
                                                                
                                                                    NSMutableDictionary *tempJSON = [NSMutableDictionary dictionaryWithDictionary:json];
                                                                    NSLog(@"startingKey => %@", startingKey);
                                                                    
                                                                    for (NSString *key in json) {
                                                                        if ([key isEqualToString:startingKey]) {
                                                                            NSLog(@"don't count no more.");
                                                                            // break;
                                                                        }
                                                                        
                                                                        NSLog(@"key: %@", key);
                                                                        // [tempJSON removeObjectForKey:key];
                                                                    }
                                                                 */
                                                                    
                                                                    /*
                                                                    NSLog(@"tempjson: %@", tempJSON);
                                                                    [tempJSON enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
                                                                        
                                                                        if ([key isEqualToString:startingKey]) {
                                                                            *stop = YES;
                                                                            return;
                                                                        }
                                                                        
                                                                        NSLog(@"key: %@", key);
                                                                        [tempJSON removeObjectForKey:key];
                                                                        
                                                                    }];
                                                                    */
                                                                    
                                                                  //   numberOfKeys = tempJSON.count;
                                                                // }
                                                                
                                                                success(numberOfKeys);
                                                                return;
                                                            }
                                                        }];
            [dataTask resume];
        });
        
    }];
}

- (void)loadKeysAtRefPath:(NSString *)refPath sortedAlphabetically:(BOOL)sortedAlphabetically success:(void (^)(NSArray <NSString *> *keys))success failure:(void (^)(NSError *error))failure {

    FIRDatabaseReference *ref = [self databaseReferenceWithPath:refPath];
    [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.exists) {
            if (!sortedAlphabetically) {
                // maintain the order by doing like this.
                NSMutableArray *tempKeys = [NSMutableArray array];
                NSEnumerator *children = [snapshot children];
                FIRDataSnapshot *child;
                while (child = [children nextObject]) {
                    [tempKeys addObject:child.key];
                }
                
                success([tempKeys copy]);
                return;
            }
            
            else {
                success([[[snapshot value] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]);
                return;
            }
        }
        
        success(nil);
        return;
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        failure(error);
        return;
    }];
}

// DTKidsViewController query method should just use eventSnippets ref at the very top of this file?

+ (void)configureTabBarWithWindow:(UIWindow *)window {
    
    // SETUP TABBAR
    UITabBarController *tabBarController = (UITabBarController*)window.rootViewController;
    
    // --> HOMEPAGE
    [[tabBarController.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"HOMEPAGE_TITLE", nil)];
    
    [[tabBarController.tabBar.items objectAtIndex:0] setImage:[[UIImage imageNamed:@"ic_home"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [[tabBarController.tabBar.items objectAtIndex:0] setSelectedImage:[[UIImage imageNamed:@"ic_home_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    
    // --> KIDS
    [[tabBarController.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"KIDS_TITLE", nil)];
    
    [[tabBarController.tabBar.items objectAtIndex:1] setImage:[[UIImage imageNamed:@"ic_balloons"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [[tabBarController.tabBar.items objectAtIndex:1] setSelectedImage:[[UIImage imageNamed:@"ic_balloons_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    // --> CALENDAR
    [[tabBarController.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"CALENDAR_TITLE", nil)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    [[tabBarController.tabBar.items objectAtIndex:2] setImage:[[UIImage imageNamed:[NSString stringWithFormat:@"ic_calendar_%@", date]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [[tabBarController.tabBar.items objectAtIndex:2] setSelectedImage:[[UIImage imageNamed:[NSString stringWithFormat:@"ic_calendar_%@_filled", date]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    // --> GENRES
    [[tabBarController.tabBar.items objectAtIndex:3] setTitle:NSLocalizedString(@"GENRES_TITLE", nil)];
    
    [[tabBarController.tabBar.items objectAtIndex:3] setImage:[[UIImage imageNamed:@"ic_masks"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [[tabBarController.tabBar.items objectAtIndex:3] setSelectedImage:[[UIImage imageNamed:@"ic_masks_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    // --> SEARCH
    [[tabBarController.tabBar.items objectAtIndex:4] setTitle:NSLocalizedString(@"SEARCH_TITLE", nil)];
    
    [[tabBarController.tabBar.items objectAtIndex:4] setImage:[[UIImage imageNamed:@"ic_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [[tabBarController.tabBar.items objectAtIndex:4] setSelectedImage:[[UIImage imageNamed:@"ic_search_filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

@end
