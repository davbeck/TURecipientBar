//
//  TURecipientsBar.m
//  ThinkSocial
//
//  Created by David Beck on 10/23/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipientsBar.h"

#import <QuartzCore/QuartzCore.h>


#define TURecipientsLineHeight 43.0
#define TURecipientsPlaceholder @"\u200B"

void *TURecipientsSelectionContext = &TURecipientsSelectionContext;


@implementation TURecipientsBar
{
    UIVisualEffectView *_backgroundView;
	NSArray *_updatingConstraints; // NSLayoutConstraint
    NSArray *_addButtonHiddenConstraints; // NSLayoutConstraint
	
	NSMutableArray *_recipients; // <TURecipient>
	NSMutableArray *_recipientViews; // UIButton
	CGSize _lastKnownSize;
	id<TURecipient>_selectedRecipient;
    BOOL _needsRecipientLayout;
    
    // UIAppearance
    NSMutableDictionary *_recipientBackgroundImages; // [@(UIControlState)] UIImage
    NSMutableDictionary *_recipientTitleTextAttributes; // [@(UIControlState)] NSDictionary(text attributes dictionary)
    
}

#pragma mark - Properties

@synthesize labelTextAttributes = _labelTextAttributes;


- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    [self _updateSummary];
}

- (NSArray *)recipients
{
	return [_recipients copy];
}

- (void)addRecipient:(id<TURecipient>)recipient
{
	NSIndexSet *changedIndex = [NSIndexSet indexSetWithIndex:_recipients.count];
	
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:changedIndex forKey:@"recipients"];
	[_recipients addObject:[(id)recipient copy]];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:changedIndex forKey:@"recipients"];
	
	
	UIButton *recipientView = [UIButton buttonWithType:UIButtonTypeCustom];
    
	recipientView.adjustsImageWhenHighlighted = NO;
	recipientView.contentEdgeInsets = _recipientContentEdgeInsets;
    
    
	[recipientView setBackgroundImage:[self recipientBackgroundImageForState:UIControlStateNormal]
                             forState:UIControlStateNormal];
    [recipientView setAttributedTitle:[[NSAttributedString alloc] initWithString:recipient.recipientTitle attributes:[self recipientTitleTextAttributesForState:UIControlStateNormal]]
                             forState:UIControlStateNormal];
    
	[recipientView setBackgroundImage:[self recipientBackgroundImageForState:UIControlStateHighlighted]
							 forState:UIControlStateHighlighted];
    [recipientView setAttributedTitle:[[NSAttributedString alloc] initWithString:recipient.recipientTitle attributes:[self recipientTitleTextAttributesForState:UIControlStateHighlighted]]
                             forState:UIControlStateHighlighted];
    
	[recipientView setBackgroundImage:[self recipientBackgroundImageForState:UIControlStateSelected]
							 forState:UIControlStateSelected];
    [recipientView setAttributedTitle:[[NSAttributedString alloc] initWithString:recipient.recipientTitle attributes:[self recipientTitleTextAttributesForState:UIControlStateSelected]]
                             forState:UIControlStateSelected];
    
    
	[recipientView addTarget:self action:@selector(selectRecipientButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
	[self addSubview:recipientView];
    
    [self _setNeedsRecipientLayout];
    if (self.animatedRecipientsInAndOut) {
        recipientView.frame = [self _frameFoRecipientView:recipientView afterView:_recipientViews.lastObject];
        recipientView.alpha = 0.0;
        recipientView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        // add this after getting the frame, otherwise it will base the frame on itself
        [_recipientViews addObject:recipientView];
        
        void(^animations)() = ^{
            recipientView.transform = CGAffineTransformIdentity;
            recipientView.alpha = 1.0;
            
            [self layoutIfNeeded];
        };
        
        if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:0 animations:animations completion:nil];
        } else {
            [UIView animateWithDuration:0.5 animations:animations];
        }
    } else {
        [_recipientViews addObject:recipientView];
        [self layoutIfNeeded];
    }
    
    
    if (_textField.editing) {
        [self _scrollToBottomAnimated:YES];
    } else {
        recipientView.alpha = 0.0;
    }
	
	[self _updateSummary];
}

