//
//  DTCarouselTableViewCell.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/18/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTCarouselTableViewCell.h"
#import "PureLayout.h"
#import "DTCarouselItemCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface DTCarouselTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) NSMutableArray <NSURL *> *itemImageURLs;
@property (nonatomic, strong) NSMutableArray <NSString *> *itemCaptions;

@end

@implementation DTCarouselTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)addItemWithImageURL:(NSURL *)imageURL caption:(NSString *)caption {
    [_itemImageURLs addObject:imageURL];
    [_itemCaptions addObject:caption];
}

- (void)addItemsWithImageUrls:(NSArray <NSURL *> *)imageUrls captions:(NSArray <NSString *> *)captions {
    _imageUrls = [NSArray arrayWithArray:imageUrls];
    _captions = [NSArray arrayWithArray:captions];
    
    [_itemImageURLs addObjectsFromArray:imageUrls];
    [_itemCaptions addObjectsFromArray:captions];
}

#pragma mark - Configure & Reuse
- (void)configure {
    
    _itemImageURLs = [NSMutableArray array];
    _itemCaptions = [NSMutableArray array];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (142 + 8 + 12) + (2 * 16)) collectionViewLayout:[self flowLayout]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = false;
    
    _collectionView.contentInset = UIEdgeInsetsMake(16, 16, 16, 16);
    
    [self.contentView addSubview:_collectionView];
    
    [_collectionView registerClass:[DTCarouselItemCollectionViewCell class] forCellWithReuseIdentifier:@"CarouselItemCell"];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UICollectionViewLayout *)flowLayout {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
   
    [flowLayout setItemSize:CGSizeMake(94, 142 + 12 + 8)];
    [flowLayout setMinimumInteritemSpacing:16.0];
    
    //flowLayout.itemSize = self.collectionView.frame.size;
    
    return flowLayout;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_itemCaptions count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DTCarouselItemCollectionViewCell *cell = (DTCarouselItemCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CarouselItemCell" forIndexPath:indexPath];
    
    NSURL *imageURL = _itemImageURLs[indexPath.row];
    NSString *titleText = _itemCaptions[indexPath.row];
    
    [cell.imageView setImageWithURL:imageURL];
    [cell.captionLabel setText:titleText];
    
    [cell updateConstraints];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_delegate respondsToSelector:@selector(carouselTableViewCell:didSelectItemAtIndexPath:)]) {
        [_delegate carouselTableViewCell:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _collectionView = nil;
}

#pragma mark - Layout

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        
        [_collectionView autoPinEdgesToSuperviewEdges];
        
        [_collectionView autoSetDimension:ALDimensionHeight toSize:(142 + 8 + 12) + (2 * 16)];
        //[_collectionView autoSetDimension:ALDimensionWidth toSize:self.contentView.bounds.size.width];
        
        
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
