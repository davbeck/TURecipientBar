//
//  TUComposeBar.h
//  ThinkSocial
//
//  Created by David Beck on 10/23/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TURecipient.h"


@protocol TURecipientsBarDelegate;


@interface TURecipientsBar : UIScrollView <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, readonly) NSArray *recipients;
- (void)addRecipient:(TURecipient *)recipient;
@property (nonatomic) BOOL searching;
- (void)setSearching:(BOOL)searching animated:(BOOL)animated;

@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UITextSpellCheckingType spellCheckingType;
@property (nonatomic) BOOL showsAddButton;

@property (nonatomic, weak) id<TURecipientsBarDelegate> composeBarDelegate;

- (void)selectRecipient:(TURecipient *)recipient;

@end


@protocol TURecipientsBarDelegate <NSObject>

@optional

- (BOOL)composeBarShouldBeginEditing:(TURecipientsBar *)composeBar;                      // return NO to not become first responder
- (void)composeBarTextDidBeginEditing:(TURecipientsBar *)composeBar;                     // called when text starts editing
- (BOOL)composeBarShouldEndEditing:(TURecipientsBar *)composeBar;                        // return NO to not resign first responder
- (void)composeBarTextDidEndEditing:(TURecipientsBar *)composeBar;                       // called when text ends editing
- (void)composeBar:(TURecipientsBar *)composeBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)composeBar:(TURecipientsBar *)composeBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; // called before text changes

- (BOOL)composeBar:(TURecipientsBar *)composeBar shouldSelectRecipient:(TURecipient *)recipient;
- (void)composeBar:(TURecipientsBar *)composeBar didSelectRecipient:(TURecipient *)recipient;

- (void)composeBarReturnButtonClicked:(TURecipientsBar *)composeBar;                     // called when keyboard return button pressed
- (void)composeBarAddButtonClicked:(TURecipientsBar *)composeBar;                        // called when add button pressed

@end
