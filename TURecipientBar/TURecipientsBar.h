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


/** The primary view for a recipient bar.
 
 This view can be used independantly, but works best with TURecipientsDisplayController.
 */


@interface TURecipientsBar : UIScrollView <UITextFieldDelegate>

/**---------------------------------------------------------------------------------------
 * @name Text Content
 *  ---------------------------------------------------------------------------------------
 */

/** The current or starting search text.
 
 The default value is nil.
 */
@property (nonatomic, copy) NSString *text;

/** The text for the label in front of both the search field and tokens.
 
 The default value is "To: ".
 
 You can set this to nil to disable the label entirely.
 
 Use `toLabel` instead.
 */
@property (nonatomic, copy) NSString *label __attribute__((deprecated));

/** The string that is displayed when there is no other text in the search field.
 
 The default value is nil.
 */
@property (nonatomic, copy) NSString *placeholder;

/** Whether the bar is searching or not.
 
 When the user taps on the bar it enters a searching mode that shows the recipients as tokens.
 */
@property (nonatomic) BOOL searching;

/** Animate changes to searching.
 
 Sets searching either animated or not. Note that this calls setSearching: inside of an animation block if needed.
 
 @param searching What to set searching to.
 @param animated Whether the change should be animated or not.
 */
- (void)setSearching:(BOOL)searching animated:(BOOL)animated;


/**---------------------------------------------------------------------------------------
 * @name Accessing Views
 *  ---------------------------------------------------------------------------------------
 */

@property (nonatomic) UITextAutocapitalizationType autocapitalizationType __attribute__((deprecated));
@property (nonatomic) UITextAutocorrectionType autocorrectionType __attribute__((deprecated));
@property (nonatomic) UIKeyboardType keyboardType __attribute__((deprecated));
@property (nonatomic) UITextSpellCheckingType spellCheckingType __attribute__((deprecated));

/** The text field used for searching.
 
 This text field moves to the front of the list of recipients.
 
 You can use this to customize the text input attributes for searching.
 */
@property (nonatomic, readonly) UITextField *textField;

@property (nonatomic, readonly) UIView *lineView;

@property (nonatomic, readonly) UIButton *addButton;

@property (nonatomic, readonly) UILabel *summaryLabel;

/** The label in front of both the search field and tokens.
 
 The default text is "To: ". You can set the text to nil to disable the label entirely.
 */
@property (nonatomic, readonly) UILabel *toLabel;

/** Whether the add button should appear.
 
 The add button calls the delegates method -recipientsBarAddButtonClicked:. It is a UIButtonTypeContactAdd type button.
 */
@property (nonatomic) BOOL showsAddButton;

/** Whether the layer shadows should be hidden.
 
 The display layer adds a shadow during search, this boolean allows them to be hidden.
 */
@property (nonatomic) BOOL showsShadows;

/** Whether adding and removing recipients should be animated.
 
 Hint: they should. This is turned on by defualt.
 
 When turned on, recipients will fade and zoom. When turned off, they will snap immediately.
 */
@property (nonatomic) BOOL animatedRecipientsInAndOut;

/** Control the height of the bar while searching.
 
 By default, the bar shrinks down to a single line when the user is searching for a recipient. When this is set to `YES`, the control will remain at it's full height.
 */
@property (nonatomic) BOOL showsMultipleLinesWhileSearching;

/** The height constraint for the entire bar.
 
 You can use this to set the height constraint in Interface Builder. This was almost necessary in iOS 6, however in iOS 7, you can set a placeholder constraint and let the bar create it's own height constraint.
 
 You can also change the priority. It must be lower than whatever constraint you are using to limit the bars height. The default priority is `UILayoutPriorityDefaultHigh` (`750`).
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;


/**---------------------------------------------------------------------------------------
 * @name Delegate
 *  ---------------------------------------------------------------------------------------
 */

/** The recipients bar’s delegate object.
 
 The delegate should conform to the TURecipientsBarDelegate protocol. Set this property to further modify the behavior. The default value is nil.
 */
@property (nonatomic, weak) id<TURecipientsBarDelegate> recipientsBarDelegate;