- (void)removeRecipient:(id<TURecipient>)recipient
{
	NSIndexSet *changedIndex = [NSIndexSet indexSetWithIndex:[_recipients indexOfObject:recipient]];
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:changedIndex forKey:@"recipients"];
	[_recipients removeObjectsAtIndexes:changedIndex];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:changedIndex forKey:@"recipients"];
	
    UIView *recipientView = [_recipientViews objectAtIndex:changedIndex.firstIndex];
    [_recipientViews removeObject:recipientView];
    [self _setNeedsRecipientLayout];
    
    if (self.animatedRecipientsInAndOut) {
        void(^animations)() = ^{
            recipientView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            recipientView.alpha = 0.0;
            
            [self layoutIfNeeded];
        };
        
        void (^completion)(BOOL finished) = ^(BOOL finished){
            [recipientView removeFromSuperview];
        };
        
        if ([UIView respondsToSelector:@selector(animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:)]) {
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:0 animations:animations completion:completion];
        } else {
            [UIView animateWithDuration:0.5 animations:animations completion:completion];
        }
    } else {
        [recipientView removeFromSuperview];
    }
	
	
	[self _updateSummary];
}

- (void)_updateSummary
{
    if (_recipients.count > 0) {
        NSMutableString *summary = [[NSMutableString alloc] init];
        
        for (id<TURecipient>recipient in _recipients) {
            [summary appendString:recipient.recipientTitle];
            
            if (recipient != [_recipients lastObject]) {
                [summary appendString:@", "];
            }
        }
        
        _summaryLabel.textColor = [UIColor darkTextColor];
        if (self.summaryTextAttributes == nil) {
            _summaryLabel.text = summary;
        } else {
            _summaryLabel.attributedText = [[NSAttributedString alloc] initWithString:summary attributes:self.summaryTextAttributes];
        }
    } else {
        _summaryLabel.textColor = [UIColor lightGrayColor];
        if (self.placeholderTextAttributes == nil || self.placeholder == nil) {
            _summaryLabel.text = self.placeholder;
        } else {
            _summaryLabel.attributedText = [[NSAttributedString alloc] initWithString:self.placeholder attributes:self.placeholderTextAttributes];
        }
    }
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
	[_textField setAutocapitalizationType:autocapitalizationType];
}

- (UITextAutocapitalizationType)autocapitalizationType
{
	return [_textField autocapitalizationType];
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
	[_textField setAutocorrectionType:autocorrectionType];
}

- (UITextAutocorrectionType)autocorrectionType
{
	return [_textField autocorrectionType];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
	[_textField setKeyboardType:keyboardType];
}

- (UIKeyboardType)keyboardType
{
	return [_textField keyboardType];
}

- (void)setSpellCheckingType:(UITextSpellCheckingType)spellCheckingType
{
	[_textField setSpellCheckingType:spellCheckingType];
}

- (UITextSpellCheckingType)spellCheckingType
{
	return [_textField spellCheckingType];
}

- (void)setShowsAddButton:(BOOL)showsAddButton
{
    _showsAddButton = showsAddButton;
    
    if (_showsAddButton) {
        [self addSubview:_addButton];
    } else {
        [_addButton removeFromSuperview];
    }
    
    [self setNeedsLayout];
}

- (void)setShowsShadows:(BOOL)showsShadows
{
	_showsShadows = showsShadows;
    
	[self updateShadows];
}

- (void)setText:(NSString *)text
{
	if (text != nil) {
		[_textField setText:[TURecipientsPlaceholder stringByAppendingString:text]];
	} else {
		[_textField setText:TURecipientsPlaceholder];
	}
	
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBar:textDidChange:)]) {
		[self.recipientsBarDelegate recipientsBar:self textDidChange:self.text];
	}
}

