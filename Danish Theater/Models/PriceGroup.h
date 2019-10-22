//
//  PriceGroup.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <UIKit/UIKit.h>

@interface PriceGroup : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *currency;
@property (nonatomic, readonly) CGFloat price;

@end
