//
//  DTMapViewController.m
//  DTCarouselTestingPt1
//
//  Created by Daniel Ran Lehmann on 1/22/18.
//  Copyright © 2018 Daniel Ran Lehmann. All rights reserved.
//

#import "DTMapViewController.h"
#import "PureLayout.h"
#import "PINCache.h" // used for 'DTVenuesLastPersistedAt' -> epoch timestamp 1970.

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"

#import "DTOrganizationDetailViewController.h"

#define A_DAY_IN_SECONDS 86400

@interface DTMapViewController ()

@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;

@end

@implementation DTMapViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // configure
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Map";
    
    _mapView = [[MKMapView alloc] initForAutoLayout];
    _mapView.delegate = self;
    
    [self.view addSubview:_mapView];
    [_mapView autoPinEdgesToSuperviewEdges];
    
    self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
    self.coordinateQuadTree.mapView = self.mapView;
    
    [[PINCache sharedCache] objectForKey:@"DTVenuesLastPersistedAt" block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
       
        NSTimeInterval venuesLastPersistedAt = 0;
        if (object) {
            venuesLastPersistedAt = [object doubleValue];
        }
        
        NSTimeInterval delta = [[NSDate date] timeIntervalSince1970] - venuesLastPersistedAt;
        if (delta > A_DAY_IN_SECONDS) {
            
            //NSURL *venuesFileURL = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"venues.csv" ofType:@"csv"]];
            /*
            FIRStorageReference *ref = [storageRef child:@"venues.csv"];
            FIRStorageDownloadTask *downloadTask = [ref writeToFile:localURL completion:^(NSURL *URL, NSError *error){
                if (!error) {
                    [[PINCache sharedCache] setObject:[[NSDate date] timeIntervalSince1970] forKey:@"DTVenuesLastPersistedAt"];
                }
            }];
            */
        }
    }]; // does this block the main thread?, yes?
    
    [self.coordinateQuadTree buildTree];
}

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    NSSet *after = [NSSet setWithArray:annotations];
    
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    TBClusterAnnotationView *annView = (TBClusterAnnotationView *)view;
    TBClusterAnnotation *ann = (TBClusterAnnotation *)annView.annotation;
    NSLog(@"did tap callout.. should push to .. : %@", ann.uniqueId);
    
    DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:@"OR0000002-0910"]; // fixed for now, until I have connected my .csv file.
    [self.navigationController pushViewController:organizationDetailVC animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *const TBAnnotatioViewReuseID = @"TBAnnotatioViewReuseID";
    
    TBClusterAnnotationView *annotationView = (TBClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TBAnnotatioViewReuseID];
    
    if (!annotationView) {
        annotationView = [[TBClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TBAnnotatioViewReuseID];
    }
    
    annotationView.canShowCallout = YES;
    annotationView.count = [(TBClusterAnnotation *)annotation count];
    
    if ([(TBClusterAnnotation *)annotation count] == 1) {
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
}

/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id annotation = view.annotation;
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        TBClusterAnnotationView *annotationView = (TBClusterAnnotationView *)view;
        TBClusterAnnotation *annotation = (TBClusterAnnotation *)view;
        
        //DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:@"OR0000002-0910"]; // fixed for now, until I have connected my .csv file.
        //[self.navigationController pushViewController:organizationDetailVC animated:YES];
        
        if (annotationView.count == 0) {
            NSLog(@"did select annotationview. %@", view);
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
