//
//  SignUpViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "SignUpViewController.h"
#import "PaymentModeViewController.h"

#import "AFNetworking.h"
#import "Common.h"
#import "Utils.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "AppDelegate.h"
#import "ActionSheetStringPicker.h"



@interface SignUpViewController () <UITextFieldDelegate>
{
    // for avoid keyborad
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];

    [self setColor];
    [self addDoneButtonToKeyboard:self.txtName];
    [self addDoneButtonToKeyboard:self.txtEmail];
    [self addDoneButtonToKeyboard:self.txtVerifyEmail];
    [self addDoneButtonToKeyboard:self.txtPassword];
    [self addDoneButtonToKeyboard:self.txtVerifyPass];
    [self addDoneButtonToKeyboard:self.txtStreetAddress];
    [self addDoneButtonToKeyboard:self.txtCity];
    [self addDoneButtonToKeyboard:self.txtZipCode];
    [self addDoneButtonToKeyboard:self.txtState];
    [self addDoneButtonToKeyboard:self.txtLastName];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationsObservers];
    topConstraint = topLayoutConstraint.constant;
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
    UIColor *color = [UIColor grayColor];
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtLastName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtCity.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"City" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtEmail.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtVerifyEmail.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Verify Email Address" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:color}];
    
    self.txtState.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"State" attributes:@{NSForegroundColorAttributeName:color}];
    
    self.txtStreetAddress.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Street Address" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtVerifyPass.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Verify Password" attributes:@{NSForegroundColorAttributeName:color}];
    self.txtZipCode.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Zip Code" attributes:@{NSForegroundColorAttributeName:color}];
}

- (IBAction)onState:(id)sender {
    NSArray *states = @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"];
    NSInteger index = [states indexOfObject:self.txtState.text];
    if (index == NSNotFound) {
        index = 0;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select state" rows:states initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.txtState.text = states[selectedIndex];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.txtName) {
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
    else if (textField == self.txtLastName)
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
    else if (textField == self.txtCity)
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
    else if (textField == self.txtZipCode)
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

- (IBAction)btn_nextClicked:(id)sender {
    
    if (self.txtName.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtName.text.length < 2) {
        [Utils showAlertView:@"Signup" message:@"Please enter valid First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtLastName.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtLastName.text.length < 4) {
        [Utils showAlertView:@"Signup" message:@"Please enter valid Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtEmail.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Email Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtVerifyEmail.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Verify Email Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (![self.txtEmail.text isEqualToString:self.txtVerifyEmail.text]) {
        [Utils showAlertView:@"Signup" message:@"Email Address and Verify Email Address is different. Please enter again." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtPassword.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Password" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtPassword.text.length < 8) {
        [Utils showAlertView:@"Signup" message:@"Password must be 8 characters long." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtVerifyPass.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Verify Password" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (![self.txtPassword.text isEqualToString:self.txtVerifyPass.text]) {
        [Utils showAlertView:@"Signup" message:@"Password and Verify Password is different. Please enter again." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtStreetAddress.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtStreetAddress.text.length < 8) {
        [Utils showAlertView:@"Signup" message:@"Please enter valid Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtState.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter State" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtCity.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtCity.text.length < 3) {
        [Utils showAlertView:@"Signup" message:@"Please enter valid City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtZipCode.text.length == 0) {
        [Utils showAlertView:@"Signup" message:@"Please enter Zip Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.txtZipCode.text.length != 5) {
        [Utils showAlertView:@"Signup" message:@"Please enter valid Zip Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    
    
    
    
//    NSString *firstname = [self.txtName
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];

    NSDictionary *dic = @{@"first_name":self.txtName.text
                          , @"last_name":self.txtLastName.text
                          , @"email":self.txtEmail.text
                          , @"password":self.txtPassword.text
                          , @"street":self.txtStreetAddress.text
                          , @"city":self.txtCity.text
                          , @"state":self.txtState.text
                          , @"zipcode":self.txtZipCode.text};
    
    [man POST:@"Signup" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [SVProgressHUD dismiss];
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [SettingManager setStringValue:[dic objectForKey:@"token"] withKey:SETTING_KEY_TOKEN];
                [SettingManager setStringValue:[dic objectForKey:@"uid"] withKey:SETTING_KEY_UID];
                NSDictionary *user = [responseObject objectForKey:@"user"];
                AppDelegate *appD = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                
                if (user) {
                    User *userObj = [[User alloc] initWithDictionary:user];
                    [appD setUser:userObj];
                }
                [appD loadSelectedArray];
                AFHTTPRequestOperationManager *sendapnman = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
                NSString *apnToken = [SettingManager stringValueWithKey:SETTING_KEY_APNTOKEN];
                NSDictionary *apndic = @{@"token":[dic objectForKey:@"token"]
                                         , @"uid":[dic objectForKey:@"uid"]
                                         , @"code":(apnToken?apnToken:@"")};
                if (apnToken) {
                    [sendapnman POST:@"SetAPNCode" parameters:apndic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"SetAPNCode: %@", responseObject);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"SetAPNCode: %@", error.localizedDescription);
                    }];
                }                
                [self performSegueWithIdentifier:@"addPayment" sender:nil];
            }else if (retCode == -101) {
                [Utils showAlertView:@"Signup fail!" message:@"UserName is duplicated. Please enter other name." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }else if (retCode == -102) {
                [Utils showAlertView:@"Signup fail!" message:@"Email is already registered. Please enter other email address." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }else{
                [Utils showAlertView:@"Signup fail!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }
        }else{
            [SVProgressHUD dismiss];
            [Utils showAlertView:@"Signup fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Signup fail!" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (void) gotoAlbum {
    [self performSegueWithIdentifier:@"gotoAlbum" sender:self];
}

- (IBAction)btn_back:(id)sender {    
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.txtName) {
        [self.txtLastName becomeFirstResponder];
    }else if (textField == self.txtLastName) {
        [self.txtEmail becomeFirstResponder];
    }else if (textField == self.txtEmail) {
        [self.txtVerifyEmail becomeFirstResponder];
    }else if (textField == self.txtVerifyEmail) {
        [self.txtPassword becomeFirstResponder];
    }else if (textField == self.txtPassword) {
        [self.txtVerifyPass becomeFirstResponder];
    }else if (textField == self.txtVerifyPass) {
        [self.txtStreetAddress becomeFirstResponder];
    }else if (textField == self.txtStreetAddress) {
        [self.txtCity becomeFirstResponder];
    }else if (textField == self.txtCity) {
        [self.txtZipCode becomeFirstResponder];
    }else if (textField == self.txtZipCode) {
        [self.txtZipCode resignFirstResponder];
    }
    return YES;
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self.navigationController popViewControllerAnimated:YES];        
    }else{
        @try {
            [self performSegueWithIdentifier:@"next" sender:nil];
        }
        @catch (NSException *exception) {
            
        }
    }
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
