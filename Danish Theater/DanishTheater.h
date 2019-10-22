//
//  DanishTheater.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/7/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DTFavoritesViewController.h"
#import "DTMunicipalityPickerController.h" 

#import "Event.h"
@import Firebase;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT UIColor *DTGlobalTintColor;

typedef void (^DTFavoritesCompletion)(BOOL cancelled, NSString *selectedEventCode);
typedef void (^DTMunicipalityPickerCompletion)(BOOL cancelled, NSString *selectedMunicipality);

@interface DanishTheater : NSObject

+ (instancetype)sharedInstance; // coming soon.

// VC helpers
+ (void)presentFavoritesFromViewController:(UIViewController *)vc animated:(BOOL)animated completion:(DTFavoritesCompletion)completion;

+ (void)pickMunicipalityFromViewController:(UIViewController *)vc selectedMunicipality:(NSString *)selectedMunicipality usersLocalMunicipality:(NSString *)usersLocalMunicipality animated:(BOOL)animated completion:(DTMunicipalityPickerCompletion)completion;


// THE QUERIES
- (void)totalNumberOfItemsWithReferencePath:(FIRDatabaseReference *)ref success:(void (^)(NSUInteger totalNumberOfItems))success failure:(void (^)(NSError *error))failure;

// PRODUCTION READY
- (void)loadEventsWithReferencePath:(FIRDatabaseReference *)ref startingWithCode:(NSString *)startingCode limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray <Event *> *events))success failure:(void (^)(NSError *error))failure;


// ONLY TESTING PURPOSES.
- (void)loadEventSnippetsAtRefPath:(NSString *)path startingWithCode:(NSString *)code limitedToFirst:(NSUInteger)limit success:(void (^)(NSArray *eventSnippets))success failure:(void (^)(NSError *error))failure;



///////////////

// PRODUCTION READY
- (void)loadShowsWithReferencePath:(FIRDatabaseReference *)ref includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray <Show *> *shows))success failure:(void (^)(NSError *error))failure;

// ONLY FOR TESTING PURPOSES
- (void)loadShowsAtRefPath:(NSString *)path includeMonths:(BOOL)includeMonths startingWithTimestamp:(NSTimeInterval)timestamp limitedToFirst:(NSUInteger)limit success:(void (^)(NSString *startingCode, NSArray <NSString *> *months, NSArray *shows))success failure:(void (^)(NSError *error))failure;


- (void)loadMunicipalitiesWithSuccess:(void (^)(NSArray <NSString *> *municipalities))success failure:(void (^)(NSError *error))failure;


- (void)loadGenresWithSuccess:(void (^)(NSArray <NSString *> *genres))success failure:(void (^)(NSError *error))failure;
- (void)loadKidsAgeRangesWithSuccess:(void (^)(NSArray <NSString *> *kidsAgeRanges))success failure:(void (^)(NSError *error))failure;

#pragma mark - Helper
- (void)countNumberOfKeysAtRefPath:(NSString *)path startingWithKey:( NSString * _Nullable)startingKey success:(void (^)(NSUInteger numberOfKeys))success;

- (void)countNumberOfKeysAtRefPath:(NSString *)path startingWithKey:( NSString * _Nullable)startingKey success:(void (^)(NSUInteger numberOfKeys))success failure:(nullable void (^)(NSError *error))failure;

+ (void)configureTabBarWithWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
