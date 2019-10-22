//
//  UIAlertController+EventHandler.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/7/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UIAlertController+Helpers.h"
@import Firebase;

@implementation UIAlertController (Helpers)

- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithEvent:(Event *)event completionHandler:( void (^ _Nullable )(BOOL cancelled))completion {
    
    __block UIAlertAction *openEventAction = nil;
    __block UIAlertAction *openOrganizationAction = nil;
    __block UIAlertAction *shareAction = nil;
    __block UIAlertAction *favoriteAction = nil;
    __block UIAlertAction *cancelAction = nil;
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    FIRUser *user = [FIRAuth auth].currentUser;
    
    [[[ref child:@"organizations"] child:event.organizationCode] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            openOrganizationAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ %@",  NSLocalizedString(@"ALERT_ACTION_TITLE_OPEN", nil), event.organizationName] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:event.organizationCode];
                [[vc navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[vc.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : vc.title style:UIBarButtonItemStylePlain target:nil action:nil]];
                [vc.navigationController pushViewController:organizationDetailVC animated:YES];
                
                if (completion) {
                    completion(NO);
                }
            }];
            
        }
        
        openEventAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_OPEN", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:event.code];
            [[vc navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[vc.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : vc.title style:UIBarButtonItemStylePlain target:nil action:nil]];
            [vc.navigationController pushViewController:eventDetailVC animated:YES];
            
            if (completion) {
                completion(NO);
            }
        }];
        
        shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_SHARE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //NSLog(@"ticketOperatorURL => %@", [[(Event *)object ticketInfo] ticketOperatorURL]); // is nil always because that child is stripped from the event snippets.
            NSURL *URL = [NSURL URLWithString:@"https://www.google.com"]; // [[(Event *)object ticketInfo] ticketOperatorURL];
            
            UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:@[URL]
                                              applicationActivities:nil];
            [vc presentViewController:activityViewController
                             animated:YES
                           completion:nil];
            
            if (completion) {
                completion(NO);
            }
        }];
        
        if (user) {
            [[[[ref child:@"user-favorites"] child:user.uid] child:event.code] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                BOOL isFavorited = false;
                if (snapshot.exists) {
                    isFavorited = true;
                }
                
                favoriteAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", isFavorited ? NSLocalizedString(@"ALERT_ACTION_TITLE_UNFAVORITE", nil) : NSLocalizedString(@"ALERT_ACTION_TITLE_FAVORITE", nil)] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[[[ref child:@"user-favorites"] child:user.uid] child:event.code] setValue:!isFavorited ? @(true) : nil];
                    
                    if (completion) {
                        completion(NO);
                    }

                }];
                
                [self addAction:openEventAction];
                
                if (openOrganizationAction) {
                    [self addAction:openOrganizationAction];
                }
                
                [self addAction:shareAction];
                [self addAction:favoriteAction];
                
                cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    if (completion) {
                        completion(YES);
                    }
                    
                }];
                [self addAction:cancelAction];
                
                [vc presentViewController:self animated:YES completion:nil];
                
            }];
        }
    }];
}

- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithShow:(Show *)show {

    __block UIAlertAction *viewEventAction = nil;
    __block UIAlertAction *viewOrganizationAction = nil;
    __block UIAlertAction *addToCalendarAction = nil;
    __block UIAlertAction *cancelAction = nil;
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    [[[ref child:@"organizations"] child:show.organizationCode] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (snapshot.exists) {
            viewOrganizationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_VIEW_THEATER", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:show.organizationCode];
                [[vc navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[vc.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : vc.title style:UIBarButtonItemStylePlain target:nil action:nil]];
                [vc.navigationController pushViewController:organizationDetailVC animated:YES];
            }];
        }
        
        viewEventAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_VIEW_EVENT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DTEventDetailViewController *eventDetailVC = [[DTEventDetailViewController alloc] initWithCode:show.eventCode];
            [[vc navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[vc.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : vc.title style:UIBarButtonItemStylePlain target:nil action:nil]];
            [vc.navigationController pushViewController:eventDetailVC animated:YES];
        }];
        
        addToCalendarAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_ADD_TO_CALENDAR", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            EKEventStore *store = [EKEventStore new];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (!granted) { return; } // make feedBackAlert communicate to users, that they need to allow access.
                
                // This is very much duplication that should be avoided and removed.
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *showDate = [df dateFromString:[NSString stringWithFormat:@"%@ %@", show.date, show.time]];
                
                [[[ref child:@"events"] child:show.eventCode] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    Event *currEvent =  [MTLJSONAdapter modelOfClass:Event.class fromJSONDictionary:snapshot.value error:nil];
                    [[[ref child:@"venues"] child:show.venueCode] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                        NSDictionary *venue = snapshot.value;
                        
                        CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:[venue[@"latitude"] doubleValue] longitude:[venue[@"longitude"] doubleValue]];
                        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                        [geocoder reverseGeocodeLocation:venueLocation completionHandler:
                         ^(NSArray* placemarks, NSError* error){
                             if ([placemarks count] > 0) {
                                 CLPlacemark *venuePlacemark = [placemarks firstObject];
                                 
                                 EKEvent *event = [EKEvent eventWithEventStore:store];
                                 event.title = [NSString stringWithFormat:@"'%@' on %@", currEvent.localizedTitle, venue[@"name"]];
                                 event.location = [venuePlacemark.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
                                 event.URL = currEvent.ticketInfo.ticketOfficeURL;
                                 event.notes = [NSString stringWithFormat:@"Buy your tickets at: %@\nOr, call the ticket office, %@, on this number: %@ (additional charges may apply.)", currEvent.ticketInfo.ticketOperatorURL, currEvent.ticketOffice.name, [NSString stringWithFormattedPhoneNumber:currEvent.ticketOffice.ticketPhone]];
                                 event.startDate = showDate;
                                 event.endDate = [event.startDate dateByAddingTimeInterval:(currEvent.durationInMinutes * 60)]; // NSTimeInterval is in seconds.
                                 event.calendar = [store defaultCalendarForNewEvents];
                                 NSError *err = nil;
                                 [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                                 
                                 UIAlertController *feedbackAlert;
                                 if (!error) {
                                     
                                     feedbackAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SHOW_ADDED_TITLE", nil) message:NSLocalizedString(@"SHOW_ADDED_MESSAGE_TEXT", nil) preferredStyle:UIAlertControllerStyleAlert];
                                 } else {
                                     feedbackAlert = [UIAlertController alertControllerWithTitle:@"Oops!" message:err.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                                 }
                                 
                                 UIAlertAction *showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SHOW_ACTION_SHOW_TITLE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     NSInteger interval = [showDate timeIntervalSinceReferenceDate];
                                     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"calshow:%ld", interval]];
                                     if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                             NSLog(@"success? %@", success ? @"yes" : @"No");
                                         }];
                                     }
                                 }];
                                 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL_ITEM_TITLE", nil) style:UIAlertActionStyleCancel handler:nil];
                                 
                                 [feedbackAlert addAction:cancelAction];
                                 [feedbackAlert addAction:showAction];
                                 [vc presentViewController:feedbackAlert animated:YES completion:nil];
                                 
                             }
                         }];
                    }];
                }];
            }];
        }];
        
        cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [self addAction:viewEventAction];
        if (viewOrganizationAction) {
            [self addAction:viewOrganizationAction];
        }
        [self addAction:addToCalendarAction];
        [self addAction:cancelAction];
        
        [vc presentViewController:self animated:YES completion:nil];
    }];
}

- (void)presentFromViewController:(UIViewController *)vc moreOptionsWithOrganization:(Organization *)organization {

    UIAlertAction *openAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_OPEN", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DTOrganizationDetailViewController *organizationDetailVC = [[DTOrganizationDetailViewController alloc] initWithCode:organization.code];
        [[vc navigationItem] setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[vc.title isEqualToString:@""] ? NSLocalizedString(@"BACK_ITEM_TITLE", nil) : vc.title style:UIBarButtonItemStylePlain target:nil action:nil]];
        [vc.navigationController pushViewController:organizationDetailVC animated:YES];
    }];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_SHARE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // [DanishTheater presentActivityViewControllerWithObject:object fromViewController:vc animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [self addAction:openAction];
    [self addAction:shareAction];
    [self addAction:cancelAction];
    
    [vc presentViewController:self animated:YES completion:nil];
}

+ (UIAlertController *)alertControllerWithTicketOfficeName:(NSString *)ticketOfficeName ticketPhone:(NSString *)ticketPhone {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ticketOfficeName message:NSLocalizedString(@"TICKET_OFFICE_ALERT_CONTROLLER_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *call = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_CALL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *ticketOfficeURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", ticketPhone]];
        if ([[UIApplication sharedApplication] canOpenURL:ticketOfficeURL]) {
            [[UIApplication sharedApplication] openURL:ticketOfficeURL options:@{} completionHandler:^(BOOL success) {
            }];
        }
    }];
    
    //UIAlertAction *learnMore = [UIAlertAction actionWithTitle:@"Learn More" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    // redirect to website that can inform users about those fees.
    //}];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_ACTION_TITLE_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:call];
    //[alert addAction:learnMore];
    [alertController addAction:cancel];
    
    
    return alertController;
}



@end
