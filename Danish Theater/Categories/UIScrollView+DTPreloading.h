//
//  UIScrollView+DTPreloading.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/9/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat DTDefaultPreloadingOffsetFromBottom; // defaults to 1000.0

@protocol DTPreloadingDelegate <NSObject, UIScrollViewDelegate>

- (void)shouldPreloadRows:(UIScrollView *)scrollView;

@end

/*
@protocol DTPreloadingDataSource <NSObject>

@required
- (BOOL)preloadingInProgress:(UIScrollView *)scrollView;
- (NSUInteger)excpectedNumberOfItems:(UIScrollView *)scrollView;

@optional
- (CGFloat)preloadingOffsetFromBottom:(UIScrollView *)scrollView;

@end
*/

@interface UIScrollView (DTPreloading) <UIScrollViewDelegate> 

@property (nonatomic, weak) IBOutlet id <DTPreloadingDelegate> preloadingDelegate;
// @property (nonatomic, weak) IBOutlet id <DTPreloadingDataSource> preloadingDataSource;

@property (nonatomic) BOOL preloadingInProgress;
@property NSUInteger expectedNumberOfRows;
@property (nonatomic) CGFloat preloadingOffsetFromBottom;

- (void)preloadingListener;
- (void)detachPreloadingListener;

@end
