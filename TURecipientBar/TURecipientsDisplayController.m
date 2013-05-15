//
//  TUComposeDisplayController.m
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipientsDisplayController.h"

#import <QuartzCore/QuartzCore.h>


@implementation TURecipientsDisplayController
{
    BOOL _shouldBeginSearch;
}

@synthesize searchResultsTableView = _searchResultsTableView;

#pragma mark - Properties

- (void)setActive:(BOOL)active
{
	[self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated
{
	_active = active;
}

- (void)setComposeBar:(TURecipientsBar *)composeBar
{
	_composeBar = composeBar;
	
	_composeBar.composeBarDelegate = self;
}

- (UITableView *)searchResultsTableView
{
	if (_searchResultsTableView == nil) {
		_searchResultsTableView = [[UITableView alloc] initWithFrame:self.composeContentsController.view.bounds style:UITableViewStylePlain];
		_searchResultsTableView.dataSource = self.searchResultsDataSource;
		_searchResultsTableView.delegate = self.searchResultsDelegate;
		_searchResultsTableView.translatesAutoresizingMaskIntoConstraints = NO;
		_searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.925 alpha:1.000];
		
		if ([self.delegate respondsToSelector:@selector(composeDisplayController:didLoadSearchResultsTableView:)]) {
			[self.delegate composeDisplayController:self didLoadSearchResultsTableView:_searchResultsTableView];
		}
	}
	
	return _searchResultsTableView;
}

- (void)_unloadTableView
{
	if ([self.delegate respondsToSelector:@selector(composeDisplayController:willUnloadSearchResultsTableView:)]) {
		[self.delegate composeDisplayController:self willUnloadSearchResultsTableView:_searchResultsTableView];
	}
	
	_searchResultsTableView = nil;
}

- (void)_showTableView
{
	if (!self.composeBar.searching) {
        if (_shouldBeginSearch) {
            UITableView *tableView = self.searchResultsTableView;
            
            if ([self.delegate respondsToSelector:@selector(composeDisplayController:willShowSearchResultsTableView:)]) {
                [self.delegate composeDisplayController:self willShowSearchResultsTableView:tableView];
            }
            
            [self.composeContentsController.view addSubview:tableView];
            [self.composeContentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
            [self.composeContentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_composeBar][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_composeBar, tableView)]];
            
            [self.composeContentsController.view layoutIfNeeded];
            
            
            tableView.alpha = 0.0;
            [UIView animateWithDuration:0.2 animations:^{
                //we don't want this to start from it's current location
                tableView.alpha = 1.0;
            }];
            
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.composeBar setSearching:YES animated:NO];
                
                [self.composeBar.superview bringSubviewToFront:self.composeBar];
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(composeDisplayController:didShowSearchResultsTableView:)]) {
                    [self.delegate composeDisplayController:self didShowSearchResultsTableView:tableView];
                }
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.composeBar setSearching:YES animated:NO];
                
                [self.composeBar.superview bringSubviewToFront:self.composeBar];
            } completion:nil];
        }
	}
}

- (void)_hideTableView
{
	if (self.composeBar.searching) {
		UITableView *tableView = self.searchResultsTableView;
		
		if ([self.delegate respondsToSelector:@selector(composeDisplayController:willHideSearchResultsTableView:)]) {
			[self.delegate composeDisplayController:self willHideSearchResultsTableView:tableView];
		}
		
		[self.composeContentsController.view layoutIfNeeded];
		
		
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
			[self.composeBar setSearching:NO animated:NO];
			
			tableView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[tableView removeFromSuperview];
			
			if ([self.delegate respondsToSelector:@selector(composeDisplayController:didHideSearchResultsTableView:)]) {
				[self.delegate composeDisplayController:self didHideSearchResultsTableView:tableView];
			}
		}];
	}
}


#pragma mark - Initialization

- (void)dealloc
{
	[self _unloadTableView];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
	self = [self initWithComposeBar:nil contentsController:nil];
	if (self != nil) {
		
	}
	
	return self;
}

