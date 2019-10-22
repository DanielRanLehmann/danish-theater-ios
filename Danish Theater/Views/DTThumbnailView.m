//
//  DTThumbnailView.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 8/3/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTThumbnailView.h"

@interface DTThumbnailView ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *blacklayerView;

@end

@implementation DTThumbnailView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    _shimmeringView = [[FBShimmeringView alloc] init];
    _shimmeringView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_shimmeringView];
    
    _imageView = [[UIImageView alloc] initForAutoLayout];
    _imageView.clipsToBounds = TRUE;
    _imageView.layer.masksToBounds = TRUE;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor colorWithHex:@"#212121"]; // [UIColor colorWithRed:(224/255.0) green:(224/255.0) blue:(224/255.0) alpha:1.0];
    
    _imageView.layer.cornerRadius = 6.0f;
    
    [_shimmeringView setContentView:_imageView];
    
    _blacklayerView = [[UIView alloc] initForAutoLayout];
    _blacklayerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.25];
    _blacklayerView.frame = _imageView.bounds;
    
    [_imageView insertSubview:_blacklayerView atIndex:0];
    
    _textLabel = [[UILabel alloc] initForAutoLayout];
    _textLabel.numberOfLines = 2;
    _textLabel.font = [UIFont systemFontOfSize:30];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    
    [_imageView insertSubview:_textLabel aboveSubview:_blacklayerView];
}

- (NSAttributedString *)attributedText {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd"];
    
    NSString *showDateStr = [df stringFromDate:_date];
    NSMutableArray *dateComponents = [NSMutableArray arrayWithArray:[showDateStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    NSString *monthComp = [[dateComponents firstObject] uppercaseString];
    [dateComponents replaceObjectAtIndex:0 withObject:monthComp];
    
    showDateStr = [dateComponents componentsJoinedByString:@"\n"];
    
    NSMutableAttributedString *bigDateMutAttrStr = [[NSMutableAttributedString alloc] initWithString:showDateStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightBold]}];
    NSRange newlineRange2 = [[bigDateMutAttrStr string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    if (newlineRange2.location != NSNotFound) {
        [bigDateMutAttrStr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:28 weight:UIFontWeightRegular]} range:NSMakeRange(newlineRange2.location + 1, bigDateMutAttrStr.string.length - (newlineRange2.location + 1))];
    }
    
    return bigDateMutAttrStr;
}

- (void)populateWithData {
    
    _textLabel.attributedText = [self attributedText];
    if (!_imageView.image) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            //Background Thread
            UIImage *thumbnail = [[UIImage imageWithData:[NSData dataWithContentsOfURL:_imageURL]] blurredImageWithRadius:15 iterations:20 tintColor:[UIColor clearColor]];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                _imageView.image = thumbnail;
            });
        });
    }
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [_shimmeringView autoPinEdgesToSuperviewEdges];
        [_imageView autoPinEdgesToSuperviewEdges];
        [_blacklayerView autoPinEdgesToSuperviewEdges];
        [_textLabel autoPinEdgesToSuperviewEdges];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
