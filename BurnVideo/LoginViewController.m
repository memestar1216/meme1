//
//  LoginViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "LoginViewController.h"
#import "AddMediaViewController.h"

#import "AFNetworking.h"
#import "Common.h"
#import "Utils.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "User.h"

#import "AppDelegate.h"

@interface LoginViewController ()<UITextFieldDelegate>{
    CGRect keyboardRect;
    int clickIdentifier;
    CGSize result;
    
    // for avoid keyborad
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
}
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIView *viewForScroll;
@property (strong, nonatomic) IBOutlet UIView *viewForScrollSecond;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     result = [[UIScreen mainScreen] bounds].size;
    
    UIColor *color = [UIColor grayColor];
    self.text_emailAddress.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName:color}];
    self.text_password.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:color}];
    
    self.forgetPasswordView.hidden = TRUE;
    
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        [[NSBundle mainBundle] loadNibNamed:@"ForgotPassword" owner:self options:nil];
    }else{
        [[NSBundle mainBundle] loadNibNamed:@"ForgotPassword_iPad" owner:self options:nil];
    }
    self.imv_forgetbg.layer.cornerRadius = 5;
    
    [self addDoneButtonToKeyboard:self.text_emailAddress];
    [self addDoneButtonToKeyboard:self.text_password];
    [self addDoneButtonToKeyboard:self.text_forgetEmailAdd];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([SettingManager stringValueWithKey:SETTING_KEY_LOGINEMAIL]) {
        [self.btnRememberPW setSelected:true];
        self.text_emailAddress.text = [SettingManager stringValueWithKey:SETTING_KEY_LOGINEMAIL];
        self.text_password.text = [SettingManager stringValueWithKey:SETTING_KEY_LOGINPASSWORD];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.forgetPasswordView setFrame:self.view.bounds];
    [self.forgetPasswordView setHidden:true];
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

- (IBAction)btn_remembPass:(id)sender {
    if([sender isSelected]){
        [sender setSelected:NO];
    }
    else{
        [sender setSelected:YES];
    }
}

- (IBAction)btn_forgetPass:(id)sender {
   
  //  [self.forgetPasswordView setAlpha:1];
    
    //hide signButton
    self.signInButton.hidden = true;
    UIColor *color = [UIColor grayColor];
     self.text_forgetEmailAdd.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter Email Address" attributes:@{NSForegroundColorAttributeName:color}];
    NSString *htmlString = @"<center><font size=5><p> We will send you an email to</p><p>your registered email address to</p><p>reset your password</p></font></center>";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    
    UIColor *clr = [UIColor grayColor];
    
    self.text_emailAddress.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName:clr}];
    self.text_password.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Password" attributes:@{NSForegroundColorAttributeName:clr}];
    
    
    self.lbl_existingCstmr.textColor = [UIColor clearColor];
    
    self.textView_message.attributedText = attributedString;
    self.textView_message.textColor = [UIColor whiteColor];
    self.forgetPasswordView.hidden = false;
    [self.view addSubview:self.forgetPasswordView];
   
    clickIdentifier =1;
    
}

- (IBAction)btn_signIn:(id)sender {
    if (self.text_emailAddress.text.length == 0) {
        [Utils showAlertView:@"Signin" message:@"Please enter Email Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.text_password.text.length == 0) {
        [Utils showAlertView:@"Signin" message:@"Please enter Password" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }  
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSDictionary *dic = @{@"email":self.text_emailAddress.text
                          , @"password":self.text_password.text};
    
    [man POST:@"Signin" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                if (self.btnRememberPW.isSelected) {
                    [SettingManager setStringValue:self.text_emailAddress.text withKey:SETTING_KEY_LOGINEMAIL];
                    [SettingManager setStringValue:self.text_password.text withKey:SETTING_KEY_LOGINPASSWORD];
                }else{
                    [SettingManager removeObjectForKey:SETTING_KEY_LOGINEMAIL];
                }
                [SettingManager setStringValue:[dic objectForKey:@"token"] withKey:SETTING_KEY_TOKEN];
                [SettingManager setStringValue:[dic objectForKey:@"uid"] withKey:SETTING_KEY_UID];
                NSDictionary *user = [responseObject objectForKey:@"user"];
                AppDelegate *appD = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                
                if (user) {
                    User *userObj = [[User alloc] initWithDictionary:user];
                    [appD setUser:userObj];
                }
                [appD loadSelectedArray];                
                if ([SettingManager stringValueWithKey:SETTING_KEY_APNTOKEN]) {
                    AFHTTPRequestOperationManager *sendapnman = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
                    NSDictionary *apndic = @{@"token":[dic objectForKey:@"token"]
                                             , @"uid":[dic objectForKey:@"uid"]
                                             , @"code":[SettingManager stringValueWithKey:SETTING_KEY_APNTOKEN]};
                    
                    [sendapnman POST:@"SetAPNCode" parameters:apndic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"SetAPNCode: %@", responseObject);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"SetAPNCode: %@", error.localizedDescription);
                    }];
                }                [self performSegueWithIdentifier:@"showmain" sender:nil];
            }else{
                [Utils showAlertView:@"Signin fail!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }
        }else{
            [Utils showAlertView:@"Signin fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Signin fail!" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (IBAction)btn_done:(UIButton*)sender {    
    
    if (self.text_forgetEmailAdd.text.length == 0) {
        [Utils showAlertView:@"Forget Password" message:@"Please enter Email Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSDictionary *dic = @{@"email":self.text_forgetEmailAdd.text};
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [man POST:@"FindPassword" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [Utils showAlertView:@"Forget Password" message:@"Please check your email. We have sent you a temporary password." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
                    [self hideForgetPasswordView];
                }];
            }else{
                [Utils showAlertView:@"Forget Password" message:@"Current email has not registered." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
                }];
                return;
            }
        }else{
            [Utils showAlertView:@"Forget Password" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Forget Password" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
        }];
    }];
}

- (void) hideForgetPasswordView {
    self.forgetPasswordView.hidden = true;
    clickIdentifier =2;
    self.lbl_existingCstmr.textColor = [UIColor whiteColor];
    self.signInButton.hidden = false;
    [self checkKeyboardOpen];
}

- (IBAction)btn_cancel:(id)sender {
    self.forgetPasswordView.hidden = true;
    self.lbl_existingCstmr.textColor = [UIColor whiteColor];
    self.signInButton.hidden = false;
    [self checkKeyboardOpen];
}

-(void)checkKeyboardOpen{
    if([self.text_forgetEmailAdd isFirstResponder]){
        [self.text_forgetEmailAdd resignFirstResponder];
    }
}
- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
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
    
    if (self.forgetPasswordView.isHidden == false) {
        return;
    }
    
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
