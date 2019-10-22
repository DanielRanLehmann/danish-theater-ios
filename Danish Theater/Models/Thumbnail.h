//
//  Thumbnail.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 11/17/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@import Firebase;

@interface Thumbnail : MTLModel

- (instancetype)initWithCode:(NSString *)code;

@property (nonatomic, strong) FIRStorageReference *defaultImageRef;
@property (nonatomic, strong) FIRStorageReference *mediumImageRef;
@property (nonatomic, strong) FIRStorageReference *highImageRef;
@property (nonatomic, strong) FIRStorageReference *standardImageRef;
@property (nonatomic, strong) FIRStorageReference *maxresImageRef;

@end
