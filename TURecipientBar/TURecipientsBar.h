//
//  TURecipientsBar.h
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
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, readonly) NSArray *recipients;
- (void)addRecipient:(TURecipient *)recipient;
@property (nonatomic) BOOL searching;
- (void)setSearching:(BOOL)searching animated:(BOOL)animated;

@property (nonatomic) UITextAutocapitalizationType autocapitalizationType __attribute__((deprecated));
@property (nonatomic) UITextAutocorrectionType autocorrectionType __attribute__((deprecated));
@property (nonatomic) UIKeyboardType keyboardType __attribute__((deprecated));
@property (nonatomic) UITextSpellCheckingType spellCheckingType __attribute__((deprecated));
@property (nonatomic, readonly) UITextField *textField;
@property (nonatomic) BOOL showsAddButton;

@property (nonatomic, weak) id<TURecipientsBarDelegate> recipientsBarDelegate;

- (void)selectRecipient:(TURecipient *)recipient;

// UIAppearance
- (void)setRecipientBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)recipientBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIEdgeInsets recipientContentEdgeInsets UI_APPEARANCE_SELECTOR;
- (void)setRecipientTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (NSDictionary *)recipientTitleTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) NSDictionary *labelTextAttributes UI_APPEARANCE_SELECTOR;

@end


@protocol TURecipientsBarDelegate <NSObject>

@optional

- (BOOL)recipientsBarShouldBeginEditing:(TURecipientsBar *)recipientsBar;                      // return NO to not become first responder
- (void)recipientsBarTextDidBeginEditing:(TURecipientsBar *)recipientsBar;                     // called when text starts editing
- (BOOL)recipientsBarShouldEndEditing:(TURecipientsBar *)recipientsBar;                        // return NO to not resign first responder
- (void)recipientsBarTextDidEndEditing:(TURecipientsBar *)recipientsBar;                       // called when text ends editing
- (void)recipientsBar:(TURecipientsBar *)recipientsBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; // called before text changes

- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldSelectRecipient:(TURecipient *)recipient;
- (void)recipientsBar:(TURecipientsBar *)recipientsBar didSelectRecipient:(TURecipient *)recipient;

- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar;                     // called when keyboard return button pressed
- (void)recipientsBarAddButtonClicked:(TURecipientsBar *)recipientsBar;                        // called when add button pressed

@end