- (NSString *)text
{
	return [[_textField text] stringByReplacingOccurrencesOfString:TURecipientsPlaceholder withString:@""];
}

- (void)setLabel:(NSString *)label
{
    _toLabel.attributedText = [[NSAttributedString alloc] initWithString:label ?: @"" attributes:self.labelTextAttributes];
}

- (NSString *)label
{
	return [_toLabel text];
}

- (void)setHeightConstraint:(NSLayoutConstraint *)heightConstraint
{
	if (_heightConstraint != heightConstraint) {
		[self removeConstraint:_heightConstraint];
		
		_heightConstraint = heightConstraint;
	}
}

- (void)setSearching:(BOOL)searching
{
	if (_searching != searching) {
		_searching = searching;
		
		[self setNeedsLayout];
		[self.superview layoutIfNeeded];
		
		[self _scrollToBottomAnimated:YES];
		
		[self updateShadows];
	}
}

- (void)setSearching:(BOOL)searching animated:(BOOL)animated
{
	if (animated) {
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
			[self setSearching:searching];
		} completion:nil];
	} else {
		[self setSearching:searching];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectedTextRange"] && object == _textField) {
		//we use a special character at the start of the field that we don't want the user to select or move the insertion point in front of
		//see shouldChangeCharactersInRange for details
		NSInteger offset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.start];
		
		if (offset < 1) {
			UITextPosition *newStart = [_textField positionFromPosition:_textField.beginningOfDocument offset:1];
			_textField.selectedTextRange = [_textField textRangeFromPosition:newStart toPosition:_textField.selectedTextRange.end];
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Visual Updates

- (void)updateShadows
{
    if (_showsShadows) {
        if (_searching) {
            self.layer.shadowColor = [UIColor blackColor].CGColor;
            self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            self.layer.shadowOpacity = 0.3;
            self.layer.shadowRadius = 2.0;
            self.clipsToBounds = NO;
        } else {
            self.layer.shadowOpacity = 0.0;
            self.layer.shadowRadius = 0.0;
            self.clipsToBounds = YES;
        }
    }
}

#pragma mark - Initialization

- (void)dealloc
{
	[_textField removeObserver:self forKeyPath:@"selectedTextRange" context:TURecipientsSelectionContext];
}

- (void)_init
{
    _showsAddButton = YES;
	_showsShadows = YES;
    _animatedRecipientsInAndOut = YES;
    _recipientBackgroundImages = [NSMutableDictionary new];
    _recipientTitleTextAttributes = [NSMutableDictionary new];
    
    _recipientContentEdgeInsets = UIEdgeInsetsMake(0.0, 9.0, 0.0, 9.0);
    
    self.contentSize = self.bounds.size;
    
	_recipients = [NSMutableArray array];
	_recipientViews = [NSMutableArray array];
	
	
	self.backgroundColor = [UIColor whiteColor];
	if (self.heightConstraint == nil) {
		_heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:TURecipientsLineHeight];
        _heightConstraint.priority = UILayoutPriorityDefaultHigh;
		[self addConstraint:_heightConstraint];
	}
	self.clipsToBounds = YES;
	
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
	[self addSubview:_lineView];
	
	_toLabel = [[UILabel alloc] init];
    self.toLabel.text = NSLocalizedString(@"To: ", nil);
	[self addSubview:_toLabel];
	
	_addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _addButton.alpha = 0.0;
	[_addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_addButton];
	
	_textField = [[UITextField alloc] init];
	_textField.text = TURecipientsPlaceholder;
    _textField.font = [UIFont systemFontOfSize:15.0];
    _textField.textColor = [UIColor blackColor];
	_textField.delegate = self;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textField.spellCheckingType = UITextSpellCheckingTypeNo;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	[self addSubview:_textField];
	[_textField addObserver:self forKeyPath:@"selectedTextRange" options:0 context:TURecipientsSelectionContext];
	
	
	_summaryLabel = [[UILabel alloc] init];
    _summaryLabel.backgroundColor = [UIColor clearColor];
	_summaryLabel.font = [UIFont systemFontOfSize:15.0];
	[self addSubview:_summaryLabel];
	
	
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(select:)]];
    
    
    
    [self _setNeedsRecipientLayout];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (CGRectEqualToRect(self.frame, CGRectZero)) {
            // often because of autolayout we will be initialized with a zero rect
            // we need to have a default size that we can layout against
            self.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
        }
        
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero)) {
        // often because of autolayout we will be initialized with a zero rect
        // we need to have a default size that we can layout against
        frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
    }
    
    self = [super initWithFrame:frame];
    if (self != nil) {
		[self _init];
    }
	
    return self;
}


