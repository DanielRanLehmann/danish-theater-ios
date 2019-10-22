//
//  DTDescriptionTableViewCell.m
//  Danish Theater
//
//  Created by Daniel Ran Lehmann on 6/27/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "DTDescriptionTableViewCell.h"
#import "DanishTheater.h"

#define DEFAULT_PREVIEW_DESCRIPTION_LENGTH 200

@interface DTDescriptionTableViewCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation DTDescriptionTableViewCell
@synthesize delegate;

#pragma mark - Initializers
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

#pragma mark - Configure & Reuse
- (void)configure {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // _descriptionTextExpanded = false; // could overwrite during refresh of cell?
    
    _headerLabel = [[UILabel alloc] initForAutoLayout];
    _headerLabel.numberOfLines = 1;
    _headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _headerLabel.textAlignment = NSTextAlignmentLeft;
    _headerLabel.textColor = [UIColor blackColor];
    
    [self.contentView addSubview:_headerLabel];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    _textView.tintColor = DTGlobalTintColor; 
    _textView.delegate = self;
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _textView.scrollEnabled = NO;
    _textView.editable = NO;
    
    // _textView.delegate = self;
    _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]; // one tick down.
    _textView.textColor = [UIColor darkGrayColor];
    _textView.textAlignment = NSTextAlignmentLeft;
    
    // IMPORTANT TWO REMOVE ANY UNWANTED PADDING AND INSETS.
    _textView.textContainer.lineFragmentPadding = 0;
    _textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _textView.linkTextAttributes = @{NSForegroundColorAttributeName : DTGlobalTintColor};
    
    [self.contentView addSubview:_textView];
    
    _previewDescriptionLength = DEFAULT_PREVIEW_DESCRIPTION_LENGTH; // size of a tweet for now.
}

- (void)prepareForReuse {
    //[super prepareForReuse];
    
    _headerLabel.text = nil;
    _textView.text = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)populateWithData {
    
    _headerLabel.text = _headerText;
    
    NSMutableAttributedString *mutAttrString = [[NSMutableAttributedString alloc] initWithString:_descriptionText attributes:@{NSForegroundColorAttributeName : [UIColor darkTextColor], NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]}];
    
    if (![self isDescriptionTextExpanded] && _descriptionText.length > _previewDescriptionLength) {
        
        NSString *more = NSLocalizedString(@"MORE_LINK_TEXT", nil);
        
        mutAttrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", [_descriptionText substringWithRange:NSMakeRange(0, _previewDescriptionLength)], more] attributes:@{NSForegroundColorAttributeName : [UIColor darkTextColor], NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]}];
        
        NSRange moreRange = [[mutAttrString string] rangeOfString:more options:NSBackwardsSearch]; //range:NSMakeRange(_previewDescriptionLength - more.length, more.length)];
        if (moreRange.location != NSNotFound) {
            [mutAttrString addAttributes:@{NSLinkAttributeName : [NSURL URLWithString:@"theater://readmore"]} range:moreRange];
        }
    }
    
    [_textView setAttributedText:mutAttrString];
    [_textView layoutIfNeeded];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    if ([[URL absoluteString] isEqualToString:@"theater://readmore"]) {
        [delegate didSelectMoreWithDescriptionTableViewCell:self];
       
        return NO;
    }
    
    
    return YES;
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        // Do your initial constraint setup
        
        [self populateWithData];
        
        [_headerLabel autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
        
        [_textView autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeTop];
        [_textView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_headerLabel withOffset:4];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
