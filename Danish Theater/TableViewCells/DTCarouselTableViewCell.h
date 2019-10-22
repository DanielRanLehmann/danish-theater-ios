//
//  DTCarouselTableViewCell.h
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/18/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTCarouselTableViewCell;

@protocol DTCarouselTableViewCellDelegate <NSObject>

- (void)carouselTableViewCell:(DTCarouselTableViewCell *)caoruselTableViewCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface DTCarouselTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource> 

@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, weak) id <DTCarouselTableViewCellDelegate> delegate;

- (void)addItemWithImageURL:(NSURL *)imageURL caption:(NSString *)caption;
- (void)addItemsWithImageUrls:(NSArray <NSURL *> *)imageUrls captions:(NSArray <NSString *> *)captions;

@property (nonatomic, readonly) NSArray <NSString *> *captions;
@property (nonatomic, readonly) NSArray <NSURL *> *imageUrls;

@end
