//
//  TURecipientsDisplayController.m
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

- (void)setRecipientsBar:(TURecipientsBar *)recipientsBar
{
	_recipientsBar = recipientsBar;
	
	_recipientsBar.recipientsBarDelegate = self;
}

- (UITableView *)searchResultsTableView
{
	if (_searchResultsTableView == nil) {
		_searchResultsTableView = [[UITableView alloc] initWithFrame:self.contentsController.view.bounds style:UITableViewStylePlain];
		_searchResultsTableView.dataSource = self.searchResultsDataSource;
		_searchResultsTableView.delegate = self.searchResultsDelegate;
		_searchResultsTableView.translatesAutoresizingMaskIntoConstraints = NO;
		_searchResultsTableView.backgroundColor = [UIColor colorWithWhite:0.925 alpha:1.000];
		
		if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:didLoadSearchResultsTableView:)]) {
			[self.delegate recipientsDisplayController:self didLoadSearchResultsTableView:_searchResultsTableView];
		}
	}
	
	return _searchResultsTableView;
}

- (void)_unloadTableView
{
	if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:willUnloadSearchResultsTableView:)]) {
		[self.delegate recipientsDisplayController:self willUnloadSearchResultsTableView:_searchResultsTableView];
	}
	
	_searchResultsTableView = nil;
}

- (void)_showTableView
{
	if (!self.recipientsBar.searching) {
        if (_shouldBeginSearch) {
            UITableView *tableView = self.searchResultsTableView;
            
            if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:willShowSearchResultsTableView:)]) {
                [self.delegate recipientsDisplayController:self willShowSearchResultsTableView:tableView];
            }
            
            [self.contentsController.view addSubview:tableView];
            [self.contentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
            [self.contentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_recipientsBar][tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_recipientsBar, tableView)]];
            
            [self.contentsController.view layoutIfNeeded];
            
            
            tableView.alpha = 0.0;
            [UIView animateWithDuration:0.2 animations:^{
                //we don't want this to start from it's current location
                tableView.alpha = 1.0;
            }];
            
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.recipientsBar setSearching:YES animated:NO];
                
                [self.recipientsBar.superview bringSubviewToFront:self.recipientsBar];
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:didShowSearchResultsTableView:)]) {
                    [self.delegate recipientsDisplayController:self didShowSearchResultsTableView:tableView];
                }
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.recipientsBar setSearching:YES animated:NO];
                
                [self.recipientsBar.superview bringSubviewToFront:self.recipientsBar];
            } completion:nil];
        }
	}
}

- (void)_hideTableView
{
	if (self.recipientsBar.searching) {
		UITableView *tableView = self.searchResultsTableView;
		
		if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:willHideSearchResultsTableView:)]) {
			[self.delegate recipientsDisplayController:self willHideSearchResultsTableView:tableView];
		}
		
		[self.contentsController.view layoutIfNeeded];
		
		
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
			[self.recipientsBar setSearching:NO animated:NO];
			
			tableView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[tableView removeFromSuperview];
			
			if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:didHideSearchResultsTableView:)]) {
				[self.delegate recipientsDisplayController:self didHideSearchResultsTableView:tableView];
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
	self = [self initWithRecipientsBar:nil contentsController:nil];
	if (self != nil) {
		
	}
	
	return self;
}

- (id)initWithRecipientsBar:(TURecipientsBar *)recipientsBar contentsController:(UIViewController *)viewController
{
	self = [super init];
	if (self != nil) {
		_recipientsBar = recipientsBar;
		_recipientsBar.recipientsBarDelegate = self;
		_contentsController = viewController;
		
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


#pragma mark - TURecipientsBarDelegate

- (void)_createRecipientForRecipientsBar:(TURecipientsBar *)recipientsBar
{
	TURecipient *recipient = [TURecipient recipientWithTitle:recipientsBar.text address:nil];
	
	if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:willAddRecipient:)]) {
		recipient = [self.delegate recipientsDisplayController:self willAddRecipient:recipient];
	}
	
	if (recipient != nil) {
		[_recipientsBar addRecipient:recipient];
		recipientsBar.text = nil;
		
		if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:didAddRecipient:)]) {
			[self.delegate recipientsDisplayController:self didAddRecipient:recipient];
		}
	}
}

