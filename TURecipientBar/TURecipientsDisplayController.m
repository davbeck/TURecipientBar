//
//  TURecipientsDisplayController.m
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipientsDisplayController.h"

#import <QuartzCore/QuartzCore.h>


static void *TURecipientsContext = &TURecipientsContext;


@implementation TURecipientsDisplayController
{
    BOOL _shouldBeginSearch;
    CGRect _keyboardFrame;
}

@synthesize searchResultsTableView = _searchResultsTableView;

#pragma mark - Properties

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
        
        [self _updateTableViewInsets];
		
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
	if (_searchResultsTableView.superview == nil) {
        if (_shouldBeginSearch) {
            UITableView *tableView = self.searchResultsTableView;
            
            if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:willShowSearchResultsTableView:)]) {
                [self.delegate recipientsDisplayController:self willShowSearchResultsTableView:tableView];
            }
            
            
            if ([self.delegate respondsToSelector:@selector(recipientsDisplayController:displaySearchResultsTableView:)]) {
                [self.delegate recipientsDisplayController:self displaySearchResultsTableView:tableView];
            } else {
                [self.contentsController.view addSubview:tableView];
                [self.contentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
                [self.contentsController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_recipientsBar, tableView)]];
                
                [self.contentsController.view layoutIfNeeded];
            }
            
            
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
    
    [self _updateTableViewInsets];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == TURecipientsContext) {
        if ([change[NSKeyValueChangeOldKey] isKindOfClass:[NSArray class]] && [self.delegate respondsToSelector:@selector(recipientsDisplayController:didRemoveRecipient:)]) {
            for (id<TURecipient>recipient in change[NSKeyValueChangeOldKey]) {
                [self.delegate recipientsDisplayController:self didRemoveRecipient:recipient];
            }
        }
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    
    [self removeObserver:self forKeyPath:@"recipientsBar.recipients" context:TURecipientsContext];
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
        if ([viewController conformsToProtocol:@protocol(UITableViewDataSource)]) {
            _searchResultsDataSource = (id<UITableViewDataSource>)viewController;
        }
        if ([viewController conformsToProtocol:@protocol(UITableViewDelegate)]) {
            _searchResultsDelegate = (id<UITableViewDelegate>)viewController;
        }
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [self addObserver:self forKeyPath:@"recipientsBar.recipients" options:NSKeyValueObservingOptionOld context:TURecipientsContext];
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

- (void)keyboardWillShow:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    _keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self _updateTableViewInsets];
    
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    _keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self _updateTableViewInsets];
    
    [UIView commitAnimations];
}

- (void)_updateTableViewInsets
{
    if (_searchResultsTableView != nil) {
        CGRect keyboardFrameInView = [self.searchResultsTableView.superview convertRect:_keyboardFrame fromView:nil];
        CGFloat bottomInset = CGRectGetMaxY(self.searchResultsTableView.frame) - keyboardFrameInView.origin.y;
        
        UIEdgeInsets contentInset = self.searchResultsTableView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.searchResultsTableView.scrollIndicatorInsets;
        
        if (!CGRectIsEmpty(_keyboardFrame)) {
            contentInset.bottom = bottomInset;
            scrollIndicatorInsets.bottom = contentInset.bottom;
        }
        
        if (![self.delegate respondsToSelector:@selector(recipientsDisplayController:displaySearchResultsTableView:)]) {
            contentInset.top = CGRectGetMaxY(self.recipientsBar.frame);
            scrollIndicatorInsets.top = contentInset.top;
        }
        
        self.searchResultsTableView.contentInset = contentInset;
        self.searchResultsTableView.scrollIndicatorInsets = scrollIndicatorInsets;
    }
}


#pragma mark - TURecipientsBarDelegate

- (void)_createRecipientForRecipientsBar:(TURecipientsBar *)recipientsBar
{
	id<TURecipient> recipient = [TURecipient recipientWithTitle:recipientsBar.text address:recipientsBar.text];
	
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
    
    if (recipientsBar.text.length > 0) {
		[self _showTableView];
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
    
    [self _hideTableView];
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

- (BOOL)recipientsBar:(TURecipientsBar *)recipientsBar shouldSelectRecipient:(id<TURecipient>)recipient
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

- (void)recipientsBar:(TURecipientsBar *)recipientsBar didSelectRecipient:(id<TURecipient>)recipient
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
