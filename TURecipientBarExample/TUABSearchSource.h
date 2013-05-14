//
//  TUABSearchSource.h
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TURecipientBar.h"
#import <AddressBook/AddressBook.h>


@interface TUABSearchSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) IBOutlet TURecipientBar *composeBar;

@property (nonatomic, copy) NSString *searchTerm;

@property (nonatomic) ABAddressBookRef addressBook;

@end
