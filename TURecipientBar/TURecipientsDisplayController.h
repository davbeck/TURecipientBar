//
//  TURecipientsDisplayController.h
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TURecipientsBar.h"


@protocol TURecipientsDisplayDelegate;


/** The controller for managing a `TURecipientsBar`.
 
 You can use this class to enable searching, as well as many other features.
 
 A recipients display controller manages the display of a recipients bar, along with
 a table view that displays search results.
 
 You initialize a recipients display controller with a recipients bar and a view controller
 responsible for managing the recipients and data to be searched. When the user starts a
 search, the recipients display controller superimposes the search interface over the original
 view controller’s view and shows the search results in its table view.
 */


@interface TURecipientsDisplayController : NSObject <TURecipientsBarDelegate>

/**---------------------------------------------------------------------------------------
 * @name Delegate
 *  ---------------------------------------------------------------------------------------
 */

/** The delegate for the display controller.
 
 The `TURecipientsBarDelegate` methods are also called on the controller's delegates, after
 the controller processes them.
 */
@property (nonatomic, weak) IBOutlet id<TURecipientsDisplayDelegate> delegate;

/** The corresponding recipients bar.
 
 The controller is mostly useless if this is not set.
 */
@property (nonatomic, strong) IBOutlet TURecipientsBar *recipientsBar;

/** The view controller to display the search results with.
 
 If you disable the search results table, this is not necessary. When searching begins, the
 `searchResultsTableView` will be added to the view controllers view, and using auto layout,
 attach to the bottom, right and left of the view, and the bottom of the recipients bar. For
 obvious reasons, the view property should return a UIView and not a UIScrollView.
 */
@property (nonatomic, weak) IBOutlet UIViewController *contentsController;

/** The table view used to display search results.
 
 This table is populated and controlled with `searchResultsDataSource` and `searchResultsDelegate`.
 */
@property (nonatomic, readonly, strong) UITableView *searchResultsTableView;

/** The datasource for the `searchResultsTableView`
 
 You can display whatever content you want, but generally will show the search results filtered
 by the recipients bar search string.
 */
@property (nonatomic, weak) IBOutlet id<UITableViewDataSource> searchResultsDataSource;

/** The delegate for the `searchResultsTableView`
 
 You can respond to the table however you like, but typically will add a recipient when the
 user selects a row.
 */
@property (nonatomic, weak) IBOutlet id<UITableViewDelegate> searchResultsDelegate;

/** Create a controller
 
 You can also create a controller in Interface Builder and connect `recipientsBar` and all the
 other properties with IBOutlets.
 
 Note that if viewController conformst to the respective protocols, it will also be used for
 `searchResultsDataSource` and `searchResultsDelegate`. You can manually set both those properties
 to nil or another value afterwards.
 
 @param recipientsBar The recipient bar for the controller to control.
 @param viewController The viewController for the controller.
 @return A controller ready to be used.
 */
- (id)initWithRecipientsBar:(TURecipientsBar *)recipientsBar contentsController:(UIViewController *)viewController;

@end


/** The delegate for `TURecipientsDisplayController`.
 
 Use this protocol to control and customize a `TURecipientsDisplayController`.
 */

@protocol TURecipientsDisplayDelegate <NSObject, TURecipientsBarDelegate>

@optional

/**---------------------------------------------------------------------------------------
 * @name Search State Change
 *  ---------------------------------------------------------------------------------------
 */

/** Asks the delegate if the controller should begin searching.
 
 Called when the search UI will be shown. You can return `NO` from this mehtod to disable the search
 table view. The recipients bar will still change to single line mode either way.
 
 If you do not impliment this method, the search UI will be shown.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @return `YES` to show the search UI, otherwise, `NO`.
 */
- (BOOL)recipientsDisplayControllerShouldBeginSearch:(TURecipientsDisplayController *)controller;

/** Tells the delegate that the controller is about to begin searching.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 */
- (void)recipientsDisplayControllerWillBeginSearch:(TURecipientsDisplayController *)controller;