/**---------------------------------------------------------------------------------------
 * @name Recipients
 *  ---------------------------------------------------------------------------------------
 */

/** An array of all the recipients objects.
 
 If you want to add or remove recipients, use -addRecipient: and -removeRecipient:.
 
 Items are of type TURecipient.
 */
@property (nonatomic, readonly) NSArray *recipients;

/** Add a recipient.
 
 This will both add the recipient to the array of recipients and will also update the view, whether it is in searching mode or not.
 
@param recipient A recipient to add.
 */
- (void)addRecipient:(id<TURecipient>)recipient;

/** Remove a recipient.
 
 This will both remove the recipient from the array of recipients and will also update the view, whether it is in searching mode or not.
 
 @param recipient A recipient to remove.
 */
- (void)removeRecipient:(id<TURecipient>)recipient;

/** The currently selected recipient.
 
 If the bar is in search mode, you can use this to select the token that represents it. If the bar is not searching, this has no effect.
 */
@property (nonatomic, strong) id<TURecipient> selectedRecipient;

/** Select a recipient.
 
 DEPRECATED: Use selectedRecipient
 
 If the bar is in search mode, you can use this to select the token that represents it. If the bar is not searching, this has no effect.
 
 @param recipient A recipient to select.
 */
- (void)selectRecipient:(id<TURecipient>)recipient __attribute__((deprecated));


/**---------------------------------------------------------------------------------------
 * @name Customizing Appearance
 *  ---------------------------------------------------------------------------------------
 */

/** Sets the background image for the token that represents a recipient.
 
 Note that by default, UIControlStateNormal, UIControlStateHighlighted and UIControlStateSelected are set and must be overriden (thus, setting a image for normal will not be applied when the token is highlighted or selected). The other states are not currently used.
 
 @param backgroundImage The background image to use. This should be a resizable image.
 @param state The state to use this background in.
 */
- (void)setRecipientBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

/** The background image for the token that represents a recipient.
 
 Defaults to iOS 6 style token images. UIControlStateHighlighted and UIControlStateSelected use the same default image.
 
 @param state The state to use this background in.
 @return The background image for the given state.
 */
- (UIImage *)recipientBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

/** The edge insets for the token that represents a recipient.
 
 If you customize the recipient background image, you may need to customize the positioning of the title.
 */
@property (nonatomic) UIEdgeInsets recipientContentEdgeInsets UI_APPEARANCE_SELECTOR;

/** The text attributes for the token that represents a recipient.
 
 When present, these attributes will override the default ones for tokens. Any attribute that is not set here will use the default.
 
 Note that by default, UIControlStateNormal, UIControlStateHighlighted and UIControlStateSelected are set and must be overriden (thus, setting a image for normal will not be applied when the token is highlighted or selected). The other states are not currently used.
 
 @param state The state to use the attributes in.
 */
- (void)setRecipientTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

/** The text attributes for the token that represents a recipient.
 
 When present, these attributes will override the default ones for tokens. Any attribute that is not set here will use the default.
 
 Note that by default, UIControlStateNormal, UIControlStateHighlighted and UIControlStateSelected are set and must be overriden (thus, setting a image for normal will not be applied when the token is highlighted or selected). The other states are not currently used.
 
 @param state The state to use this background in.
 @return The text attributes override for the given state.
 */
- (NSDictionary *)recipientTitleTextAttributesForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

/** The text attributes applied to the label.
 */
@property (nonatomic, copy) NSDictionary *labelTextAttributes UI_APPEARANCE_SELECTOR __attribute__((deprecated));

/** The text attributes applied to the summary.
 */
@property (nonatomic, copy) NSDictionary *summaryTextAttributes UI_APPEARANCE_SELECTOR;

/** The text attributes applied to the search text field.
 
 Only the font and foreground color are used.
 */
@property (nonatomic, copy) NSDictionary *searchFieldTextAttributes UI_APPEARANCE_SELECTOR;

/** The text attributes applied to the placeholder.
 
 Note that at this time, changing summaryTextAttributes or recipientTitleTextAttributesForState: will not change the placeholder attributes.
 */
