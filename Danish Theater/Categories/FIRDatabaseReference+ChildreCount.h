//
//  FIRDatabaseReference+ChildreCount.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 7/21/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "FirebaseDatabase/FirebaseDatabase.h"

typedef void (^ChildrenCountCallBack)(NSUInteger childrenCount, NSError *error);
typedef void (^ObserveShallowCallback)(NSDictionary *json, NSError *error);

@interface FIRDatabaseReference (ChildreCount)

- (void)getNumberOfChildrenWithStartingKey:(NSString *)startingKey completion:(ChildrenCountCallBack)completion;

- (void)observeShallowEventTypeValueWithCompletion:(ObserveShallowCallback)completion;



@end
