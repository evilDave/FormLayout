//
//  ViewController.m
//  FormLayout
//
//  Created by David Clark on 16/02/2016.
//  Copyright (c) 2016 David Clark. All rights reserved.
//

#import "ViewController.h"
#import "UIBarButtonItem+DC.h"
#import "CustomTextField.h"

@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController {
    UIScrollView *_scrollView;
    UIView *_contentView;
    UITextField *_editingTextField;
    NSLayoutConstraint *_scrollViewBottomAnchor;
    NSMutableSet *_scrollToTopTextFields;
    UIToolbar *_nextPrevAccessoryView;
    int _maxTag;
	UIVisualEffectView *_contentViewBlurEffectView;
	UIView *_placeholderView;
    NSMutableSet *_blurOnFocusTextFields;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scrollToTopTextFields = [[NSMutableSet alloc] init];
        _blurOnFocusTextFields = [[NSMutableSet alloc] init];
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
    _scrollViewBottomAnchor = [_scrollView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor];
    _scrollViewBottomAnchor.active = YES;
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

    _nextPrevAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)]; // this sucks, no autolayout with UIBarButtonItem
    [_nextPrevAccessoryView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_nextPrevAccessoryView setItems:@[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(prevTextField)],
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil].withWidth(10),
            [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextTextField)] ]];

    UITextField *textField = nil;
    for (int i = 0; i < 25; ++i) {
        if(i == 3 || i == 10 || i == 12) {
            textField = [self addCustomTextFieldWithText:[NSString stringWithFormat:@"testing%02i", i] toView:_contentView belowView:textField scrollToTop:(i % 5 == 0)];
        }
        else {
            textField = [self addTextFieldWithText:[NSString stringWithFormat:@"testing%02i", i] toView:_contentView belowView:textField scrollToTop:(i % 5 == 0)];
        }
        [textField setTag:i+1];
        _maxTag = i+1;
    }

    [_contentView.bottomAnchor constraintEqualToAnchor:textField.bottomAnchor].active = YES;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _contentViewBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [_contentViewBlurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_contentViewBlurEffectView setHidden:YES];
    [_contentViewBlurEffectView setAlpha:0.8];
    [_contentView addSubview:_contentViewBlurEffectView];
    [_contentViewBlurEffectView.topAnchor constraintEqualToAnchor:_contentView.topAnchor].active = YES;
    [_contentViewBlurEffectView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor].active = YES;
    [_contentViewBlurEffectView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor].active = YES;
    [_contentViewBlurEffectView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor].active = YES;
    // TODO: needs another view over the top to click on to dismiss
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [_contentViewBlurEffectView addGestureRecognizer:tapGestureRecognizer];

    _placeholderView = [[UIView alloc] init];
    [_contentView addSubview:_placeholderView];
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
    [self setupTextField:textField withText:text toView:containerView belowView:belowView scrollToTop:scrollToTop showAccessory:YES];
    return textField;
}

- (void)setupTextField:(UITextField *)textField withText:(NSString *)text toView:(UIView *)containerView belowView:(UITextField *)belowView scrollToTop:(BOOL)scrollToTop showAccessory:(BOOL)showAccessory {
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue" size:scrollToTop ? 42 : 22]];
    [textField.layer setCornerRadius:5];
    [textField.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [textField.layer setBorderWidth:0.5];
    [textField setText:text];
    [textField setBackgroundColor:[UIColor whiteColor]];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setDelegate:self];
    if(showAccessory) {
        [textField setInputAccessoryView:_nextPrevAccessoryView];
    }
    [containerView addSubview:textField];
    [textField.topAnchor constraintEqualToAnchor:belowView ? belowView.bottomAnchor : containerView.topAnchor constant:belowView ? 20 : 50].active = YES;
    [textField.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:50].active = YES;
    [textField.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-50].active = YES;
    if(scrollToTop) {
        [_scrollToTopTextFields addObject:textField];
    }
}

- (UITextField *)addCustomTextFieldWithText:(NSString *)text toView:(UIView *)containerView belowView:(UITextField *)belowView scrollToTop:(BOOL)scrollToTop {
    UITextField *textField = [[CustomTextField alloc] init];
    [_blurOnFocusTextFields addObject:textField];
    [self setupTextField:textField withText:text toView:containerView belowView:belowView scrollToTop:scrollToTop showAccessory:NO];
    [textField.layer setBorderColor:[[UIColor redColor] CGColor]];
    return textField;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _editingTextField = textField;

    if([_blurOnFocusTextFields containsObject:_editingTextField]) {
        [_scrollView setBounces:NO];
        [_contentViewBlurEffectView setHidden:NO];
        [_contentView exchangeSubviewAtIndex:[_contentView.subviews indexOfObject:_editingTextField] withSubviewAtIndex:[_contentView.subviews indexOfObject:_placeholderView]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([_blurOnFocusTextFields containsObject:_editingTextField]) {
        [_scrollView setBounces:YES];
        [_contentViewBlurEffectView setHidden:YES];
        [_contentView exchangeSubviewAtIndex:[_contentView.subviews indexOfObject:_editingTextField] withSubviewAtIndex:[_contentView.subviews indexOfObject:_placeholderView]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [_scrollViewBottomAnchor setConstant:-rect.size.height];

    if([_scrollToTopTextFields containsObject:_editingTextField]) {
        CGPoint point = CGPointMake(_scrollView.contentOffset.x, _editingTextField.frame.origin.y);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_scrollView setContentOffset:point animated:YES];
        });
    }

    [self.view layoutSubviews]; // prevent delay in scrolling
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_scrollViewBottomAnchor setConstant:0];
}

- (void)prevTextField {
    int nextTag = _editingTextField.tag - 1;
    if(nextTag < 1) {
        nextTag = _maxTag;
    }
    [[self.view viewWithTag:nextTag] becomeFirstResponder];
}

- (void)nextTextField {
    int nextTag = _editingTextField.tag + 1;
    if(nextTag > _maxTag) {
        nextTag = 1;
    }
    [[self.view viewWithTag:nextTag] becomeFirstResponder];
}

- (void)endEditing {
    [self.view endEditing:NO];
}

@end
