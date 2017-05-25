//
//  LoginViewController.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UITextField *text_emailAddress;
@property (strong, nonatomic) IBOutlet UITextField *text_password;
@property (strong, nonatomic) IBOutlet UIView *forgetPasswordView;
@property (weak, nonatomic) IBOutlet UIImageView *imv_forgetbg;
@property (strong, nonatomic) IBOutlet UITextView *textView_message;
@property (strong, nonatomic) IBOutlet UITextField *text_forgetEmailAdd;
@property (strong, nonatomic) IBOutlet UILabel *lbl_existingCstmr;
@property (weak, nonatomic) IBOutlet UIButton *btnRememberPW;


@end
