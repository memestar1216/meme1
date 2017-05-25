//
//  PaymentModeViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "PaymentModeViewController.h"
#import "PaymentDetailViewController.h"
#import "Utils.h"

#import "AFNetworking.h"
#import "Common.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "AppDelegate.h"

@interface PaymentModeViewController ()<BTDropInViewControllerDelegate>
{
    BTDropInViewController *dropIn;
    AppDelegate *appd;
}

@end

@implementation PaymentModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appd = (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = true;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addPaymentAccount:(id)sender {
    dropIn = [self.braintree dropInViewControllerWithDelegate:self];
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

- (void)tappedCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BTDropInViewControllerDelegate

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
                [self performSegueWithIdentifier:@"showAlbum" sender:self];
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
    self.navigationController.navigationBarHidden = true;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPaypal:(id)sender {//not paypal, it's for applepay
    if (self.braintree) {
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
    
    [man POST:@"GetBTClientToken" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [self performSegueWithIdentifier:@"showAlbum" sender:self];
            }else {
                [Utils showAlertView:@"Add Payment Information fail!" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addcredit"]) {
        PaymentDetailViewController *detail = (PaymentDetailViewController*)[segue destinationViewController];
        if (self.braintree) {
            detail.braintree = self.braintree;
        }
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return true;
}

@end
