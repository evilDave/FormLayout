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
    UITextField *_editingTextField;
    NSLayoutConstraint *_ScrollViewBottomAnchor;
}

- (void)loadView {
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor orangeColor]];
    [self setView:view];

    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_scrollView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_scrollView];
    [_scrollView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
    _ScrollViewBottomAnchor = [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor];
    _ScrollViewBottomAnchor.active = YES;
    [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;

    _contentView = [[UIView alloc] init];
    [_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_contentView setBackgroundColor:[UIColor blueColor]];
    [_scrollView addSubview:_contentView];
    [_contentView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor].active = YES;
    [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor].active = YES;
    [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor].active = YES;
    [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor].active = YES;

    [_contentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;

    UITextField *textField = nil;
    for (int i = 0; i < 50; ++i) {
        textField = [self addTextFieldWithText:[NSString stringWithFormat:@"testing%02i", i] toView:_contentView belowView:textField];
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

- (UITextField *)addTextFieldWithText:(NSString *)text toView:(UIView *)containerView belowView:(UITextField *)belowView {
    UITextField *textField = [[UITextField alloc] init];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField setText:text];
    [textField setBackgroundColor:[UIColor greenColor]];
    [textField setDelegate:self];
    [containerView addSubview:textField];
    [textField.topAnchor constraintEqualToAnchor:belowView ? belowView.bottomAnchor : containerView.topAnchor constant:belowView ? 2 : 0].active = YES;
    [textField.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor].active = YES;
    [textField.widthAnchor constraintEqualToAnchor:containerView.widthAnchor].active = YES;
    return textField;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _editingTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _editingTextField = nil;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [_ScrollViewBottomAnchor setConstant:-rect.size.height];
    [self.view layoutIfNeeded];

    [_scrollView scrollRectToVisible:_editingTextField.frame animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_ScrollViewBottomAnchor setConstant:0];
}

@end