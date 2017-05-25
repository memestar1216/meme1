//
//  ChangePasswordViewController.m
//  BurnVideo
//
//  Created by user on 9/13/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AFNetworking.h"
#import "Common.h"
#import "Utils.h"
#import "SettingManager.h"
#import "SVProgressHUD.h"
#import "User.h"

#import "AppDelegate.h"

@interface ChangePasswordViewController ()
{
    __weak IBOutlet UITextField *tfNewPassword;
    
    __weak IBOutlet UITextField *tfRepassword;
}

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *color = [UIColor grayColor];
    tfNewPassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"New Password" attributes:@{NSForegroundColorAttributeName:color}];
    tfRepassword.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Verify Password" attributes:@{NSForegroundColorAttributeName:color}];
    [self addDoneButtonToKeyboard:tfNewPassword];
    [self addDoneButtonToKeyboard:tfRepassword];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSave:(id)sender {
    if (tfNewPassword.text.length == 0) {
        [Utils showAlertView:@"Change Password" message:@"Please enter New Password" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (tfRepassword.text.length == 0) {
        [Utils showAlertView:@"Change Password" message:@"Please enter Verify Password" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (tfRepassword.text.length < 8) {
        [Utils showAlertView:@"Change Password" message:@"Password must be 8 characters long." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    if (![tfNewPassword.text isEqualToString:tfRepassword.text]) {
        [Utils showAlertView:@"Change Password" message:@"Password and Verify Password is different. Please enter again." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid
                          , @"password":tfNewPassword.text};
    
    [man POST:@"ModifyPassword" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [SVProgressHUD dismiss];
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [Utils showAlertView:@"Change Password" message:@"Password is successfully changed." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else if (retCode == -101) {
                [Utils showAlertView:@"Change Password" message:@"UserName is duplicated. Please enter other name." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }else if (retCode == -102) {
                [Utils showAlertView:@"Change Password" message:@"Email is already registered. Please enter other email address." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }else{
                [Utils showAlertView:@"Change Password" message:[dic objectForKey:@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return;
            }
        }else{
            [SVProgressHUD dismiss];
            [Utils showAlertView:@"Change Password" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Change Password" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
    
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addDoneButtonToKeyboard:(UITextField*) textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
