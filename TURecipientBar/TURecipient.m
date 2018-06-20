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

- (instancetype)initWithTitle:(NSString *)title address:(id)address
{
	self = [super init];
	if (self != nil) {
		self.recipientTitle = title;
		self.address = address;
	}
	
	return self;
}

+ (id)recipientWithTitle:(NSString *)title address:(id)address
{
	return [[TURecipient alloc] initWithTitle:title address:address];
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: title=%@, address=%@>", NSStringFromClass([self class]), self.recipientTitle, self.address];
}

@end
