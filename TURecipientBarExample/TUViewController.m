//
//  TUViewController.m
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import "TUViewController.h"

#import "TUABSearchSource.h"


@interface TUViewController ()

@end

@implementation TUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.recipientsBar.showsAddButton = NO;
//    self.recipientsBar.placeholder = NSLocalizedString(@"Type names...", nil);
//    self.recipientsBar.label = @"To:";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TSComposeDisplayDelegate

- (void)composeBarReturnButtonClicked:(TURecipientsBar *)composeBar
{
	if (composeBar.text.length == 0) {
		[composeBar resignFirstResponder];
	}
}

- (void)composeDisplayController:(TURecipientsDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	self.searchSource.tableView = tableView;
}

- (BOOL)composeDisplayController:(TURecipientsDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	self.searchSource.searchTerm = searchString;
	
	return YES;
}

/*
 Uncomment to disable the search table view.
 The shouldReloadTableForSearchString method and other text change methods will still be called, so you can provide your own search UI
- (BOOL)composeDisplayControllerShouldBeginSearch:(TURecipientDisplayController *)controller
{
    return NO;
}
 */

@end
