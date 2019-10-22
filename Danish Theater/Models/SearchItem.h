//
//  SearchItem.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 2/1/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <Mantle/Mantle.h>

typedef enum : NSUInteger {
    DTSearchItemContentTypeEvent,
    DTSearchItemContentTypeOrganization
} DTSearchItemContentType;

@interface SearchItem : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *searchItemId;

@property (nonatomic) NSTimeInterval lastVisitAt;

@property (nonatomic, strong) NSDictionary *title;
@property (nonatomic, copy, readonly) NSString *localizedTitle; // don't include this?, but it's nice to have, from db -> frontend.

@property (nonatomic) NSInteger visitCount; // do something smart incrementing wise, like lastVisitAt.

@property (nonatomic, copy) NSString *contentId;
@property (nonatomic) DTSearchItemContentType contentType;

@end
