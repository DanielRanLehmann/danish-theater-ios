//
//  Geokeys.h
//  Geokeys
//
//  Created by Daniel Ran Lehmann on 3/30/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

struct EPSG {
    int code;
};
typedef struct EPSG EPSG;

CG_INLINE EPSG
EPSGMake(int code) {
    EPSG epsg;
    epsg.code = code;
    return epsg;
}

CG_INLINE NSString *
NSStringFromEPSG(EPSG epsg) {
    return [NSString stringWithFormat:@"EPSG:%i", epsg.code];
}

typedef enum : NSUInteger {
    GKAddress,
    GKPostalAddress,
    GKClosestAddress,
    GKRoad,
    GKPostalCode,
    GKMunicipality,
    GKParish,
    GKPoliceDistrict,
    GKConstituency,
    GKJurisdiction,
    GKOwnerAssociations,
    GKLandRegisterNumber,
    GKAssessingProperty,
    GKRealEstate,
    GKPlace,
    GKPlaceCategory,
    GKHeight,
    GKCoordinateTransformation
} GKMethods;

@interface Geokeys : NSObject

// - (NSArray <NSString *> *)allKeys;

- (instancetype)initWithLogin:(NSString *)login password:(NSString *)password;

- (void)GET:(GKMethods)method parameters:(NSDictionary *)parameters completionHandler:(void (^)(NSError *error, id response))handler;

- (void)transformCoordinates:(NSArray *)coordinates fromEPSG:(EPSG)fromEPSG toEPSG:(EPSG)toEPSG completionHandler:(void (^)(NSError *, id))handler;


@end