#pragma mark - Layout

- (void)_setNeedsRecipientLayout
{
    _needsRecipientLayout = YES;
    [self setNeedsLayout];
}

- (CGRect)_frameFoRecipientView:(UIView *)recipientView afterView:(UIView *)lastView
{
    CGRect recipientViewFrame;
    if (recipientView == _textField) {
        recipientViewFrame.size = CGSizeMake(100.0, 43.0);
    } else {
        recipientViewFrame.size = recipientView.intrinsicContentSize;
    }
    
    if (lastView == _toLabel) {
        recipientViewFrame.origin.x = CGRectGetMaxX(lastView.frame);
    } else {
        recipientViewFrame.origin.x = CGRectGetMaxX(lastView.frame) + 6.0;
    }
    
    recipientViewFrame.origin.y = CGRectGetMidY(lastView.frame) - recipientViewFrame.size.height / 2.0;
    
    if (CGRectGetMaxX(recipientViewFrame) > self.bounds.size.width - 6.0) {
        recipientViewFrame.origin.x = 15.0;
        recipientViewFrame.origin.y += TURecipientsLineHeight - 8.0;
    }
    
    return recipientViewFrame;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    if (_needsRecipientLayout) {
        CGSize toSize = _toLabel.intrinsicContentSize;
        _toLabel.frame = CGRectMake(15.0,
                                    21.0 - toSize.height / 2,
                                    toSize.width, toSize.height);
        
        
        CGRect summaryLabelFrame;
        summaryLabelFrame.origin.x = CGRectGetMaxX(_toLabel.frame);
        summaryLabelFrame.size.height = ceil(_summaryLabel.font.lineHeight);
        summaryLabelFrame.origin.y = 21.0 - summaryLabelFrame.size.height / 2;
        summaryLabelFrame.size.width = self.bounds.size.width - summaryLabelFrame.origin.x - 12.0;
        _summaryLabel.frame = summaryLabelFrame;
        
        CGRect addButtonFrame;
        addButtonFrame.size = _addButton.intrinsicContentSize;
        addButtonFrame.origin.x = self.bounds.size.width - addButtonFrame.size.width - 6.0;
        
        UIView *lastView = _toLabel;
        
        for (UIView *recipientView in [_recipientViews arrayByAddingObject:_textField]) {
            CGRect recipientViewFrame = [self _frameFoRecipientView:recipientView afterView:lastView];
            
            if (recipientView == _textField) {
                if (_addButton.superview == self) {
                    recipientViewFrame.size.width = addButtonFrame.origin.x - recipientViewFrame.origin.x;
                } else {
                    recipientViewFrame.size.width = self.bounds.size.width - recipientViewFrame.origin.x;
                }
            }
            
            recipientView.frame = recipientViewFrame;
            
            
            lastView = recipientView;
        }
        
        
        self.contentSize = CGSizeMake(self.frame.size.width, MAX(CGRectGetMaxY(lastView.frame), TURecipientsLineHeight));
        
        
        _needsRecipientLayout = NO;
        
        addButtonFrame.origin.y = self.contentSize.height - addButtonFrame.size.height / 2.0 - TURecipientsLineHeight / 2.0;
        _addButton.frame = addButtonFrame;
    }
    
    [_lineView.superview bringSubviewToFront:_lineView];
    CGFloat lineHeight = 1.0 / self.traitCollection.displayScale;
    if (self.traitCollection.displayScale < 1.0) { // this is the case when the view is off screen
        lineHeight = 1.0;
    }
    if (self.searching) {
        _lineView.frame = CGRectMake(0.0, self.contentSize.height - lineHeight, self.bounds.size.width, lineHeight);
    } else {
        _lineView.frame = CGRectMake(0.0, self.contentOffset.y + self.bounds.size.height - lineHeight, self.bounds.size.width, lineHeight);
    }
    
    if (_textField.isFirstResponder && (!self.searching || self.showsMultipleLinesWhileSearching)) {
		self.heightConstraint.constant = self.contentSize.height;
	} else {
		self.heightConstraint.constant = TURecipientsLineHeight;
	}
    
    if (_searching) {
		[self _scrollToBottomAnimated:NO];
	}
    
    
	if (_textField.isFirstResponder && self.contentSize.height > self.frame.size.height && !_searching) {
		self.scrollEnabled = YES;
	} else {
		self.scrollEnabled = NO;
	}
}

