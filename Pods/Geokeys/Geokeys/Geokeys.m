//
//  Geokeys.m
//  Geokeys
//
//  Created by Daniel Ran Lehmann on 3/30/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Geokeys.h"
#import "NSString+FormatCoordinates.h"

@interface Geokeys ()

@property (copy, nonatomic) NSString *login;
@property (copy, nonatomic) NSString *password;

@end

@implementation Geokeys

#pragma mark - Initializer

- (instancetype)init {
    NSAssert(false, @"You have to be authorized to use this service. Please use -initWithLogin, instead");
    return nil;
}

- (instancetype)initWithLogin:(NSString *)login password:(NSString *)password {
    
    self = [super init];
    if (self) {
        
        _login = login;
        _password = password;
    }
    
    return self;
}

#pragma mark - Public
- (void)GET:(GKMethods)method parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error, id response))handler {
    
    NSString *methodName = [self stringWithMethod:method];
    
    // the order of the params doesn't matter.
    NSMutableDictionary *updatedParams = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    updatedParams[@"servicename"] = @"RestGeokeys_v2";
    if (method == GKHeight && [parameters.allKeys containsObject:@"geop"]) {
        if ([parameters[@"geop"] rangeOfString:@";"].location != NSNotFound) {
            methodName = @"geopmulti";
        }
    }
    
    updatedParams[@"method"] = methodName;
    
    updatedParams[@"login"] = _login;
    updatedParams[@"password"] = _password;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://services.kortforsyningen.dk/?%@", [self stringWithParameters:updatedParams]]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        handler(error, nil);
                                                    } else {
                                                        handler(nil, [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                                    }
                                                }];
    [dataTask resume];
}

- (void)transformCoordinates:(NSArray *)coordinates fromEPSG:(EPSG)fromEPSG toEPSG:(EPSG)toEPSG completionHandler:(void (^)(NSError *error, id response))handler {
    
    NSDictionary *params = @{@"ingeop" : [NSString stringWithFormattedCoordinates:coordinates],
                             @"ingeoref" : NSStringFromEPSG(fromEPSG),
                             @"outgeoref" : NSStringFromEPSG(toEPSG)
                             };
    
    [self GET:GKCoordinateTransformation parameters:params completionHandler:^(NSError *error, id response) {
        handler(error, response);
    }];
}

#pragma mark - Helpers

- (NSString *)stringWithParameters:(NSDictionary *)parameters {
    NSMutableString *paramsStr = [NSMutableString string];
    for (int i = 0; i < parameters.allKeys.count; i++) {
        NSString *key = [[parameters allKeys] objectAtIndex:i];
        [paramsStr appendString:[NSString stringWithFormat:@"%@=%@",key, parameters[key]]];
        if (i < parameters.allKeys.count - 1) {
            [paramsStr appendString:@"&"];
        }
    }
    
    return paramsStr;
}

- (NSString *)stringWithMethod:(GKMethods)method {
    
    NSString *name;
    switch (method) {
        case GKAddress:
            name = @"adresse";
            break;
            
        case GKPostalAddress:
            name = @"padresse";
            break;
            
        case GKClosestAddress:
            name = @"nadresse";
            break;
            
        case GKRoad:
            name = @"vej";
            break;
            
        case GKPostalCode:
            name = @"postdistrikt";
            break;
            
        case GKMunicipality:
            name = @"kommune";
            break;
            
        case GKParish:
            name = @"sogn";
            break;
            
        case GKPoliceDistrict:
            name = @"politikreds";
            break;
            
        case GKConstituency:
            name = @"opstillingskreds";
            break;
            
        case GKJurisdiction:
            name = @"retskreds";
            break;
            
        case GKOwnerAssociations:
            name = @"ejerlav";
            break;
            
        case GKLandRegisterNumber:
            name = @"matrikelnr";
            break;
            
        case GKAssessingProperty:
            name = @"vurderingsejendom";
            break;
            
        case GKRealEstate:
            name = @"sfeejendom";
            break;
            
        case GKPlace:
            name = @"stedv2";
            break;
            
        case GKPlaceCategory:
            name = @"stedkat";
            break;
            
        case GKHeight:
            name = @"hoejde";
            break;
            
        case GKCoordinateTransformation:
            name = @"koortrans";
            break;
    }
    
    return name;
}

@end
