//
//  DTMunicipalityPickerController.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/2/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import <Geokeys/Geokeys.h>
#import <MapKit/MapKit.h>
#import "DanishTheater.h" 

typedef void (^DTMunicipalityPickerCompletion)(BOOL cancelled, NSString *selectedMunicipality);

@class DTMunicipalityPickerController;
@protocol DTMunicipalityPickerControllerDelegate <NSObject>

@required
- (void)municipalityPickerController:(DTMunicipalityPickerController *)picker didFinishPickingWithMuncipality:(NSString *)municipality;

@optional
- (void)municipalityPickerControllerDidCancel:(DTMunicipalityPickerController *)picker;

@end

@interface DTMunicipalityPickerController : UIViewController <UITableViewDelegate, UITableViewDataSource> 

- (instancetype)initWithMunicipalities:(NSArray <NSString *> *)municipalities;
@property (nonatomic, strong) DTMunicipalityPickerCompletion completion;

@property (nonatomic, readonly) NSArray *municipalities;
@property (nonatomic, copy) NSString *selectedMunicipality;

@property (nonatomic, copy) NSString *usersLocalMunicipaltiy;

@property (nonatomic, weak) id <DTMunicipalityPickerControllerDelegate> delegate;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UITableView *tableView;

// Factory helper methods

+ (void)getNearestMunicipalityWithLocation:(CLLocation *)location withSuccess:(void (^)(NSString *municipality))success failure:(void (^)(NSError *error))failure;

@end
