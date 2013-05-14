//
//  TUComposeBar.m
//  ThinkSocial
//
//  Created by David Beck on 10/23/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipientBar.h"

#import <QuartzCore/QuartzCore.h>


#define TUComposeLineHeight 43.0
#define TUComposePlaceholder @"\u200B"

void *TUComposeSelectionContext = &TUComposeSelectionContext;


@implementation TURecipientBar
{
	UIView *_contentView;
	UITextField *_textField;
	UILabel *_toLabel;
	UIButton *_addButton;
	UILabel *_summaryLabel;
	UIView *_lineView;
	NSArray *_updatingConstraints;
	
	NSMutableArray *_recipients;
	NSMutableArray *_recipientViews;
	NSMutableArray *_recipientLines;
	CGSize _lastKnownSize;
	TURecipient *_selectedRecipient;
}

#pragma mark - Properties

- (NSArray *)recipients
{
	return [_recipients copy];
}

- (void)addRecipient:(TURecipient *)recipient
{
	NSIndexSet *changedIndex = [NSIndexSet indexSetWithIndex:_recipients.count];
	
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:changedIndex forKey:@"recipients"];
	[_recipients addObject:recipient];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:changedIndex forKey:@"recipients"];
	
	
	UIButton *recipientView = [UIButton buttonWithType:UIButtonTypeCustom];
	recipientView.contentEdgeInsets = UIEdgeInsetsMake(0.0, 9.0, 0.0, 9.0);
	recipientView.titleLabel.font = [UIFont systemFontOfSize:15.0];
	[recipientView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[recipientView setBackgroundImage:[[UIImage imageNamed:@"recipient.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0]
					  forState:UIControlStateNormal];
	[recipientView addTarget:self action:@selector(selectRecipientButton:) forControlEvents:UIControlEventTouchUpInside];
	
	[recipientView setBackgroundImage:[[UIImage imageNamed:@"recipient-selected.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0]
							 forState:UIControlStateHighlighted];
	[recipientView setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[recipientView setBackgroundImage:[[UIImage imageNamed:@"recipient-selected.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0]
							 forState:UIControlStateSelected];
	[recipientView setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	recipientView.adjustsImageWhenHighlighted = NO;
	
	recipientView.translatesAutoresizingMaskIntoConstraints = NO;
	[_contentView addSubview:recipientView];
	[_recipientViews addObject:recipientView];
	
	
	[recipientView setTitle:recipient.title forState:UIControlStateNormal];
	
	[self _updateSummary];
	
	[self _resetLines];
}

- (void)removeRecipient:(TURecipient *)recipient
{
	NSIndexSet *changedIndex = [NSIndexSet indexSetWithIndex:[_recipients indexOfObject:recipient]];
	
	[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:changedIndex forKey:@"recipients"];
	[_recipients removeObjectsAtIndexes:changedIndex];
	[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:changedIndex forKey:@"recipients"];
	
	[[_recipientViews objectsAtIndexes:changedIndex] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_recipientViews removeObjectsAtIndexes:changedIndex];
	
	[self _updateSummary];
	
	[self _resetLines];
}

- (void)_resetLines
{
	_recipientLines = [NSMutableArray arrayWithObject:[_recipientViews mutableCopy]];
	[[_recipientLines lastObject] addObject:_textField];
	
	[self setNeedsUpdateConstraints];
	[self setNeedsLayout];
}

- (void)_updateSummary
{
	NSMutableString *summary = [[NSMutableString alloc] init];
	
	for (TURecipient *recipient in _recipients) {
		[summary appendString:recipient.title];
		
		if (recipient != [_recipients lastObject]) {
			[summary appendString:@", "];
		}
	}
	
	_summaryLabel.text = summary;
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

- (void)setText:(NSString *)text
{
	if (text != nil) {
		[_textField setText:[TUComposePlaceholder stringByAppendingString:text]];
	} else {
		[_textField setText:TUComposePlaceholder];
	}
	
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBar:textDidChange:)]) {
		[self.composeBarDelegate composeBar:self textDidChange:self.text];
	}
}

- (NSString *)text
{
	return [[_textField text] stringByReplacingOccurrencesOfString:TUComposePlaceholder withString:@""];
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
		
		[self setNeedsUpdateConstraints];
		[self.superview layoutIfNeeded];
		
		[self _scrollToBottom];
		
		if (_searching) {
			self.scrollEnabled = NO;
			_lineView.hidden = NO;
			_lineView.backgroundColor = [UIColor colorWithWhite:0.557 alpha:1.000];
			
			self.layer.shadowColor = [UIColor blackColor].CGColor;
			self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
			self.layer.shadowOpacity = 0.5;
			self.layer.shadowRadius = 5.0;
			self.clipsToBounds = NO;
		} else {
			_lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.000];
			
			self.layer.shadowOpacity = 0.0;
			self.layer.shadowRadius = 0.0;
			self.clipsToBounds = YES;
		}
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


#pragma mark - Initialization

- (void)dealloc
{
	[_textField removeObserver:self forKeyPath:@"selectedTextRange" context:TUComposeSelectionContext];
}

- (void)_init
{
    self.contentSize = self.bounds.size;
    
	_recipients = [NSMutableArray array];
	_recipientViews = [NSMutableArray array];
	_recipientLines = [NSMutableArray arrayWithObject:[NSMutableArray array]];
	
	
	self.backgroundColor = [UIColor whiteColor];
	if (self.heightConstraint == nil) {
		_heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:TUComposeLineHeight + 1.0];
		[self addConstraint:_heightConstraint];
	}
	self.clipsToBounds = YES;
	
	_contentView = [[UIView alloc] initWithFrame:self.bounds];
	_contentView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:_contentView];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView)]];
	
	_lineView = [[UIView alloc] init];
	_lineView.backgroundColor = [UIColor colorWithWhite:0.800 alpha:1.000];
	_lineView.translatesAutoresizingMaskIntoConstraints = NO;
	[_contentView addSubview:_lineView];
	[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lineView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lineView)]];
	
	_toLabel = [[UILabel alloc] init];
	_toLabel.textColor = [UIColor colorWithWhite:0.498 alpha:1.000];
	_toLabel.font = [UIFont systemFontOfSize:17.0];
	_toLabel.text = NSLocalizedString(@"To:", nil);
	_toLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[_toLabel setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisHorizontal];
	[_contentView addSubview:_toLabel];
	[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_toLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toLabel)]];
	[_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_toLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:21.0]];
	
	_addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	_addButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
	[_contentView addSubview:_addButton];
	[_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_addButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-23.0]];
	
	_textField = [[UITextField alloc] init];
	_textField.text = TUComposePlaceholder;
	_textField.delegate = self;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
	_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textField.spellCheckingType = UITextSpellCheckingTypeNo;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.translatesAutoresizingMaskIntoConstraints = NO;
	[_contentView addSubview:_textField];
	[_textField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textField(43)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textField)]];
	[_textField setContentHuggingPriority:100 forAxis:UILayoutConstraintAxisHorizontal];
	[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_textField]-6-[_addButton]-6-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textField, _addButton)]];
	[_textField addObserver:self forKeyPath:@"selectedTextRange" options:0 context:TUComposeSelectionContext];
	
	[[_recipientLines lastObject] addObject:_textField];
	
	
	_summaryLabel = [[UILabel alloc] init];
	_summaryLabel.font = [UIFont systemFontOfSize:15.0];
	_summaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[_contentView addSubview:_summaryLabel];
	[_contentView addConstraint:[NSLayoutConstraint constraintWithItem:_toLabel attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:_summaryLabel attribute:NSLayoutAttributeBaseline multiplier:1.0 constant:0.0]];
	[_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_toLabel]-13-[_summaryLabel]-12-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toLabel, _summaryLabel)]];
	[_summaryLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
	
	
	[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(select:)]];
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

