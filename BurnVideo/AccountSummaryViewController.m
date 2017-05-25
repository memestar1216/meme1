//
//  AccountSummaryViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AccountSummaryViewController.h"
#import "ShippingAddressViewController.h"
#import "BillingInformationViewController.h"
#import "SettingViewController.h"
#import "ShippingInformation.h"
#import "PaymentInformation.h"

#import "AFNetworking.h"
#import "Common.h"
#import "Utils.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"



#import "User.h"
#import "AppDelegate.h"

@interface AccountSummaryViewController () <UINavigationBarDelegate, BTDropInViewControllerDelegate, UIActionSheetDelegate>
{
    __weak IBOutlet UILabel *lbShippingAddress;
    __weak IBOutlet UILabel *lbBillingInformation;
    AppDelegate *appd;
}

@end

@implementation AccountSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
    appd = (AppDelegate*)[UIApplication sharedApplication].delegate;
    User *user = appd.user;
    [lbShippingAddress setText:[user information]];
    ShippingInformation *shippingInfo = [[ShippingInformation alloc] init];
    [shippingInfo loadShippingInformation];
    if ([shippingInfo information].length != 0) {
        [lbShippingAddress setText:[NSString stringWithFormat:@"%@ %@, %@, %@, %@, %@", shippingInfo.firstName, shippingInfo.lastName, shippingInfo.streetAddress, shippingInfo.city, shippingInfo.state, shippingInfo.zipcode]];
    }
//    NSString *payment = [SettingManager stringValueWithKey:SETTING_KEY_PAYMENT];
    if (appd.user.customerid) {
        lbBillingInformation.text = @"Payment Account Registered!";
//        if (payment == nil) {
//            lbBillingInformation.text = @"Payment Account Registered!";
//            return;
//        }
//        if ([payment isEqualToString:@"1"]) {//paypal
//            lbBillingInformation.text = @"Paypal Account Registered!";
//        }else{
//            PaymentInformation *paymentInfor = [[PaymentInformation alloc] init];
//            [paymentInfor loadPaymentInformation];
//            if (paymentInfor.creditCardNo && paymentInfor.expDate) {
//                NSString *infor = [NSString stringWithFormat:@"%@, %@", paymentInfor.creditCardNo
//                                   , paymentInfor.expDate];
//                lbBillingInformation.text = infor;
//            }else{
//                lbBillingInformation.text = @"Credit Card registered.";
//            }
//        }
    }else{
        lbBillingInformation.text = @"Not Registered!";
    }
    
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
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editPaymentAccount:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Payment Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Apple Pay" otherButtonTitles:@"Other Payment", nil];
//    [actionSheet showInView:self.view];
    
    { // updated by steve:12/30/2015
        if (self.braintree) {
            BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
            dropIn.title = @"Add Payment Information";
            dropIn.callToActionText = @"Add Account";
            dropIn.shouldHideCallToAction = NO;
            self.navigationController.navigationBarHidden = false;
            [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:67.0/255 green:132.0/255 blue:58.0/255 alpha:1]];
            [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]];
            
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]};
            [self.navigationController.navigationBar setTranslucent:false];
            [self.navigationController pushViewController:dropIn animated:YES];
        }else{
            [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
                if (err) {
                    [SVProgressHUD dismiss];
                    [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }else{
                    self.braintree = [Braintree braintreeWithClientToken:client_token];
                    BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
                    dropIn.title = @"Add Payment Information";
                    dropIn.callToActionText = @"Add Account";
                    dropIn.shouldHideCallToAction = NO;
                    self.navigationController.navigationBarHidden = false;
                    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:67.0/255 green:132.0/255 blue:58.0/255 alpha:1]];
                    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]];
                    
                    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]};
                    [self.navigationController.navigationBar setTranslucent:false];
                    [self.navigationController pushViewController:dropIn animated:YES];
                }
            }];
        }
    

    }
    
   
    
    return;
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {//apple pay
        if (self.braintree) {
            self.provider = [self.braintree paymentProviderWithDelegate:self];
            if (![self.provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeApplePay]) {
                [Utils showAlertView:@"Order" message:@"Apple pay isn't available." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }
            PKPaymentSummaryItem *testTotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Burn Video" amount:[NSDecimalNumber decimalNumberWithString:@"0"]];
            [self.provider setPaymentSummaryItems:@[testTotal]];
            [self.provider createPaymentMethod:BTPaymentProviderTypeApplePay];
        }else{
            [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
                if (err) {
                    [SVProgressHUD dismiss];
                    [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }else{
                    self.braintree = [Braintree braintreeWithClientToken:client_token];
                    self.provider = [self.braintree paymentProviderWithDelegate:self];
                    if (![self.provider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeApplePay]) {
                        [Utils showAlertView:@"Order" message:@"Apple pay isn't available." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        return;
                    }
                    PKPaymentSummaryItem *testTotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Burn Video" amount:[NSDecimalNumber decimalNumberWithString:@"0"]];
                    [self.provider setPaymentSummaryItems:@[testTotal]];
                    [self.provider createPaymentMethod:BTPaymentProviderTypeApplePay];
                }
            }];
        }
    }else if (buttonIndex == 0){// other pay
        if (self.braintree) {
            BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
            dropIn.title = @"Add Payment Information";
            dropIn.callToActionText = @"Add Account";
            dropIn.shouldHideCallToAction = NO;
            self.navigationController.navigationBarHidden = false;
            [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:67.0/255 green:132.0/255 blue:58.0/255 alpha:1]];
            [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]];
            
            self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]};
            [self.navigationController.navigationBar setTranslucent:false];
            [self.navigationController pushViewController:dropIn animated:YES];
        }else{
            [self createCustomerAndFetchClientTokenWithCompletion:^(NSString *client_token, NSError *err) {
                if (err) {
                    [SVProgressHUD dismiss];
                    [Utils showAlertView:@"Cannot access Server" message:err.localizedDescription  cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }else{
                    self.braintree = [Braintree braintreeWithClientToken:client_token];
                    BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
                    dropIn.title = @"Add Payment Information";
                    dropIn.callToActionText = @"Add Account";
                    dropIn.shouldHideCallToAction = NO;
                    self.navigationController.navigationBarHidden = false;
                    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:67.0/255 green:132.0/255 blue:58.0/255 alpha:1]];
                    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]];
                    
                    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:233.0/255 green:231.0/255 blue:34.0/255 alpha:1]};
                    [self.navigationController.navigationBar setTranslucent:false];
                    [self.navigationController pushViewController:dropIn animated:YES];
                }
            }];
        }
    }
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
                [Utils showAlertView:@"Add Payment Information!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
            [Utils showAlertView:@"Add Payment Information Fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Add Payment Information Fail!" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
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

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.navigationController popViewControllerAnimated:YES];
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
                appd.user.customerid = dic[@"customerid"];
                lbBillingInformation.text = @"Payment Account Registered!";
            }else {
                [Utils showAlertView:@"Add Payment Information Fail!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
            [Utils showAlertView:@"Add Payment Information Fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Add Payment Information Account" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (void)dropInViewControllerWillComplete:(__unused BTDropInViewController *)viewController {
    self.navigationController.navigationBarHidden = true;
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
