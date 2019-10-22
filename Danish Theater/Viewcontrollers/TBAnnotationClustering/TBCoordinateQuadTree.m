//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"

typedef struct TBVenueInfo {
    char* venueName;
    char* venuePhoneNumber;
    char* venueOrganizationCode;
} TBVenueInfo;

TBQuadTreeNodeData TBDataFromLine(NSString *line)
{
    NSArray *components = [line componentsSeparatedByString:@","];
    double latitude = [components[1] doubleValue];
    double longitude = [components[0] doubleValue];

    TBVenueInfo* venueInfo = malloc(sizeof(TBVenueInfo));

    // VENUE NAME [2]
    NSString *venueName = [components[2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    venueInfo->venueName = malloc(sizeof(char) * venueName.length + 1);
    strncpy(venueInfo->venueName, [venueName UTF8String], venueName.length + 1);
    
    // VENUE PHONE NUMBER [3]
    NSString *venueOrganizationCode = @"orgCode1234Test"; // [components[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    venueInfo->venueOrganizationCode = malloc(sizeof(char) * venueOrganizationCode.length + 1);
    strncpy(venueInfo->venueOrganizationCode, [venueOrganizationCode UTF8String], venueOrganizationCode.length + 1);
    
    // VENUE ORGANIZATION CODE [4]
    NSString *venuePhoneNumber = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    venueInfo->venuePhoneNumber = malloc(sizeof(char) * venuePhoneNumber.length + 1);
    strncpy(venueInfo->venuePhoneNumber, [venuePhoneNumber UTF8String], venuePhoneNumber.length + 1);

    return TBQuadTreeNodeDataMake(latitude, longitude, venueInfo);
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));

    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;

    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;

    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox)
{
    MKMapPoint topLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.x0, boundingBox.y0));
    MKMapPoint botRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(boundingBox.xf, boundingBox.yf));

    return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y));
}

NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale)
{
    double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
    NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
    NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));

    return zoomLevel;
}

float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    NSInteger zoomLevel = TBZoomScaleToZoomLevel(zoomScale);

    switch (zoomLevel) {
        case 13:
        case 14:
        case 15:
            return 64;
        case 16:
        case 17:
        case 18:
            return 32;
        case 19:
            return 16;

        default:
            return 88;
    }
}

@implementation TBCoordinateQuadTree

- (void)buildTree
{
    @autoreleasepool {
        NSString *data = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USA-HotelMotel" ofType:@"csv"] encoding:NSASCIIStringEncoding error:nil];
        NSArray *lines = [data componentsSeparatedByString:@"\n"];

        NSInteger count = lines.count - 1;

        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            dataArray[i] = TBDataFromLine(lines[i]);
        }

        TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
        _root = TBQuadTreeBuildWithData(dataArray, count, world, 4);
    }
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;

    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;

            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            NSMutableArray *organizationCodes = [[NSMutableArray alloc] init];

            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;

                TBVenueInfo venueInfo = *(TBVenueInfo *)data.data;
                [names addObject:[NSString stringWithFormat:@"%s", venueInfo.venueName]];
                [phoneNumbers addObject:[NSString stringWithFormat:@"%s", venueInfo.venuePhoneNumber]];
                [organizationCodes addObject:[NSString stringWithFormat:@"%s", venueInfo.venueOrganizationCode]];
            });

            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                annotation.title = [names lastObject];
                annotation.subtitle = [phoneNumbers lastObject];
                annotation.uniqueId = [organizationCodes lastObject];
                [clusteredAnnotations addObject:annotation];
            }

            if (count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                [clusteredAnnotations addObject:annotation];
            }
        }
    }

    return [NSArray arrayWithArray:clusteredAnnotations];
}

@end
