//
//  Accreditation.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Accreditation : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *firstname;
@property (nonatomic, copy, readonly) NSString *lastname;
@property (nonatomic, copy, readonly) NSString *positionName;
@property (nonatomic, copy, readonly) NSString *positionTypeName;
@property (nonatomic, readonly) NSUInteger index;

@end
