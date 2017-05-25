//
//  FAQViewController.m
//  BurnVideo
//
//  Created by user on 8/3/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "FAQViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "Utils.h"
#import "Common.h"
#import "SettingManager.h"

@interface FAQViewController ()
{
    __weak IBOutlet UITextView *tvContent;
    
}

@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [tvContent setHidden:true];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid
                          , @"attribute":@"faq"};
    [man POST:@"GetSetting" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                NSString *data = [dic objectForKey:@"data"];
                UIFont *font;
                if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
                    font = [UIFont fontWithName:@"Arial" size:14];
                }else{
                    font = [UIFont fontWithName:@"Arial" size:30];
                }
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                                                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
                [tvContent setAttributedText:string];
            }else {
//                [Utils showAlertView:@"Order" message:dic[@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
//            [Utils showAlertView:@"Order" message:@"Response data error" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
        [tvContent setHidden:false];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [tvContent setHidden:false];
//        [Utils showAlertView:@"Get Order History" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
