//
//  PaymentDetailViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "PaymentDetailViewController.h"
#import "AlbumSelectionViewController.h"

#import "AFNetworking.h"
#import "Common.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "Utils.h"

@interface PaymentDetailViewController () <UITextFieldDelegate>
{
    // for avoid keyborad
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
}

@end

@implementation PaymentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Muraree");
    NSString *htmlString = @"<center><font size=5><p> Signing up is free and you are never</p><p>charged until you place your first</p><p>order with Burn Video</p></font></center>";
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    self.text_detailMsg.attributedText = attributedString;
    self.text_detailMsg.textColor = [UIColor whiteColor];
    [self textColor];
   
    [self addDoneButtonToKeyboard:self.text_creditCard];
    [self addDoneButtonToKeyboard:self.text_expDate];
    [self addDoneButtonToKeyboard:self.text_nameoncard];
    [self addDoneButtonToKeyboard:self.text_securityCode];
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

-(void)textColor{
    
    UIColor *color = [UIColor grayColor];
    self.text_creditCard.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Credit Card No." attributes:@{NSForegroundColorAttributeName:color}];
    self.text_nameoncard.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Name on Card" attributes:@{NSForegroundColorAttributeName:color}];
    self.text_expDate.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Exp Date(mm/yr)" attributes:@{NSForegroundColorAttributeName:color}];
    self.text_securityCode.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Security Code" attributes:@{NSForegroundColorAttributeName:color}];


    

    
}
- (IBAction)btn_createAccount:(id)sender {
    //[self performSegueWithIdentifier:@"gotoselectalbum" sender:self];
    if (self.text_creditCard.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Credit Card No." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    if (self.text_nameoncard.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Name on Card" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    if (self.text_expDate.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Exp Date" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if ([self.text_expDate.text rangeOfString:@"[0-9]{1,2}\\/[0-9]{1,4}" options:NSRegularExpressionSearch].location == NSNotFound) {
        [Utils showAlertView:@"Add Credit Card" message:@"Invalid Expiration Date." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (self.text_securityCode.text.length == 0) {
        [Utils showAlertView:@"Add Credit Card" message:@"Please enter Security Code" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if (self.braintree) {
        BTClientCardTokenizationRequest *request = [[BTClientCardTokenizationRequest alloc] init];
        request.number = self.text_creditCard.text;
        request.expirationDate = self.text_expDate.text;
        request.cvv = self.text_securityCode.text;
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
                        [SettingManager setStringValue:self.text_creditCard.text withKey:SETTING_KEY_CARDNUMBER];
                        [SettingManager setStringValue:self.text_nameoncard.text withKey:SETTING_KEY_CARDNAME];
                        [SettingManager setStringValue:self.text_expDate.text withKey:SETTING_KEY_EXPIREDATE];
                        [SettingManager setStringValue:self.text_securityCode.text withKey:SETTING_KEY_SECURITYCODE];
                        [self performSegueWithIdentifier:@"gotoselectalbum" sender:self];
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
                request.number = self.text_creditCard.text;
                request.expirationDate = self.text_expDate.text;
                request.cvv = self.text_securityCode.text;
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
                                [SettingManager setStringValue:self.text_creditCard.text withKey:SETTING_KEY_CARDNUMBER];
                                [SettingManager setStringValue:self.text_nameoncard.text withKey:SETTING_KEY_CARDNAME];
                                [SettingManager setStringValue:self.text_expDate.text withKey:SETTING_KEY_EXPIREDATE];
                                [SettingManager setStringValue:self.text_securityCode.text withKey:SETTING_KEY_SECURITYCODE];
                                [self performSegueWithIdentifier:@"gotoselectalbum" sender:self];
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

- (IBAction)btn_payPal:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
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

#pragma mark - payment delegate
- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender
{
    
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error
{
    [Utils showAlertView:@"Create Payment Mothod" message:error.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    [SVProgressHUD dismiss];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorDidCancel:(id)sender
{
    [SVProgressHUD dismiss];
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
                [self performSegueWithIdentifier:@"gotoselectalbum" sender:self];
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
