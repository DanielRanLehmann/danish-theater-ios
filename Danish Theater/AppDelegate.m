//
//  AppDelegate.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+ColorFromHexadecimal.h" 

#import "DanishTheater.h"
#import "DTEventDetailViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "PINCache.h"

@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Global TintColor
    // https://stackoverflow.com/questions/18960321/change-global-tint-color-ios7-ios8
    
    DTGlobalTintColor = [UIColor colorWithHex:@"#FF5252"]; // #00BCD4 cyan color
    [self.window setTintColor:DTGlobalTintColor];
    
    //
    [FIRApp configure];
    [FIRDatabase database].persistenceEnabled = YES; // used for searchVC.
    
    // LOGIN USER ANONYMOUSLY
    FIRUser *user = [FIRAuth auth].currentUser;
    if (!user) {
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"user is anonumous? %@", user.isAnonymous ? @"Yes" : @"No");
            }
            
            else {
                NSLog(@"error from trying to sign in user anonymous: %@", error.localizedDescription);
            }
        }];
        /*
        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"user is anonumous? %@", user.isAnonymous ? @"Yes" : @"No");
            }
            
            else {
                NSLog(@"error from trying to sign in user anonymous: %@", error.localizedDescription);
            }
        }];
        */
    }
    
    // CRASH REPORTS
    [Fabric with:@[[Crashlytics class]]];
    
    [DanishTheater configureTabBarWithWindow:_window];
    
    return YES;
}

// SHORT CUT ACTIONS HAVEN'T BEEN TESTED YET.
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    if ([shortcutItem.type isEqualToString:@"com.danish-theater.appshortcut.favorites"]) {
        
        UIViewController *selectedVC = [(UITabBarController*)self.window.rootViewController selectedViewController];
        [DanishTheater presentFavoritesFromViewController:selectedVC animated:NO completion:^(BOOL cancelled, NSString * _Nonnull selectedEventCode) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:selectedEventCode];
            [selectedVC.navigationController pushViewController:eventDetailVC animated:NO];
        }];
    }
    
    else if ([shortcutItem.type isEqualToString:@"com.danish-theater.appshortcut.search"]) {
        UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
        if (tabController.selectedIndex == 4) {
            return;
        }
        
        tabController.selectedIndex = 4;
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [DanishTheater configureTabBarWithWindow:_window]; // right place to refresh the calendar icon?
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PINCache sharedCache] removeObjectForKey:@"DTPodcastPlaybackAtIndexPath"];
}


@end