- (void)_frameChanged
{
	if (_recipients != nil && self.bounds.size.width != _lastKnownSize.width) {
		[self _setNeedsRecipientLayout];
	}
    
    if (_textField.isFirstResponder && self.contentSize.height > self.frame.size.height && !_searching) {
		self.scrollEnabled = YES;
	} else {
		self.scrollEnabled = NO;
	}
	
	if (_textField.isFirstResponder
        && _selectedRecipient == nil
		&& (self.bounds.size.width != _lastKnownSize.width || self.bounds.size.height != _lastKnownSize.height)) {
		[self _scrollToBottomAnimated:NO];
	}
	
	_lastKnownSize = self.bounds.size;
}

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	
	[self _frameChanged];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self _frameChanged];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    UIControlState state = UIControlStateNormal;
    NSDictionary *attributes = [self recipientTitleTextAttributesForState:state];
    for (UIButton *button in _recipientViews) {
        NSString *text = [button titleForState:state] ?: [button attributedTitleForState:state].string ?: @"";
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [button setAttributedTitle:attributedText forState:state];
    }
}


#pragma mark - Actions

- (IBAction)addContact:(id)sender
{
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarAddButtonClicked:)]) {
		[self.recipientsBarDelegate recipientsBarAddButtonClicked:self];
	}
}

- (IBAction)select:(id)sender
{
	[self becomeFirstResponder];
	
    self.selectedRecipient = nil;
}

- (IBAction)selectRecipientButton:(UIButton *)sender
{
	NSUInteger recipientIndex = [_recipientViews indexOfObject:sender];
	
	if (recipientIndex != NSNotFound && [_recipients count] > recipientIndex) {
        self.selectedRecipient = [_recipients objectAtIndex:recipientIndex];
	}
}

- (void)selectRecipient:(id<TURecipient>)recipient
{
    self.selectedRecipient = recipient;
}

- (void)setSelectedRecipient:(id<TURecipient>)recipient
{
	BOOL should = YES;
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBar:shouldSelectRecipient:)]) {
		should = [self.recipientsBarDelegate recipientsBar:self shouldSelectRecipient:recipient];
	}
	
	if (should) {
		if (_selectedRecipient != recipient) {
			_selectedRecipient = recipient;
			
			[self _updateRecipientTextField];
			
			if (_selectedRecipient != nil) {
				[_textField becomeFirstResponder];
			}
		}
		
		for (UIButton *recipientView in _recipientViews) {
			recipientView.selected = NO;
		}
		
		NSUInteger recipientIndex = [_recipients indexOfObject:recipient];
		
		if (recipientIndex != NSNotFound && [_recipientViews count] > recipientIndex) {
			UIButton *recipientView = [_recipientViews objectAtIndex:recipientIndex];
			recipientView.selected = YES;
		}
		
		
		if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBar:didSelectRecipient:)]) {
			[self.recipientsBarDelegate recipientsBar:self didSelectRecipient:recipient];
		}
	}
}

