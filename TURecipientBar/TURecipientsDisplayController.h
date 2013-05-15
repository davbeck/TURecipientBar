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


@interface TURecipientsDisplayController : NSObject <TURecipientsBarDelegate>

@property(nonatomic, getter=isActive) BOOL active;
- (void)setActive:(BOOL)active animated:(BOOL)animated;

@property (nonatomic, weak) IBOutlet id<TURecipientsDisplayDelegate> delegate;

@property (nonatomic, strong) IBOutlet TURecipientsBar *recipientsBar;
@property (nonatomic, strong) IBOutlet UIViewController *contentsController;
@property (nonatomic, readonly, strong) UITableView *searchResultsTableView;
@property (nonatomic, weak) IBOutlet id<UITableViewDataSource> searchResultsDataSource;
@property (nonatomic, weak) IBOutlet id<UITableViewDelegate> searchResultsDelegate;

- (id)initWithRecipientsBar:(TURecipientsBar *)recipientsBar contentsController:(UIViewController *)viewController;

@end


@protocol TURecipientsDisplayDelegate <NSObject>

@optional

// when we start/end showing the search UI
- (BOOL)recipientsDisplayControllerShouldBeginSearch:(TURecipientsDisplayController *)controller;
- (void)recipientsDisplayControllerWillBeginSearch:(TURecipientsDisplayController *)controller;
- (void)recipientsDisplayControllerDidBeginSearch:(TURecipientsDisplayController *)controller;
- (void)recipientsDisplayControllerWillEndSearch:(TURecipientsDisplayController *)controller;
- (void)recipientsDisplayControllerDidEndSearch:(TURecipientsDisplayController *)controller;

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;

// called when table is shown/hidden
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView;
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView;
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)recipientsDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;

- (TURecipient *)recipientsDisplayController:(TURecipientsDisplayController *)controller willAddRecipient:(TURecipient *)recipient;
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didAddRecipient:(TURecipient *)recipient;

@end
