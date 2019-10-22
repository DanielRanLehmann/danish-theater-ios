//
//  Contact.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/26/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Contact : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *firstname;
@property (nonatomic, copy, readonly) NSString *lastname;

@property (nonatomic, copy, readonly) NSString *landline;
@property (nonatomic, copy, readonly) NSString *mobile;

@property (nonatomic, copy, readonly) NSString *position;

@end
