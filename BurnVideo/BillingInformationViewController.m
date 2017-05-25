//
//  BillingInformationViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "BillingInformationViewController.h"
#import "AccountSummaryViewController.h"
#import "AddMediaViewController.h"

#import "AFNetworking.h"
#import "Common.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "Utils.h"

#import "PaymentInformation.h"

@interface BillingInformationViewController () <UITextFieldDelegate>{
    CGSize result;
    
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
    
    
}
@property (strong, nonatomic) IBOutlet UITextField *securityCode;
@property (strong, nonatomic) IBOutlet UITextField *expDate;
@property (strong, nonatomic) IBOutlet UITextField *nameOnCard;
@property (strong, nonatomic) IBOutlet UITextField *creditCardNo;
@property (strong, nonatomic) IBOutlet UITextField *creditCardNoOther;
@property (strong, nonatomic) IBOutlet UITextField *nameOnCardOther;
@property (strong, nonatomic) IBOutlet UITextField *ExpDateOther;
@property (strong, nonatomic) IBOutlet UITextField *securityCodeOther;

@end

@implementation BillingInformationViewController

- (void)viewDidLoad {
    result = [[UIScreen mainScreen] bounds].size;
    [super viewDidLoad];
    self.addNewCreditCardView.hidden = true;
    
    [self setColor];
    // Do any additional setup after loading the view from its nib.
    [self addDoneButtonToKeyboard:self.securityCode];
    [self addDoneButtonToKeyboard:self.expDate];
    [self addDoneButtonToKeyboard:self.nameOnCard];
    [self addDoneButtonToKeyboard:self.creditCardNo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationsObservers];
    topConstraint = topLayoutConstraint.constant;   
    
    if (self.braintree) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
        [SVProgressHUD dismiss];
        if (err)
            [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"YES" doneButtonTitle:nil alertHandle:nil];
        else{
            self.braintree = [Braintree braintreeWithClientToken:client_token];
            self.provider = [self.braintree paymentProviderWithDelegate:self];
        }
    }];
    PaymentInformation *paymentInfor = [[PaymentInformation alloc] init];
    [paymentInfor loadPaymentInformation];
    
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
    self.creditCardNo.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Credit Card No." attributes:@{NSForegroundColorAttributeName:clr}];
    self.creditCardNoOther.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Credit Card No." attributes:@{NSForegroundColorAttributeName:clr}];
    self.nameOnCard.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Name On Card" attributes:@{NSForegroundColorAttributeName:clr}];
    self.nameOnCardOther.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Name On Card" attributes:@{NSForegroundColorAttributeName:clr}];
    self.expDate.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Exp. Date(mm/yr)" attributes:@{NSForegroundColorAttributeName:clr}];
    self.ExpDateOther.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Exp. Date(mm/yr)" attributes:@{NSForegroundColorAttributeName:clr}];
    self.securityCode.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Security Code" attributes:@{NSForegroundColorAttributeName:clr}];
    self.securityCodeOther.attributedPlaceholder =[[NSAttributedString alloc]initWithString:@"Security Code" attributes:@{NSForegroundColorAttributeName:clr}];
}
- (IBAction)btn_save:(id)sender {
    if (self.creditCardNo.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Credit Card No." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    if (self.nameOnCard.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Name on Card" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    if (self.expDate.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Exp Date" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if ([self.expDate.text rangeOfString:@"[0-9]{1,2}\\/[0-9]{1,4}" options:NSRegularExpressionSearch].location == NSNotFound) {
        [Utils showAlertView:@"Add Credit Card" message:@"Invalid Expiration Date." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.securityCode.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Security Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if (self.braintree) {
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
        request.number = self.creditCardNo.text;
        request.expirationDate = self.expDate.text;
        request.cvv = self.securityCode.text;
        [self.braintree tokenizeCard:request completion:^(NSString *nonce, NSError *error) {
            
            if (error) {
                [SVProgressHUD dismiss];
                [Utils showAlertView:@"Fail to save Credit Card" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }
            
            AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
            
            NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
            NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
            
            NSDictionary *dic = @{@"token":token
                                  , @"uid":uid
                                  , @"noncenumber":nonce};
            
            [man POST:@"SetPaymentAccount" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [SVProgressHUD dismiss];
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary*) responseObject;
                    int retCode = [[dic objectForKey:@"retCode"] intValue];
                    if (retCode == 0) {
                        [SettingManager setStringValue:@"2" withKey:SETTING_KEY_PAYMENT];
                        [SettingManager setStringValue:self.creditCardNo.text withKey:SETTING_KEY_CARDNUMBER];
                        [SettingManager setStringValue:self.nameOnCard.text withKey:SETTING_KEY_CARDNAME];
                        [SettingManager setStringValue:self.expDate.text withKey:SETTING_KEY_EXPIREDATE];
                        [SettingManager setStringValue:self.securityCode.text withKey:SETTING_KEY_SECURITYCODE];
                        [self.navigationController popViewControllerAnimated:YES];
                    }else {
                        [Utils showAlertView:@"Fail to Set Payment Account" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    }
                }else{
                    [Utils showAlertView:@"Fail to Set Payment Account" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD dismiss];
                [Utils showAlertView:@"Fail to Set Payment Account" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }];
            
        }];
    }else{
        [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
            if (err) {
                [SVProgressHUD dismiss];
                [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }else{
                self.braintree = [Braintree braintreeWithClientToken:client_token];
                self.provider = [self.braintree paymentProviderWithDelegate:self];
                BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
                request.number = self.creditCardNo.text;
                request.expirationDate = self.expDate.text;
                request.cvv = self.securityCode.text;
                [self.braintree tokenizeCard:request completion:^(NSString *nonce, NSError *error) {
                    if (error) {
                        [SVProgressHUD dismiss];
                        [Utils showAlertView:@"Fail to save Credit Card" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        return;
                    }
                    
                    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
                    
                    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
                    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
                    
                    NSDictionary *dic = @{@"token":token
                                          , @"uid":uid
                                          , @"noncenumber":nonce};
                    
                    [man POST:@"SetPaymentAccount" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [SVProgressHUD dismiss];
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *dic = (NSDictionary*) responseObject;
                            int retCode = [[dic objectForKey:@"retCode"] intValue];
                            if (retCode == 0) {
                                [SettingManager setStringValue:@"2" withKey:SETTING_KEY_PAYMENT];
                                [SettingManager setStringValue:self.creditCardNo.text withKey:SETTING_KEY_CARDNUMBER];
                                [SettingManager setStringValue:self.nameOnCard.text withKey:SETTING_KEY_CARDNAME];
                                [SettingManager setStringValue:self.expDate.text withKey:SETTING_KEY_EXPIREDATE];
                                [SettingManager setStringValue:self.securityCode.text withKey:SETTING_KEY_SECURITYCODE];
                                [self.navigationController popViewControllerAnimated:YES];
                            }else {
                                [Utils showAlertView:@"Fail to Set Payment Account" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                            }
                        }else{
                            [Utils showAlertView:@"Fail to Set Payment Account" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [SVProgressHUD dismiss];
                        [Utils showAlertView:@"Fail to Set Payment Account" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    }];
                    
                }];
            }
        }];
    }
}
- (IBAction)btn_addCreditCard:(id)sender {
//    [self checkKeyboardOpen:1];
//     self.addNewCreditCardView.hidden = false;
//    [self.view addSubview:self.addNewCreditCardView];
//    
//    
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
//        if(result.height == 480){
//            self.addNewCreditCardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 320, 480);
//
//        }
//        if(result.height == 568){
//            self.addNewCreditCardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 320, 568);
//        }
//        if (result.height == 667) {
//            self.addNewCreditCardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 375, 667);
//        }
//        if (result.height > 667) {
//            self.addNewCreditCardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 414, 736);
//        }
//    }
    
}

-(void)checkKeyboardOpen : (int)a{
    if(a==1){
    if([self.creditCardNo isFirstResponder] || [self.nameOnCard isFirstResponder ] || [self.expDate isFirstResponder] ||[self.securityCode isFirstResponder] ){
        [self.creditCardNo resignFirstResponder];
        [self.nameOnCard resignFirstResponder];
        [self.expDate resignFirstResponder];
        [self.securityCode resignFirstResponder];
        
    }
    }
    if(a == 2){
        if([self.creditCardNoOther isFirstResponder] || [self.nameOnCardOther isFirstResponder ] || [self.ExpDateOther isFirstResponder] ||[self.securityCodeOther isFirstResponder] ){
            [self.creditCardNoOther resignFirstResponder];
            [self.nameOnCardOther resignFirstResponder];
            [self.ExpDateOther resignFirstResponder];
            [self.securityCodeOther resignFirstResponder];
            
        }

    }

}
- (IBAction)btn_PayPal:(id)sender {
    if (self.braintree) {
        [self.provider createPaymentMethod:BTPaymentProviderTypePayPal];
    }else{
        [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
            if (err) {
                [SVProgressHUD dismiss];
                [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }else{
                self.braintree = [Braintree braintreeWithClientToken:client_token];
                self.provider = [self.braintree paymentProviderWithDelegate:self];
                [self.provider createPaymentMethod:BTPaymentProviderTypePayPal];
            }
        }];
    }
}
- (IBAction)btn_saveCreditCardDetail:(id)sender {
     self.addNewCreditCardView.hidden = true;
    [self checkKeyboardOpen:2];
   // [self.addNewCreditCardView removeFromSuperview];
    
}
- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btn_cancel:(id)sender {
    self.addNewCreditCardView.hidden = false;
    [self.addNewCreditCardView removeFromSuperview];

}

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

#pragma mark - payment delegate
- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender
{
    
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error
{
    [Utils showAlertView:@"Create Payment Mothod" message:error.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorDidCancel:(id)sender
{
    
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod
{
    // send payment
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid
                          , @"noncenumber":paymentMethod.nonce};
    
    [man POST:@"SetPaymentAccount" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [SettingManager setStringValue:@"1" withKey:SETTING_KEY_PAYMENT];
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [Utils showAlertView:@"Signin fail!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
            [Utils showAlertView:@"Set Payment Account Fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Set Payment Account" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreatorWillProcess:(id)sender
{
    
}

- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *, NSError *))completionBlock {
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid};
    
    [man POST:@"GetBTClientToken" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                completionBlock(responseObject[@"btClientToken"], nil);
            }else {
                completionBlock(nil, nil);
                return;
            }
        }else{
            completionBlock(nil, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
}

@end
