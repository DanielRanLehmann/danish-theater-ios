//
//  IPAddress.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "IPAddress.h"

@interface IPAddress ()

@property (nonatomic, strong) id response;

@end

@implementation IPAddress

- (instancetype)initWithResponse:(id)response {
    self = [super init];
    if (self) {
        _response = response;
        
        // set all props to nil.
        _city = nil;
        _country = nil;
        _hostname = nil;
        _ip = nil;
        _location = nil;
        _org = nil;
        _postal = nil;
        _region = nil;
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    if (_response[@"city"]) {
        _city = _response[@"city"];
    }
    
    if (_response[@"country"]) {
        _country = _response[@"country"];
    }
    
    if (_response[@"hostname"]) {
        _hostname = _response[@"hostname"];
    }
    
    if (_response[@"ip"]) {
        _ip = _response[@"ip"];
    }
    
    if (_response[@"loc"]) {
        NSArray <NSString *> *coords = [_response[@"loc"] componentsSeparatedByString:@","];
        _location = [[CLLocation alloc] initWithLatitude:[coords[0] doubleValue] longitude:[coords[1] doubleValue]];
    }
    
    if (_response[@"org"]) {
        _org = _response[@"org"];
    }
    
    if (_response[@"postal"]) {
        _postal = _response[@"postal"];
    }
    
    if (_response[@"region"]) {
        _region = _response[@"region"];
    }
    
}

@end
