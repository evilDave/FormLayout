//
// Created by David Clark on 17/02/2016.
// Copyright (c) 2016 David Clark. All rights reserved.
//

#import "CustomTextField.h"


@implementation CustomTextField {

}

- (BOOL)becomeFirstResponder {
	BOOL returnValue = [super becomeFirstResponder];
	if(returnValue) {
		[self invalidateIntrinsicContentSize];
		[self setNeedsDisplay];
	}
	return returnValue;
}

- (BOOL)resignFirstResponder {
	BOOL returnValue = [super resignFirstResponder];
	if(returnValue) {
		[self invalidateIntrinsicContentSize];
		[self setNeedsDisplay];
	}
	return returnValue;
}

- (CGSize)intrinsicContentSize {
	CGSize superSize = [super intrinsicContentSize];
	return [self isFirstResponder] ? CGSizeMake(superSize.width, superSize.height * 5) : superSize;
}

@end
