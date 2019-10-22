//
//  UIScrollView+DTPreloading.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/9/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UIScrollView+DTPreloading.h"
#import <objc/runtime.h>

CGFloat DTDefaultPreloadingOffsetFromBottom = 1000.0;

@interface DZNWeakObjectContainer : NSObject

@property (nonatomic, readonly, weak) id weakObject;

- (instancetype)initWithWeakObject:(id)object;

@end

// static char const * const kPreloadingDataSource =     "preloadingDataSource";
static char const * const kPreloadingDelegate =   "preloadingDelegate";
static NSString *kExpectedNumberOfRows = @"expectedNumberOfRows";
static NSString *kPreloadingInProgressKey = @"preloadingInProgress";
static NSString *kPreloadingOffsetFromBottomKey = @"preloadingOffsetFromBottom";

@implementation UIScrollView (DTPreloading)

- (void)preloadingListener {
    
    if (self.preloadingDelegate) {
        
        CGFloat bottomInset = self.contentInset.bottom;
        CGFloat bottomEdge = self.contentOffset.y + self.frame.size.height - bottomInset;
        
        NSLog(@"rows count: %lu", [self rowsCount]);
        NSLog(@"expectednumberofrows: %lu", [self expectedNumberOfRows]);
        
        if ((bottomEdge + self.preloadingOffsetFromBottom) >= self.contentSize.height
            && !self.preloadingInProgress
            /*[self rowsCount] < self.expectedNumberOfRows*/) {
            
            NSLog(@"should preload right now.");
            [(id)self.preloadingDelegate shouldPreloadRows:self];
        }
    }
}

- (void)detachPreloadingListener {
    self.preloadingDelegate = nil;
}

/* scrollViewDidScroll not being called in UIScrollView category */

#pragma mark - Setters (Public)

- (NSUInteger)expectedNumberOfRows {
    return [objc_getAssociatedObject(self, &kExpectedNumberOfRows) unsignedIntegerValue];
}

- (void)setExpectedNumberOfRows:(NSUInteger)expectedNumberOfRows
{
    // Convert float value to NSNumber object and associate with self
    objc_setAssociatedObject(self, &kExpectedNumberOfRows, [NSNumber numberWithUnsignedInteger:expectedNumberOfRows],  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)preloadingInProgress {
    return [objc_getAssociatedObject(self, &kPreloadingInProgressKey) unsignedIntegerValue];
}

- (void)setPreloadingInProgress:(BOOL)preloadingInProgress {
    // Convert float value to NSNumber object and associate with self
    objc_setAssociatedObject(self, &kPreloadingInProgressKey, [NSNumber numberWithBool:preloadingInProgress],  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)preloadingOffsetFromBottom {
    return [objc_getAssociatedObject(self, &kPreloadingOffsetFromBottomKey) floatValue];
}

- (void)setPreloadingOffsetFromBottom:(CGFloat)preloadingOffsetFromBottom {
    
    // Convert float value to NSNumber object and associate with self
    objc_setAssociatedObject(self, &kPreloadingOffsetFromBottomKey, [NSNumber numberWithFloat:preloadingOffsetFromBottom],  OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


 - (void)setPreloadingDelegate:(id<DTPreloadingDelegate>)preloadingDelegate {
     if (!preloadingDelegate) {
         // invalidate something.
     }
     
     objc_setAssociatedObject(self, kPreloadingDelegate, [[DZNWeakObjectContainer alloc] initWithWeakObject:preloadingDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

/*
- (void)setPreloadingDataSource:(id<DTPreloadingDataSource>)preloadingDataSource {
    if (!preloadingDataSource) {
        // invalidate something
    }
    
    objc_setAssociatedObject(self, kPreloadingDelegate, [[DZNWeakObjectContainer alloc] initWithWeakObject:preloadingDataSource], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
*/

#pragma mark - Getters (Public)
/*
- (id<DTPreloadingDataSource>)preloadingDataSource
{
    DZNWeakObjectContainer *container = objc_getAssociatedObject(self, kPreloadingDataSource);
    return container.weakObject;
}
*/

- (id<DTPreloadingDelegate>)preloadingDelegate
{
    DZNWeakObjectContainer *container = objc_getAssociatedObject(self, kPreloadingDelegate);
    return container.weakObject;
}

#pragma mark - Getters (Private)
- (NSInteger)rowsCount
{
    NSInteger items = 0;
    
    // UIScollView doesn't respond to 'dataSource' so let's exit
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}

@end