@property (nonatomic, copy) NSDictionary *placeholderTextAttributes UI_APPEARANCE_SELECTOR;

/** Whether the recipient bar should use a visual effect for it's background.
 
 When set to true, the background will use a UIVisualEffectView for it's background that matches UINavigationBar. When set to false (the default) a plain white background is used. This is good for bars that are placed directly below the navigation bar without other entry fields. The messages app uses this style while the mail app does not.
 */
@property (nonatomic) BOOL usesTransparency UI_APPEARANCE_SELECTOR;

@end


@protocol TURecipientsBarDelegate <NSObject>

@optional

/**---------------------------------------------------------------------------------------
 * @name Editing Text
 *  ---------------------------------------------------------------------------------------
 */

/** Asks the delegate if editing should begin in the specified search bar.
 
 Return `NO` to not become first responder.
 
 @param recipientsBar The recipient bar that is being edited.
 @return `YES` if an editing session should be initiated, otherwise, `NO`.
 */
- (BOOL)recipientsBarShouldBeginEditing:(TURecipientsBar *)recipientsBar;

/** Tells the delegate when the user begins editing the search text.
 
 Called when text starts editing.
 
 @param recipientsBar The recipient bar that is being edited.
 */
- (void)recipientsBarTextDidBeginEditing:(TURecipientsBar *)recipientsBar;

/** Asks the delegate if editing should stop in the specified search bar.
 
 Return `NO` to not resign first responder.
 
 @param recipientsBar The recipient bar that is being edited.
 @return `YES` if editing should stop, otherwise, `NO`.
 */
- (BOOL)recipientsBarShouldEndEditing:(TURecipientsBar *)recipientsBar;

/** Tells the delegate that the user finished editing the search text.
 
 Called when text ends editing.
 
 @param recipientsBar The recipient bar that is being edited.
 */
- (void)recipientsBarTextDidEndEditing:(TURecipientsBar *)recipientsBar;

/** Tells the delegate that the user changed the search text.
 
 Called when text changes (including clear).
 
 @param recipientsBar The recipient bar that is being edited.
 @param searchText The current text in the search text field.
 */
- (void)recipientsBar:(TURecipientsBar *)recipientsBar textDidChange:(NSString *)searchText;

/** Asks the delegate if editing should stop in the specified recipient bar.
 
 Called before text changes.
 
 @param recipientsBar The recipient bar that is being edited.
 @param range The range of the text to be changed.
 @param text The text to replace existing text in range.
 @return `YES` if text in range should be replaced by text, otherwise, `NO`.
 */
- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

/**---------------------------------------------------------------------------------------
 * @name Selection
 *  ---------------------------------------------------------------------------------------
 */

/** Asks the delegate if recipients should be selected.
 
 Return no to disable selection.
 
 @param recipientsBar The recipient bar that is being edited.
 @param recipient The recipient being selected.
 @return `YES` if the recipient should be selected, otherwise, `NO`.
 */
- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldSelectRecipient:(id<TURecipient>)recipient;

/** Tells the delegate that recipient selection has changed.
 
 Called when the user selects a recipient, either with the back delete key, or by tapping them.
 
 @param recipientsBar The recipient bar that is being edited.
 @param recipient The recipient that was selected.
 */
- (void)recipientsBar:(TURecipientsBar *)recipientsBar didSelectRecipient:(id<TURecipient>)recipient;

/**---------------------------------------------------------------------------------------
 * @name Clicking Buttons
 *  ---------------------------------------------------------------------------------------
 */

/**  Tells the delegate when the return key is pressed.
 
 Called when the keyboard return button is pressed.
 
 @param recipientsBar The recipient bar that is being edited.
 */
- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar;

/**  Tells the delegate when the add button is pressed.
 
 Called when the add button is pressed. Use this to show recipient selection UI.
 
 @param recipientsBar The recipient bar that is being edited.
 */
- (void)recipientsBarAddButtonClicked:(TURecipientsBar *)recipientsBar;

@end
