//
//  TUComposeBar.h
//  ThinkSocial
//
//  Created by David Beck on 10/23/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TURecipient.h"


@protocol TUComposeBarDelegate;


@interface TURecipientBar : UIScrollView <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, readonly) NSArray *recipients;
- (void)addRecipient:(TURecipient *)recipient;
@property (nonatomic) BOOL searching;
- (void)setSearching:(BOOL)searching animated:(BOOL)animated;

@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UITextSpellCheckingType spellCheckingType;

@property (nonatomic, weak) id<TUComposeBarDelegate> composeBarDelegate;

- (void)selectRecipient:(TURecipient *)recipient;

@end


@protocol TUComposeBarDelegate <NSObject>

@optional

- (BOOL)composeBarShouldBeginEditing:(TURecipientBar *)composeBar;                      // return NO to not become first responder
- (void)composeBarTextDidBeginEditing:(TURecipientBar *)composeBar;                     // called when text starts editing
- (BOOL)composeBarShouldEndEditing:(TURecipientBar *)composeBar;                        // return NO to not resign first responder
- (void)composeBarTextDidEndEditing:(TURecipientBar *)composeBar;                       // called when text ends editing
- (void)composeBar:(TURecipientBar *)composeBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)composeBar:(TURecipientBar *)composeBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; // called before text changes

- (BOOL)composeBar:(TURecipientBar *)composeBar shouldSelectRecipient:(TURecipient *)recipient;
- (void)composeBar:(TURecipientBar *)composeBar didSelectRecipient:(TURecipient *)recipient;

- (void)composeBarReturnButtonClicked:(TURecipientBar *)composeBar;                     // called when keyboard return button pressed
- (void)composeBarAddButtonClicked:(TURecipientBar *)composeBar;                        // called when add button pressed

@end