- (void)_updateRecipientTextField
{
	_textField.hidden = _selectedRecipient != nil || ![_textField isFirstResponder];
}

- (void)_scrollToBottomAnimated:(BOOL)animated
{
    [self setContentOffset:CGPointMake(0.0, self.contentSize.height - self.bounds.size.height) animated:animated];
}


#pragma mark - FirstResponder

- (BOOL)canBecomeFirstResponder
{
	return [_textField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
	return [_textField resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
	//we use a zero width space to detect the backspace
	if ([[_textField.text substringWithRange:range] isEqual:TURecipientsPlaceholder]) {
		//select the last recipient
		if (_selectedRecipient == nil) {
			if (self.text.length == 0) {
                self.selectedRecipient = _recipients.lastObject;
			}
		} else {
			[self removeRecipient:_selectedRecipient];
            self.selectedRecipient = nil;
		}
		
		return NO;
	} else if (_selectedRecipient != nil) {
		//replace the selected recipient
		[self removeRecipient:_selectedRecipient];
        self.selectedRecipient = nil;
	}
	
	
	
	//adjust to protect our placeholder character
	if (range.location < 1) {
		range.location++;
		
		if (range.length > 0) {
			range.length--;
		}
	}
	
	
	BOOL delegateResponse = YES;
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBar:shouldChangeTextInRange:replacementText:)]) {
		delegateResponse = [self.recipientsBarDelegate recipientsBar:self shouldChangeTextInRange:range replacementText:string];
	}
	
	return delegateResponse;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBar:textDidChange:)]) {
        [self.recipientsBarDelegate recipientsBar:self textDidChange:self.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarReturnButtonClicked:)]) {
		[self.recipientsBarDelegate recipientsBarReturnButtonClicked:self];
	}
	
	return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	BOOL should = YES;
	if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarShouldBeginEditing:)]) {
		should = [self.recipientsBarDelegate recipientsBarShouldBeginEditing:self];
	}
	
	return should;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        for (UIView *recipientView in _recipientViews) {
            recipientView.alpha = 1.0;
        }
        _textField.alpha = 1.0;
        _addButton.alpha = 1.0;
        
        _summaryLabel.alpha = 0.0;
        
        
        [self setNeedsLayout];
        [self.superview layoutIfNeeded];
        
        [self _scrollToBottomAnimated:YES];
    } completion:^(BOOL finished) {
        if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarTextDidBeginEditing:)]) {
            [self.recipientsBarDelegate recipientsBarTextDidBeginEditing:self];
        }
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL should = YES;
    if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarShouldEndEditing:)]) {
        should = [self.recipientsBarDelegate recipientsBarShouldEndEditing:self];
    }
    
    return should;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.scrollEnabled = NO;
        
        for (UIView *recipientView in _recipientViews) {
            recipientView.alpha = 0.0;
        }
        _textField.alpha = 0.0;
        _addButton.alpha = 0.0;
        
        _summaryLabel.alpha = 1.0;
        
        [self setNeedsLayout];
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ([self.recipientsBarDelegate respondsToSelector:@selector(recipientsBarTextDidEndEditing:)]) {
            [self.recipientsBarDelegate recipientsBarTextDidEndEditing:self];
        }
    }];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}


#pragma mark - UIAppearance

- (void)setRecipientBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR
{
    if (backgroundImage == nil) {
        [_recipientBackgroundImages removeObjectForKey:@(state)];
    } else {
        _recipientBackgroundImages[@(state)] = backgroundImage;
    }
    
    backgroundImage = [self recipientBackgroundImageForState:state];
    
    for (UIButton *button in _recipientViews) {
        [button setBackgroundImage:backgroundImage forState:state];
    }
}

