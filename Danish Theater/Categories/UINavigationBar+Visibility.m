//
//  UINavigationBar+Visibility.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/6/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "UINavigationBar+Visibility.h"

@implementation UINavigationBar (Visibility)

- (void)restore {
    
    [self setBackgroundImage:nil /*[UIImage imageNamed:@"white-background"]*/ forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:nil];
    
    self.barStyle = UIBarStyleDefault;
    self.tintColor = [UIColor colorWithRed:(5/255.0) green:(122/255.0) blue:(255/255.0) alpha:1.0];
}

- (void)hide {
    
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new]];
    
    self.barStyle = UIBarStyleBlack;
    self.tintColor = [UIColor whiteColor];
}

@end