- (void)updateConstraints
{
	[super updateConstraints];
	
	if (_updatingConstraints != nil) {
		[_contentView removeConstraints:_updatingConstraints];
	}
	
	NSMutableArray *updatingConstraints = [NSMutableArray array];
	
	
	UIView *lastView = _toLabel;
	CGFloat topOffset = 0.0;
	UILayoutPriority compressionResistance = UILayoutPriorityDefaultHigh;
	
	for (NSArray *line in _recipientLines) {
		for (UIView *recipientView in line) {
			if (lastView == _toLabel) {
				[updatingConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastView]-4-[recipientView]->=6-[_addButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(recipientView, lastView, _addButton)]];
			} else if (lastView == nil) {
				[updatingConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[recipientView]->=6-[_addButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(recipientView, _addButton)]];
			} else {
				[updatingConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastView]-6-[recipientView]->=6-[_addButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(recipientView, lastView, _addButton)]];
			}
			[updatingConstraints addObject:[NSLayoutConstraint constraintWithItem:recipientView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:topOffset + TUComposeLineHeight / 2.0]];
			
			[recipientView setContentCompressionResistancePriority:compressionResistance forAxis:UILayoutConstraintAxisHorizontal];
			
			lastView = recipientView;
			compressionResistance -= 1;
		}
		
		lastView = nil;
		topOffset += TUComposeLineHeight - 8.0;
	}
	
	
	
	if (_textField.isFirstResponder) {
		[updatingConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lineView(1)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lineView)]];
	} else {
		[updatingConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-43-[_lineView(1)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lineView)]];
	}
	
	
	self.contentSize = CGSizeMake(self.contentSize.width, topOffset + 9.0);
	if (_searching) {
		[self _scrollToBottom];
	}
	
	if (_textField.isFirstResponder && !self.searching) {
		self.heightConstraint.constant = self.contentSize.height;
	} else {
		self.heightConstraint.constant = TUComposeLineHeight + 1.0;
	}
	
	
	[updatingConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.contentSize.height]];
	[updatingConstraints addObject:[NSLayoutConstraint constraintWithItem:_contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.contentSize.width]];
	
	_updatingConstraints = updatingConstraints;
	[_contentView addConstraints:_updatingConstraints];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[_contentView layoutSubviews];
	
	NSMutableArray *lastLine = [_recipientLines lastObject];
	[[lastLine copy] enumerateObjectsUsingBlock:^(UIView *recipientView, NSUInteger index, BOOL *stop) {
		if (index != 0) {
			if (recipientView.intrinsicContentSize.width > recipientView.bounds.size.width
				|| (recipientView == _textField && recipientView.bounds.size.width < 100.0)) {
				[_recipientLines addObject:[[lastLine subarrayWithRange:NSMakeRange(index, lastLine.count - index)] mutableCopy]];
				[lastLine removeObjectsInArray:[_recipientLines lastObject]];
				
				[self updateConstraints];
				[self layoutSubviews];
				
				*stop = YES;
			}
		}
	}];
	
	
	if (self.frame.size.width != self.contentSize.width) {
		self.contentSize = CGSizeMake(self.frame.size.width, self.contentSize.height);
		[self _resetLines];
		[self updateConstraints];
		[self layoutSubviews];
		return;
	}
	
	
	if (_textField.isFirstResponder && self.contentSize.height > self.frame.size.height && !_searching) {
		self.scrollEnabled = YES;
		_lineView.hidden = YES;
	} else {
		self.scrollEnabled = NO;
		_lineView.hidden = NO;
	}
}

