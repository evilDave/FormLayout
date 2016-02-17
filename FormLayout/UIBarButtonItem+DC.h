//
// Created by David Clark on 17/02/2016.
// Copyright (c) 2016 David Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface UIBarButtonItem (DC)

@property (readonly) UIBarButtonItem *(^withWidth)(int width);

@end
