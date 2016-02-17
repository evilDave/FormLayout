//
// Created by David Clark on 17/02/2016.
// Copyright (c) 2016 David Clark. All rights reserved.
//

#import "UIBarButtonItem+DC.h"


@implementation UIBarButtonItem (DC)

- (UIBarButtonItem *(^)(int width))withWidth {
	return ^(int width) {
		[self setWidth:width];
		return self;
	};
}

@end