- (UIImage *)recipientBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR
{
    UIImage *backgroundImage = _recipientBackgroundImages[@(state)];
    
    if (backgroundImage == nil) {
        if (state == UIControlStateNormal) {
            backgroundImage = [UIImage imageNamed:@"recipient" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:self.traitCollection];
        } else if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
            backgroundImage = [UIImage imageNamed:@"recipient-selected" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:self.traitCollection];
        }
        
        backgroundImage = [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:14 topCapHeight:0];
    }
    
    return backgroundImage;
}

- (void)setRecipientContentEdgeInsets:(UIEdgeInsets)recipientContentEdgeInsets
{
    _recipientContentEdgeInsets = recipientContentEdgeInsets;
    
    for (UIButton *button in _recipientViews) {
        button.contentEdgeInsets = _recipientContentEdgeInsets;
    }
}

- (void)setRecipientTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state
{
    if (attributes == nil) {
        [_recipientTitleTextAttributes removeObjectForKey:@(state)];
    } else {
        _recipientTitleTextAttributes[@(state)] = attributes.copy;
    }
    
    attributes = [self recipientTitleTextAttributesForState:state];
    
    for (UIButton *button in _recipientViews) {
        NSString *text = [button titleForState:state] ?: [button attributedTitleForState:state].string ?: @"";
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [button setAttributedTitle:attributedText forState:state];
    }
}

- (NSDictionary *)recipientTitleTextAttributesForState:(UIControlState)state
{
    NSDictionary *attributes = _recipientTitleTextAttributes[@(state)];
    
    if (attributes == nil) {
        if (state == UIControlStateNormal) {
            attributes = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                           NSForegroundColorAttributeName: self.tintColor,
                           };
        } else if (state == UIControlStateHighlighted) {
            attributes = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
        } else if (state == UIControlStateSelected) {
            attributes = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
        }
    }
    
    return attributes;
}

- (void)setSummaryTextAttributes:(NSDictionary *)attributes
{
    _summaryTextAttributes = [attributes copy];
    
    [self _updateSummary];
}

- (void)setSearchFieldTextAttributes:(NSDictionary *)attributes
{
    _searchFieldTextAttributes = [attributes copy];
    
    if (_searchFieldTextAttributes[NSFontAttributeName] != nil) {
        _textField.font = _searchFieldTextAttributes[NSFontAttributeName];
    } else {
        _textField.font = [UIFont systemFontOfSize:16.0];
    }
    
    if (_searchFieldTextAttributes[NSForegroundColorAttributeName] != nil) {
        _textField.textColor = _searchFieldTextAttributes[NSForegroundColorAttributeName];
    } else {
        _textField.textColor = [UIColor blackColor];
    }
}

- (void)setPlaceholderTextAttributes:(NSDictionary *)attributes
{
    _placeholderTextAttributes = [attributes copy];
    
    [self _updateSummary];
}

- (void)setLabelTextAttributes:(NSDictionary *)attributes
{
    _labelTextAttributes = attributes;
    
    NSString *text = _toLabel.text;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:_labelTextAttributes];
    _toLabel.attributedText = attributedText;
}

- (NSDictionary *)labelTextAttributes
{
    NSDictionary *labelTextAttributes = _labelTextAttributes;
    
    if (labelTextAttributes == nil) {
        labelTextAttributes = @{
                                NSForegroundColorAttributeName: [UIColor colorWithWhite:0.498 alpha:1.000],
                                NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                };
    }
    
    return labelTextAttributes;
}

- (void)setUsesTransparency:(BOOL)usesTransparency
{
    _usesTransparency = usesTransparency;
    
    if (_usesTransparency) {
        if (_backgroundView == nil) {
            _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        }
        
        [self insertSubview:_backgroundView atIndex:0];
        self.backgroundColor = [UIColor clearColor];
    } else {
        [_backgroundView removeFromSuperview];
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
