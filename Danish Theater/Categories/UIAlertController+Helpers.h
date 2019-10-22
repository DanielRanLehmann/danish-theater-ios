//
//  UIAlertController+Helpers
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/7/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Event.h"
#import "Show.h"
#import "Organization.h"

#import "DTEventDetailViewController.h"
#import "DTOrganizationDetailViewController.h"

#import <EventKit/EventKit.h>
#import "UIBarButtonItem+DTBackButtonItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (Helpers)


- (UIAlertController *)moreOptionsWithEvent:(Event *)event;

- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithEvent:(Event *)event completionHandler:( void (^ _Nullable )(BOOL cancelled))completion;

//
- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithShow:(Show *)show;
- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithOrganization:(Organization *)organization;

+ (UIAlertController *)alertControllerWithTicketOfficeName:(NSString *)ticketOfficeName ticketPhone:(NSString *)ticketPhone;

@end

NS_ASSUME_NONNULL_END