- (void)_frameChanged
{
	if (_recipients != nil && self.bounds.size.width != _lastKnownSize.width) {
		[self _resetLines];
	}
	
	if (_textField.isFirstResponder && self.contentSize.height > self.frame.size.height && !_searching) {
		self.scrollEnabled = YES;
		_lineView.hidden = YES;
	} else {
		self.scrollEnabled = NO;
		_lineView.hidden = NO;
	}
	
	if (_selectedRecipient == nil
		&& (self.bounds.size.width != _lastKnownSize.width || self.bounds.size.height != _lastKnownSize.height)) {
		[self _scrollToBottom];
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


#pragma mark - Actions

- (IBAction)addContact:(id)sender
{
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBarAddButtonClicked:)]) {
		[self.composeBarDelegate composeBarAddButtonClicked:self];
	}
}

- (IBAction)select:(id)sender
{
	[self becomeFirstResponder];
	
	[self selectRecipient:nil];
}

- (IBAction)selectRecipientButton:(UIButton *)sender
{
	NSUInteger recipientIndex = [_recipientViews indexOfObject:sender];
	
	if (recipientIndex != NSNotFound && [_recipients count] > recipientIndex) {
		[self selectRecipient:[_recipients objectAtIndex:recipientIndex]];
	}
}

- (void)selectRecipient:(TURecipient *)recipient
{
	BOOL should = YES;
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBar:shouldSelectRecipient:)]) {
		should = [self.composeBarDelegate composeBar:self shouldSelectRecipient:recipient];
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
		
		
		if ([self.composeBarDelegate respondsToSelector:@selector(composeBar:didSelectRecipient:)]) {
			[self.composeBarDelegate composeBar:self didSelectRecipient:recipient];
		}
	}
}