/** Tells the delegate that the controller is about to begin searching.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 */
- (void)recipientsDisplayControllerDidBeginSearch:(TURecipientsDisplayController *)controller;

/** Tells the delegate that the controller is about to end searching.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 */
- (void)recipientsDisplayControllerWillEndSearch:(TURecipientsDisplayController *)controller;

/** Tells the delegate that the controller has finished searching.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 */
- (void)recipientsDisplayControllerDidEndSearch:(TURecipientsDisplayController *)controller;


/**---------------------------------------------------------------------------------------
 * @name Loading and Unloading the Table View
 *  ---------------------------------------------------------------------------------------
 */

/** Tells the delegate that the controller has loaded its table view.
 
 Apply any style customization to the table view you want to here.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The `searchResultsTableView` that was just loaded.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;

/** Tells the delegate that the controller is about to unload its table view.
 
 The `searchResultsTableView` may be unloaded during a memory warning and will always be unloaded
 on `dealloc`.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The `searchResultsTableView` that was just loaded.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;


/**---------------------------------------------------------------------------------------
 * @name Showing and Hiding the Table View
 *  ---------------------------------------------------------------------------------------
 */

/** Tells the delegate that the controller is about to display its table view.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The recipients display controller’s table view.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView;

/** Tells the delegate to add the search table view to the view hierarchy.
 
 If this is implimented by the delegate, the controller will defer to the delegate to add the search table view to a superview. If not, the controller will attempt to add it to the `contentsController`'s view.
 
 Before returning from this method, it is the delegate's responsibility to:
 
 1. Add the tableView to a superview.
 2. Set the frame of the tableView, either with constraints followed by a call to layoutIfNeeded, or manually.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The recipients display controller’s table view.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller displaySearchResultsTableView:(UITableView *)tableView;

/** Tells the delegate that the controller just displayed its table view.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The recipients display controller’s table view.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView;

/** Tells the delegate that the controller is about to hide its table view.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The recipients display controller’s table view.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;

/** Tells the delegate that the controller just hid its table view.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param tableView The recipients display controller’s table view.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView;


/**---------------------------------------------------------------------------------------
 * @name Responding to Changes in Search Criteria
 *  ---------------------------------------------------------------------------------------
 */

/** Asks the delegate if the table view should be reloaded for a given search string.
 
 If you don’t implement this method, then the results table is reloaded as soon as the search
 string changes.
 
 You might implement this method if you want to perform an asynchronous search. You would
 initiate the search in this method, then return NO. You would reload the table when you have
 results.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param searchString The string in the search bar.
 @return `YES` if the display controller should reload the data in its table view, otherwise `NO`.
 */
- (BOOL)recipientsDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;


/**---------------------------------------------------------------------------------------
 * @name Recipient Control
 *  ---------------------------------------------------------------------------------------
 */

/** Called when the controller is about to add a recipient to the recipients bar
 
 When the user hits return, the controller will try to automatically add the search string as 
 a recipient. This is useful in cases where you can enter addresses manually, such as email
 addresses or phone numbers. However, if you want to disable this behavior, you can return nil
 from this method. Alternatively, you can substitute your own recipient and return that.
 
 Note that this is not called when recipients are added directly the recipients bar.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param recipient The recipient the controller is about to add.
 @return The recipient to add.
 */
- (id<TURecipient>)recipientsDisplayController:(TURecipientsDisplayController *)controller willAddRecipient:(id<TURecipient>)recipient;

/** Tells the delegate when a recipient has been added
 
 Note that this is not called when recipients are added directly the recipients bar.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param recipient The recipient that was added.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didAddRecipient:(id<TURecipient>)recipient;

/** Tell the delegate when a recipient is removed
 
 Called whenever a recipient is removed from the recipients bar, no matter how it was removed.
 
 @param controller The recipients display controller for which the receiver is the delegate.
 @param recipient The recipient that was removed.
 */
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didRemoveRecipient:(id<TURecipient>)recipient;

@end