- (BOOL)recipientsBarShouldBeginEditing:(TURecipientsBar *)recipientsBar
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(recipientsBarShouldBeginEditing:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate recipientsBarShouldBeginEditing:recipientsBar];
	}
	
	if (should) {
        _shouldBeginSearch = YES;
        
        if ([self.delegate respondsToSelector:@selector(recipientsDisplayControllerShouldBeginSearch:)]) {
            _shouldBeginSearch = [self.delegate recipientsDisplayControllerShouldBeginSearch:self];
        }
        
		if (_shouldBeginSearch && [self.delegate respondsToSelector:@selector(recipientsDisplayControllerWillBeginSearch:)]) {
			[self.delegate recipientsDisplayControllerWillBeginSearch:self];
		}
	}
	
	return should;
}

- (void)recipientsBarTextDidBeginEditing:(TURecipientsBar *)recipientsBar
{
	if ([self.delegate respondsToSelector:@selector(recipientsBarTextDidBeginEditing:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBarTextDidBeginEditing:recipientsBar];
	}
	
	if (_shouldBeginSearch && [self.delegate respondsToSelector:@selector(recipientsDisplayControllerDidBeginSearch:)]) {
		[self.delegate recipientsDisplayControllerDidBeginSearch:self];
	}
}

- (BOOL)recipientsBarShouldEndEditing:(TURecipientsBar *)recipientsBar
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(recipientsBarShouldEndEditing:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate recipientsBarShouldEndEditing:recipientsBar];
	}

	if (should) {
		if ([self.delegate respondsToSelector:@selector(recipientsDisplayControllerWillEndSearch:)]) {
			[self.delegate recipientsDisplayControllerWillEndSearch:self];
		}
		
		if (recipientsBar.text.length > 0) {
			[self _createRecipientForRecipientsBar:recipientsBar];
		}
	}
	
	return should;
}

- (void)recipientsBarTextDidEndEditing:(TURecipientsBar *)recipientsBar
{
	if ([self.delegate respondsToSelector:@selector(recipientsBarTextDidEndEditing:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBarTextDidEndEditing:recipientsBar];
	}
	
	if ([self.delegate respondsToSelector:@selector(recipientsDisplayControllerDidEndSearch:)]) {
		[self.delegate recipientsDisplayControllerDidEndSearch:self];
	}
}

- (void)recipientsBar:(TURecipientsBar *)recipientsBar textDidChange:(NSString *)searchText
{
	if ([self.delegate respondsToSelector:@selector(recipientsBar:textDidChange:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBar:recipientsBar textDidChange:searchText];
	}
	
	if (recipientsBar.text.length > 0) {
		[self _showTableView];
		
		BOOL should = YES;
		if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:shouldReloadTableForSearchString:)]) {
			should = [self.delegate recipientsDisplayController:self shouldReloadTableForSearchString:searchText];
		}
		
		if (should) {
			[_searchResultsTableView reloadData];
		}
	} else {
		[self _hideTableView];
	}
}

- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(recipientsBar:shouldChangeTextInRange:replacementText:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate recipientsBar:recipientsBar shouldChangeTextInRange:range replacementText:text];
	}
	
	return should;
}

- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldSelectRecipient:(TURecipient *)recipient
{
	BOOL should = YES;
	if ([self.delegate respondsToSelector:@selector(recipientsBar:shouldSelectRecipient:)]) {
		should = [(id<TURecipientsBarDelegate>)self.delegate recipientsBar:recipientsBar shouldSelectRecipient:recipient];
	}
	
	if (should) {
		if (recipientsBar.text.length > 0) {
			[self _createRecipientForRecipientsBar:recipientsBar];
		}
	}
	
	return should;
}

- (void)recipientsBar:(TURecipientsBar *)recipientsBar didSelectRecipient:(TURecipient *)recipient
{
	if ([self.delegate respondsToSelector:@selector(recipientsBar:didSelectRecipient:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBar:recipientsBar didSelectRecipient:recipient];
	}
}

- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar
{
	if ([self.delegate respondsToSelector:@selector(recipientsBarReturnButtonClicked:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBarReturnButtonClicked:recipientsBar];
	}
	
	if (recipientsBar.text.length > 0) {
		[self _createRecipientForRecipientsBar:recipientsBar];
	}
}

- (void)recipientsBarAddButtonClicked:(TURecipientsBar *)recipientsBar
{
	if ([self.delegate respondsToSelector:@selector(recipientsBarAddButtonClicked:)]) {
		[(id<TURecipientsBarDelegate>)self.delegate recipientsBarAddButtonClicked:recipientsBar];
	}
}

@end
