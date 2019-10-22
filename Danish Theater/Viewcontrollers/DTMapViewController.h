//
//  DTMapViewController.h
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/22/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DTMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end
