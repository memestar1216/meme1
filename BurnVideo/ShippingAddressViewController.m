//
//  ShippingAddressViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "ShippingAddressViewController.h"
#import "AccountSummaryViewController.h"
#import "AddMediaViewController.h"

#import "LPlaceholderTextView.h"
#import "ShippingInformation.h"
#import "ActionSheetStringPicker.h"

#import "User.h"
#import "AppDelegate.h"

@interface ShippingAddressViewController () <UITextFieldDelegate , UITextViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
}
@property (strong, nonatomic) IBOutlet UITextField *textFirstName;
@property (strong, nonatomic) IBOutlet UITextField *textLastName;
@property (strong, nonatomic) IBOutlet UITextField *textZipCode;
@property (strong, nonatomic) IBOutlet UITextField *textCity;
@property (strong, nonatomic) IBOutlet LPlaceholderTextView *textStreetAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnState;

@end

@implementation ShippingAddressViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setColor];
    [self addDoneButtonToKeyboard:self.textFirstName];
    [self addDoneButtonToKeyboard:self.textLastName];
    [self addDoneButtonToKeyboard:self.textZipCode];
    [self addDoneButtonToKeyboard:self.textCity];
    [self addDoneButtonToKeyboardTextView:self.textStreetAddress];
    [self.textStreetAddress setPlaceholderColor:[UIColor grayColor]];
    
    self.textFirstName.delegate = self;
    self.textLastName.delegate = self;
    self.textCity.delegate = self;
    self.textZipCode.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationsObservers];
    topConstraint = topLayoutConstraint.constant;
    ShippingInformation *shipping = [[ShippingInformation alloc] init];
    AppDelegate *appd = (AppDelegate*)[UIApplication sharedApplication].delegate;
    User *user = appd.user;
    [shipping loadShippingInformation];
    if (shipping.firstName) {
        [self.textFirstName setText:shipping.firstName];
    }else{
        [self.textFirstName setText:user.firstName];
    }
    if (shipping.lastName) {
        [self.textLastName setText:shipping.lastName];
    }else{
        [self.textLastName setText:user.lastName];
    }
    if (shipping.streetAddress) {
        [self.textStreetAddress setText:shipping.streetAddress];
    }else{
        [self.textStreetAddress setText:user.streetAddress];
    }
    if (shipping.city) {
        [self.textCity setText:shipping.city];
    }else{
        [self.textCity setText:user.city];
    }
    if (shipping.zipcode) {
        [self.textZipCode setText:shipping.zipcode];
    }else{
        [self.textZipCode setText:user.zipcode];
    }
    if (shipping.state) {
        [self.btnState setTitle:shipping.state forState:UIControlStateNormal];
    }else{
        [self.btnState setTitle:user.state forState:UIControlStateNormal];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationsObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setColor{
    UIColor *clr = [UIColor grayColor];
    self.textCity.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"City" attributes:@{NSForegroundColorAttributeName:clr}];
    
    self.textFirstName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName:clr}];
    self.textLastName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName:clr}];
    
    self.textZipCode.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Zip Code" attributes:@{NSForegroundColorAttributeName:clr}];
    [self.btnState setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.textFirstName) {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.textLastName)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.textCity)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.textZipCode)
    {
        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterNoStyle];
        
        NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber * number = [nf numberFromString:newString];
        
        if (number){
            if (newString.length > 5) {
                return NO;
            }
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}

- (IBAction)btn_save:(id)sender {
    
    if ([self isValidate]) {
        ShippingInformation *shipping = [[ShippingInformation alloc] init];
        shipping.firstName = self.textFirstName.text;
        shipping.lastName = self.textLastName.text;
        shipping.city = self.textCity.text;
        shipping.zipcode = self.textZipCode.text;
        shipping.streetAddress = self.textStreetAddress.text;
        shipping.state = [self.btnState titleForState:UIControlStateNormal];
        [shipping save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL) isValidate{
    
    if (self.textFirstName.text.length == 0) {
        [Utils showAlertView:@"Save" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textFirstName.text.length < 2) {
        [Utils showAlertView:@"Save" message:@"Please enter valid First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textLastName.text.length == 0) {
        [Utils showAlertView:@"Save" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textLastName.text.length < 4) {
        [Utils showAlertView:@"Save" message:@"Please enter valid Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textStreetAddress.text.length == 0) {
        [Utils showAlertView:@"Save" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textStreetAddress.text.length < 8) {
        [Utils showAlertView:@"Save" message:@"Please enter valid Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textCity.text.length == 0) {
        [Utils showAlertView:@"Save" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textCity.text.length < 3) {
        [Utils showAlertView:@"Save" message:@"Please enter valid City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textZipCode.text.length == 0) {
        [Utils showAlertView:@"Save" message:@"Please enter Zip Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    if (self.textZipCode.text.length != 5) {
        [Utils showAlertView:@"Save" message:@"Please enter valid Zip Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return NO;
    }
    
    return YES;
}
- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)onState:(id)sender {
    NSArray *states = @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"];
    NSInteger index = [states indexOfObject:[self.btnState titleForState:UIControlStateNormal]];
    if (index == NSNotFound) {
        index = 0;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select state" rows:states initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.btnState setTitle:states[selectedIndex] forState:UIControlStateNormal];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}
//textfield delegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// avoid keyboard

- (void) addNotificationsObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeNotificationsObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#define MORE_HEIGHT 80

- (void) keyboardWillShow:(NSNotification*) notification {
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self.view];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    // Use this view's coordinate system
    CGRect keyboardBounds = [self.view convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGRect firstResponderFrame = [firstResponder convertRect:firstResponder.bounds toView:self.view];
    CGFloat textbottom = CGRectGetMaxY(firstResponderFrame);
    
    CGFloat currentDiff = topLayoutConstraint.constant - topConstraint;
    
    CGFloat diff = textbottom - keyboardBounds.origin.y + MORE_HEIGHT;
    
    diff = MAX(currentDiff, diff);
    
    if (diff == 0) {
        return;
    }
    
    // Shrink view's height by the keyboard's height, and scroll to show the text field/view being edited
    topLayoutConstraint.constant = topLayoutConstraint.constant - diff;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification*) notification {
    // Restore dimensions to prior size
    
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    topLayoutConstraint.constant = topConstraint;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void) addDoneButtonToKeyboard:(UITextField*) textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

- (void) addDoneButtonToKeyboardTextView:(UITextView*) textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *resultview = [self findFirstResponderBeneathView:childView];
        if (resultview) return resultview;
    }
    return nil;
}


@end