- (id)initWithComposeBar:(TURecipientsBar *)composeBar contentsController:(UIViewController *)viewController
{
	self = [super init];
	if (self != nil) {
		_composeBar = composeBar;
		_composeBar.composeBarDelegate = self;
		_composeContentsController = viewController;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	
	return self;
}


#pragma mark - Notifications

- (void)applicationDidReceiveMemoryWarning:(NSNotification *)notification
{
	if (_searchResultsTableView != nil && _searchResultsTableView.superview == nil) {
		[self _unloadTableView];
	}
}


#pragma mark - TUComposeBarDelegate

- (void)_createRecipientForComposeBar:(TURecipientsBar *)composeBar
{
	TURecipient *recipient = [TURecipient recipientWithTitle:composeBar.text address:nil];
	
	if ([self.delegate respondsToSelector:@selector(composeDisplayController:willAddRecipient:)]) {
		recipient = [self.delegate composeDisplayController:self willAddRecipient:recipient];
	}
	
	if (recipient != nil) {
		[_composeBar addRecipient:recipient];
		composeBar.text = nil;
		
		if ([self.delegate respondsToSelector:@selector(composeDisplayController:didAddRecipient:)]) {
			[self.delegate composeDisplayController:self didAddRecipient:recipient];
		}
	}
}

- (BOOL)composeBarShouldBeginEditing:(TURecipientsBar *)composeBar
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(composeBarShouldBeginEditing:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate composeBarShouldBeginEditing:composeBar];
	}
	
	if (should) {
        _shouldBeginSearch = YES;
        
        if ([self.delegate respondsToSelector:@selector(composeDisplayControllerShouldBeginSearch:)]) {
            _shouldBeginSearch = [self.delegate composeDisplayControllerShouldBeginSearch:self];
        }
        
		if (_shouldBeginSearch && [self.delegate respondsToSelector:@selector(composeDisplayControllerWillBeginSearch:)]) {
			[self.delegate composeDisplayControllerWillBeginSearch:self];
		}
	}
	
	return should;
}

- (void)composeBarTextDidBeginEditing:(TURecipientsBar *)composeBar
{
	if ([self.delegate respondsToSelector:@selector(composeBarTextDidBeginEditing:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBarTextDidBeginEditing:composeBar];
	}
	
	if (_shouldBeginSearch && [self.delegate respondsToSelector:@selector(composeDisplayControllerDidBeginSearch:)]) {
		[self.delegate composeDisplayControllerDidBeginSearch:self];
	}
}

- (BOOL)composeBarShouldEndEditing:(TURecipientsBar *)composeBar
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(composeBarShouldEndEditing:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate composeBarShouldEndEditing:composeBar];
	}

	if (should) {
		if ([self.delegate respondsToSelector:@selector(composeDisplayControllerWillEndSearch:)]) {
			[self.delegate composeDisplayControllerWillEndSearch:self];
		}
		
		if (composeBar.text.length > 0) {
			[self _createRecipientForComposeBar:composeBar];
		}
	}
	
	return should;
}

- (void)composeBarTextDidEndEditing:(TURecipientsBar *)composeBar
{
	if ([self.delegate respondsToSelector:@selector(composeBarTextDidEndEditing:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBarTextDidEndEditing:composeBar];
	}
	
	if ([self.delegate respondsToSelector:@selector(composeDisplayControllerDidEndSearch:)]) {
		[self.delegate composeDisplayControllerDidEndSearch:self];
	}
}

- (void)composeBar:(TURecipientsBar *)composeBar textDidChange:(NSString *)searchText
{
	if ([self.delegate respondsToSelector:@selector(composeBar:textDidChange:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBar:composeBar textDidChange:searchText];
	}
	
	if (composeBar.text.length > 0) {
		[self _showTableView];
		
		BOOL should = YES;
		if ([self.delegate respondsToSelector:@selector(composeDisplayController:shouldReloadTableForSearchString:)]) {
			should = [self.delegate composeDisplayController:self shouldReloadTableForSearchString:searchText];
		}
		
		if (should) {
			[_searchResultsTableView reloadData];
		}
	} else {
		[self _hideTableView];
	}
}

- (BOOL)composeBar:(TURecipientsBar *)composeBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(composeBar:shouldChangeTextInRange:replacementText:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate composeBar:composeBar shouldChangeTextInRange:range replacementText:text];
	}
	
	return should;
}

- (BOOL)composeBar:(TURecipientsBar *)composeBar shouldSelectRecipient:(TURecipient *)recipient
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(composeBar:shouldSelectRecipient:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate composeBar:composeBar shouldSelectRecipient:recipient];
	}
	
	if (should) {
		if (composeBar.text.length > 0) {
			[self _createRecipientForComposeBar:composeBar];
		}
	}
	
	return should;
}

- (void)composeBar:(TURecipientsBar *)composeBar didSelectRecipient:(TURecipient *)recipient
{
	if ([self.delegate respondsToSelector:@selector(composeBar:didSelectRecipient:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBar:composeBar didSelectRecipient:recipient];
	}
}

- (void)composeBarReturnButtonClicked:(TURecipientsBar *)composeBar
{
	if ([self.delegate respondsToSelector:@selector(composeBarReturnButtonClicked:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBarReturnButtonClicked:composeBar];
	}
	
	if (composeBar.text.length > 0) {
		[self _createRecipientForComposeBar:composeBar];
	}
}

- (void)composeBarAddButtonClicked:(TURecipientsBar *)composeBar
{
	if ([self.delegate respondsToSelector:@selector(composeBarAddButtonClicked:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate composeBarAddButtonClicked:composeBar];
	}
}

@end