- (void)_updateRecipientTextField
{
	_textField.hidden = _selectedRecipient != nil || ![_textField isFirstResponder];
}

- (void)_scrollToBottom
{
	self.contentOffset = CGPointMake(0.0, self.contentSize.height - self.bounds.size.height);
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
	if ([[_textField.text substringWithRange:range] isEqual:TUComposePlaceholder]) {
		//select the last recipient
		if (_selectedRecipient == nil) {
			if (self.text.length == 0) {
				[self selectRecipient:[_recipients lastObject]];
			}
		} else {
			[self removeRecipient:_selectedRecipient];
			[self selectRecipient:nil];
		}
		
		return NO;
	} else if (_selectedRecipient != nil) {
		//replace the selected recipient
		[self removeRecipient:_selectedRecipient];
		[self selectRecipient:nil];
	}
	
	
	
	//adjust to protect our placeholder character
	if (range.location < 1) {
		range.location++;
		
		if (range.length > 0) {
			range.length--;
		}
	}
	
	
	BOOL delegateResponse = YES;
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBar:shouldChangeTextInRange::replacementText:)]) {
		delegateResponse = [self.composeBarDelegate composeBar:self shouldChangeTextInRange:range replacementText:string];
	}
	
	
	if (delegateResponse) {
		[self _manuallyChangeTextField:textField inRange:range replacementString:string];
		
		
		if ([self.composeBarDelegate respondsToSelector:@selector(composeBar:textDidChange:)]) {
			[self.composeBarDelegate composeBar:self textDidChange:self.text];
		}
	}
	
	
	return NO;
}

- (void)_manuallyChangeTextField:(UITextField *)textField inRange:(NSRange)range replacementString:(NSString *)string
{
	//we save the offset from the end of the document and reset the selection to be a caret there
	NSInteger offset = [_textField offsetFromPosition:_textField.selectedTextRange.end toPosition:_textField.endOfDocument];
	
	textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	
	UITextPosition *newEnd = [_textField positionFromPosition:_textField.endOfDocument inDirection:UITextLayoutDirectionLeft offset:offset];
	_textField.selectedTextRange = [_textField textRangeFromPosition:newEnd toPosition:newEnd];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBarReturnButtonClicked:)]) {
		[self.composeBarDelegate composeBarReturnButtonClicked:self];
	}
	
	return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	BOOL should = YES;
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBarShouldBeginEditing:)]) {
		should = [self.composeBarDelegate composeBarShouldBeginEditing:self];
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
        
        
        [self setNeedsUpdateConstraints];
        [self.superview layoutIfNeeded];
        
        [self _scrollToBottom];
    } completion:^(BOOL finished) {
        if ([self.composeBarDelegate respondsToSelector:@selector(composeBarTextDidBeginEditing:)]) {
            [self.composeBarDelegate composeBarTextDidBeginEditing:self];
        }
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	BOOL should = YES;
	if ([self.composeBarDelegate respondsToSelector:@selector(composeBarShouldEndEditing:)]) {
		should = [self.composeBarDelegate composeBarShouldEndEditing:self];
	}
	
	if (should) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
				self.scrollEnabled = NO;
				_lineView.hidden = NO;
				
				for (UIView *recipientView in _recipientViews) {
					recipientView.alpha = 0.0;
				}
				_textField.alpha = 0.0;
				_addButton.alpha = 0.0;
				
				_summaryLabel.alpha = 1.0;
				
				[self setNeedsUpdateConstraints];
				[self.superview layoutIfNeeded];
				
				self.contentOffset = CGPointMake(0.0, 0.0);
			} completion:^(BOOL finished) {
				if ([self.composeBarDelegate respondsToSelector:@selector(composeBarTextDidEndEditing:)]) {
					[self.composeBarDelegate composeBarTextDidEndEditing:self];
				}
			}];
		});
	}
	
	return should;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

@end
