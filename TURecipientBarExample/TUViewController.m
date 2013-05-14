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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TSComposeDisplayDelegate

- (void)composeBarReturnButtonClicked:(TURecipientBar *)composeBar
{
	if (composeBar.text.length == 0) {
		[composeBar resignFirstResponder];
	}
}

- (void)composeDisplayController:(TURecipientDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
	self.searchSource.tableView = tableView;
}

- (BOOL)composeDisplayController:(TURecipientDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	self.searchSource.searchTerm = searchString;
	
	return YES;
}

@end
