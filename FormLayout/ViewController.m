//
//  ViewController.m
//  FormLayout
//
//  Created by David Clark on 16/02/2016.
//  Copyright (c) 2016 David Clark. All rights reserved.
//


#import "ViewController.h"


@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController {
    UIScrollView *_scrollView;
    UIView *_contentView;
    NSLayoutConstraint *_ScrollViewBottomAnchor;
    NSMutableSet *_scrollToTopTextFields;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scrollToTopTextFields = [[NSMutableSet alloc] init];
    }

    return self;
}


- (void)loadView {
    UIView *view = [[UIView alloc] init];
    [self setView:view];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imageView];
    [imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;

    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_scrollView];
    [_scrollView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    _ScrollViewBottomAnchor = [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor];
    _ScrollViewBottomAnchor.active = YES;
    [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    _contentView = [[UIView alloc] init];
    [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:_contentView];
    [_contentView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor].active = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor].active = YES;
    [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor].active = YES;
    [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor].active = YES;

    [_contentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;

    UITextField *textField = nil;
    for (int i = 0; i < 15; ++i) {
        textField = [self addTextFieldWithText:[NSString stringWithFormat:@"testing%02i", i] toView:_contentView belowView:textField scrollToTop:(i%5==0)];
    }

    [_contentView.bottomAnchor constraintEqualToAnchor:textField.bottomAnchor].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITextField *)addTextFieldWithText:(NSString *)text toView:(UIView *)containerView belowView:(UITextField *)belowView scrollToTop:(BOOL)scrollToTop {
    UITextField *textField = [[UITextField alloc] init];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:scrollToTop ? 42 : 22]];
    [textField.layer setCornerRadius:5];
    [textField.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [textField.layer setBorderWidth:0.5];
    [textField setText:text];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setDelegate:self];
    [containerView addSubview:textField];
    [textField.topAnchor constraintEqualToAnchor:belowView ? belowView.bottomAnchor : containerView.topAnchor constant:belowView ? 20 : 50].active = YES;
    [textField.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:50].active = YES;
    [textField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-50].active = YES;
    if(scrollToTop) {
        [_scrollToTopTextFields addObject:textField];
    }
    return textField;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([_scrollToTopTextFields containsObject:textField]) {
        CGPoint point = CGPointMake(_scrollView.contentOffset.x, textField.frame.origin.y);
        [_scrollView setContentOffset:point animated:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [_ScrollViewBottomAnchor setConstant:-rect.size.height];
    [self.view layoutIfNeeded]; // prevent delay in scrolling
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_ScrollViewBottomAnchor setConstant:0];
}

@end
