//
//  TURecipient.m
//  ThinkSocial
//
//  Created by David Beck on 10/24/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//

#import "TURecipient.h"

@interface TURecipient ()

@property (nonatomic, readwrite, copy) NSString *recipientTitle;
@property (nonatomic, readwrite, strong) id address;

@end

@implementation TURecipient

- (NSString *)title
{
    return self.recipientTitle;
}

+ (id)recipientWithTitle:(NSString *)title address:(id)address
{
	TURecipient *recipient = [[TURecipient alloc] init];
	
	recipient.recipientTitle = title;
	recipient.address = address;
	
	return recipient;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: title=%@, address=%@>", NSStringFromClass([self class]), self.recipientTitle, self.address];
}

- (BOOL)isValid
{
	NSString *emailAddress;
	if (self.address && [self.address isKindOfClass:[NSString class]]) {
		emailAddress = self.address;
	} else {
		emailAddress = self.recipientTitle;
	}
	
	NSString* regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:emailAddress];
}

@end
