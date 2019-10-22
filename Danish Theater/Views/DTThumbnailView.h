//
//  DTThumbnailView.h
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PureLayout.h"
#import "FXBlurView.h" 
#import "FBShimmeringView.h"
#import "UIColor+ColorFromHexadecimal.h" 

@interface DTThumbnailView : UIView

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) FBShimmeringView *shimmeringView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

- (NSAttributedString *)attributedText;
- (void)populateWithData;

@end
