//
//  TUComposeDisplayController.h
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TURecipientBar.h"


@protocol TUComposeDisplayDelegate;


@interface TURecipientDisplayController : NSObject <TUComposeBarDelegate>

@property(nonatomic, getter=isActive) BOOL active;
- (void)setActive:(BOOL)active animated:(BOOL)animated;

@property (nonatomic, weak) IBOutlet id<TUComposeDisplayDelegate> delegate;

@property (nonatomic, strong) IBOutlet TURecipientBar *composeBar;
@property (nonatomic, strong) IBOutlet UIViewController *composeContentsController;
@property (nonatomic, readonly, strong) UITableView *searchResultsTableView;
@property (nonatomic, weak) IBOutlet id<UITableViewDataSource> searchResultsDataSource;
@property (nonatomic, weak) IBOutlet id<UITableViewDelegate> searchResultsDelegate;

- (id)initWithComposeBar:(TURecipientBar *)composeBar contentsController:(UIViewController *)viewController;

@end


@protocol TUComposeDisplayDelegate <NSObject>

@optional

// when we start/end showing the search UI
- (void)composeDisplayControllerWillBeginSearch:(TURecipientDisplayController *)controller;
- (void)composeDisplayControllerDidBeginSearch:(TURecipientDisplayController *)controller;
- (void)composeDisplayControllerWillEndSearch:(TURecipientDisplayController *)controller;
- (void)composeDisplayControllerDidEndSearch:(TURecipientDisplayController *)controller;

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void)composeDisplayController:(TURecipientDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;

// called when table is shown/hidden
- (void)composeDisplayController:(TURecipientDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView;
- (void)composeDisplayController:(TURecipientDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)composeDisplayController:(TURecipientDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;

- (TURecipient *)composeDisplayController:(TURecipientDisplayController *)controller willAddRecipient:(TURecipient *)recipient;
- (void)composeDisplayController:(TURecipientDisplayController *)controller didAddRecipient:(TURecipient *)recipient;

@end
