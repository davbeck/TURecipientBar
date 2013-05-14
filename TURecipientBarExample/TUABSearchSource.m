//
//  TUABSearchSource.m
//  TURecipientBar
//
//  Created by David Beck on 5/14/13.
//  Copyright (c) 2013 ThinkUltimate. All rights reserved.
//

#import "TUABSearchSource.h"


@implementation TUABSearchSource
{
    NSArray *_people;
}

- (void)dealloc
{
    self.addressBook = nil;
}

- (void)setAddressBook:(ABAddressBookRef)addressBook
{
    if (addressBook != _addressBook) {
        if (_addressBook != NULL) {
            CFRelease(_addressBook);
        }
        
        if (addressBook != nil) {
            _addressBook = CFRetain(addressBook);
        } else {
            _addressBook = nil;
        }
    }
    
    
    self.searchTerm = self.searchTerm;
}

- (void)setSearchTerm:(NSString *)searchTerm
{
	_searchTerm = searchTerm;
    
    _people = CFBridgingRelease(ABAddressBookCopyPeopleWithName(self.addressBook, (__bridge CFStringRef)(_searchTerm)));
}

- (id)init
{
    self = [super init];
    if (self) {
        self.addressBook = ABAddressBookCreateWithOptions(nil, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                self.searchTerm = self.searchTerm;
            });
        }
    }
	
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _people.count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	ABRecordRef person = (__bridge ABRecordRef)([_people objectAtIndex:indexPath.row]);
    
	cell.textLabel.text = CFBridgingRelease(ABRecordCopyCompositeName(person));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reuseIdentifier = @"SearchCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ABRecordRef person = (__bridge ABRecordRef)([_people objectAtIndex:indexPath.row]);
    
	[self.composeBar addRecipient:[TURecipient recipientWithTitle:CFBridgingRelease(ABRecordCopyCompositeName(person))
                                                          address:(__bridge id)(person)]];
	self.composeBar.text = nil;
}

@end
