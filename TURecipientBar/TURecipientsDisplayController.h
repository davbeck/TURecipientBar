//
//  TUComposeDisplayController.h
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

@property (nonatomic, strong) IBOutlet TURecipientsBar *composeBar;
@property (nonatomic, strong) IBOutlet UIViewController *composeContentsController;
@property (nonatomic, readonly, strong) UITableView *searchResultsTableView;
@property (nonatomic, weak) IBOutlet id<UITableViewDataSource> searchResultsDataSource;
@property (nonatomic, weak) IBOutlet id<UITableViewDelegate> searchResultsDelegate;

- (id)initWithComposeBar:(TURecipientsBar *)composeBar contentsController:(UIViewController *)viewController;

@end


@protocol TURecipientsDisplayDelegate <NSObject>

@optional

// when we start/end showing the search UI
- (BOOL)composeDisplayControllerShouldBeginSearch:(TURecipientsDisplayController *)controller;
- (void)composeDisplayControllerWillBeginSearch:(TURecipientsDisplayController *)controller;
- (void)composeDisplayControllerDidBeginSearch:(TURecipientsDisplayController *)controller;
- (void)composeDisplayControllerWillEndSearch:(TURecipientsDisplayController *)controller;
- (void)composeDisplayControllerDidEndSearch:(TURecipientsDisplayController *)controller;

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void)composeDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientsDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;

// called when table is shown/hidden
- (void)composeDisplayController:(TURecipientsDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientsDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientsDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientsDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)composeDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;

- (TURecipient *)composeDisplayController:(TURecipientsDisplayController *)controller willAddRecipient:(TURecipient *)recipient;
- (void)composeDisplayController:(TURecipientsDisplayController *)controller didAddRecipient:(TURecipient *)recipient;

@end
