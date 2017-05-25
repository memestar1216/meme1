//
//  CompleteOrderViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "CompleteOrderViewController.h"
#import "AddMediaViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "UIViewController+LewPopupViewController.h"
#import "SettingManager.h"
#import "ShippingTableViewCell.h"

#import "AFNetworking.h"
#import "Utils.h"
#import "Common.h"
#import "SVProgressHUD.h"
#import "SelectionManager.h"

#import "AdditionalOrderView.h"
#import "NSURLRequest+NSURLRequestSSLY.h"


@interface CompleteOrderViewController ()<UITableViewDataSource, UITableViewDelegate, AdditionOrderDelegate>
{
    AppDelegate *appdel;
    CGSize result;
    NSString *orderid;
    NSInteger editingIndex;
}

@end

@implementation CompleteOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.orderInfo);
    result = [[UIScreen mainScreen] bounds].size;
    appdel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    // Do any additional setup after loading the view from its nib.
   _btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    [_btn1 addTarget:self action:@selector(btn_promocodeapply) forControlEvents:UIControlEventTouchUpInside];
    [_mainviews addSubview:_btn1];
    [_btn1 setImage:[UIImage imageNamed:@"bbtniphoneeyellow.png"] forState:UIControlStateNormal];
    [_btn1 setTitle:@"Apply Promo Code" forState:UIControlStateNormal];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        NSLog(@"%f",screenBounds.size.height);
        if (screenBounds.size.height ==667)
        {
            _btn1.frame=CGRectMake(65, self.view.frame.size.height-84, 248, 36);
        }
        else if (screenBounds.size.height ==736)
        {
            _btn1.frame=CGRectMake(70, self.view.frame.size.height-84, 243, 36);
            
        }
        else
        {
            _btn1.frame=CGRectMake(56, self.view.frame.size.height-82, 208, 34);
        }
    }
    else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        _btn1.frame=CGRectMake(self.view.frame.size.width/2-160, self.view.frame.size.height-140, 320, 50);
    
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     applyOrNot=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onEditMainOrder:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn_done:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    NSMutableDictionary *shipping = [NSMutableDictionary new];
    [shipping addEntriesFromDictionary:@{@1:[self.orderInfo.mainShippingInfomation toDictionary]}];
    for (int i = 0; i<self.orderInfo.shippingArray.count; i++) {
        ShippingInformation *infor = self.orderInfo.shippingArray[i];
        [shipping addEntriesFromDictionary:@{[NSNumber numberWithInt:i+2]:[infor toDictionary]}];
    }
    
    NSDictionary *dic;
    if (self.orderInfo.previousOrder) {
        if ( applyOrNot==NO) {
            dic = @{@"token":token
                    , @"uid":uid
                    , @"filecount":[NSNumber numberWithInteger:0]
                    , @"slotcount":[NSNumber numberWithInteger:0]
                    , @"dvdtitle":[self.orderInfo getDVDTitle]
                    , @"dvd_caption":@""
                    , @"preorderid":self.orderInfo.previousOrder
                    , @"shipping":shipping
                    , @"devicetype":@"1"
                    , @"files":@""
                    , @"dvdcount":[NSNumber numberWithInteger:[self.orderInfo getTotalCount]]};
        } else {
            dic = @{@"token":token
                    , @"uid":uid
                    , @"filecount":[NSNumber numberWithInteger:0]
                    , @"slotcount":[NSNumber numberWithInteger:0]
                    , @"dvdtitle":[self.orderInfo getDVDTitle]
                    , @"dvd_caption":@""
                    , @"preorderid":self.orderInfo.previousOrder
                    , @"shipping":shipping
                    , @"devicetype":@"1"
                    , @"files":@""
                    ,@"promocode":str_promocode
                    , @"dvdcount":[NSNumber numberWithInteger:[self.orderInfo getTotalCount]]};
        }
        
        
    }else{
        if ( applyOrNot==NO)
        {
            dic = @{@"token":token
                    , @"uid":uid
                    , @"filecount":[NSNumber numberWithInteger:self.orderInfo.selectedMediaArray.count]
                    , @"slotcount":[NSNumber numberWithInteger:self.orderInfo.selectedCount]
                    , @"dvdtitle":[self.orderInfo getDVDTitle]
                    , @"dvd_caption":@""
                    , @"preorderid":@""
                    , @"shipping":shipping
                    , @"devicetype":@"1"
                    , @"files":self.orderInfo.selectedMediaArray
                    , @"dvdcount":[NSNumber numberWithInteger:[self.orderInfo getTotalCount]]};
        }
        else
        {
            dic = @{@"token":token
                    , @"uid":uid
                    , @"filecount":[NSNumber numberWithInteger:self.orderInfo.selectedMediaArray.count]
                    , @"slotcount":[NSNumber numberWithInteger:self.orderInfo.selectedCount]
                    , @"dvdtitle":[self.orderInfo getDVDTitle]
                    , @"dvd_caption":@""
                    , @"preorderid":@""
                    , @"shipping":shipping
                    , @"devicetype":@"1"
                    , @"files":self.orderInfo.selectedMediaArray
                    ,@"promocode":str_promocode
                    , @"dvdcount":[NSNumber numberWithInteger:[self.orderInfo getTotalCount]]};
        }
           }
    
    [man POST:@"CreateOrder" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                orderid = responseObject[@"orderid"];
                if (self.orderInfo.previousOrder == nil) {
                    [[SelectionManager sharedInstance] saveUploadedFiles];
                }
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
                
                NSInteger day = [components day];
                NSInteger month = [components month];
                NSInteger year = [components year];
                NSString *str=[[NSString alloc]init];
                if (month==1) {
                    str=@"February";
                } else if (month==2) {
                    str=@"March";
                }else if (month==3) {
                    str=@"April";
                }else if (month==4) {
                    str=@"May";
                }else if (month==5) {
                    str=@"June";
                }else if (month==6) {
                    str=@"July";
                }else if (month==7) {
                    str=@"August";
                }else if (month==8) {
                    str=@"September";
                }else if (month==9) {
                    str=@"October";
                }else if (month==10) {
                    str=@"November";
                }else if (month==11) {
                    str=@"December";
                }else if (month==12) {
                    str=@"January";
                }
                NSString *string = [NSString stringWithFormat:@"%@ %ld,%ld", str, (long)day, (long)year];
                
                
                //[self.lbConfirm setText:[NSString stringWithFormat:@"Thank you for your purchase. Your custom HD DVD is on its way. Make sure you upload your next 40 media spaces on or by %@.", string]];
                [self.confirmView setHidden:false];
                _btn1.hidden=YES;
                appdel.user.hasFreeDVD = false;
                NSDate *nextMonthlyDate = [NSDate dateWithTimeInterval:2592000 sinceDate:[NSDate date]];
                appdel.user.monthlyDate = nextMonthlyDate;
            }else {
                [Utils showAlertView:@"Order" message:dic[@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
            [Utils showAlertView:@"Order" message:@"Response data error" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Order" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (IBAction)onConfirmOrder:(id)sender {
    [self.navigationController popToViewController:appdel.mainVC animated:YES];
//    [Utils showAlertView:@"Complete Order" message:@"You can close the app at this time. We will continue to upload your media files in the background and it WON’t interfere with the use of your phone. Once the media files are fully uploaded you will receive an email confirmation that your Burn Video is on its way!" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
//        
//    }];
}

- (IBAction)onShare:(UIButton*)sender {
    NSArray *activityItems = [NSArray arrayWithObjects:@"www.burnvideo.net", self.lbConfirm.text, nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityController animated:YES completion:nil];
    }else{
        UIPopoverController *popc = [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popc presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orderInfo) {
        return self.orderInfo.shippingArray.count + 1;
    }
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ShippingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shippingcell" forIndexPath:indexPath];
    
//      ShippingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    static NSString *CellIdentifiers =@"shippingcell";
    ShippingTableViewCell *cell=(ShippingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifiers];
    [cell.btnEdit setTag:indexPath.row];
    [cell.btnEdit addTarget:self action:@selector(onEditCell:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnPromocode setTag:indexPath.row];
//    [cell.btnPromocode addTarget:self action:@selector(onEnterPromoCode:) forControlEvents:UIControlEventTouchUpInside];
    UITextView *tv_address=[[UITextView alloc]initWithFrame:CGRectMake(5, 56, 245, 58)];
    
    [cell addSubview:tv_address];
    if (indexPath.row == 0) {
        [cell.btnRemove setHidden:true];
        
        cell.lbDVDCount.text = self.orderInfo.mainShippingInfomation.count;
        NSLog(@"%@",self.orderInfo.mainShippingInfomation.count);
        NSString *str_count1=[[NSString alloc]initWithFormat:@"%@",self.orderInfo.mainShippingInfomation.count];
        
        totalValuecalculated=[str_count1 floatValue];
          NSLog(@"%f",totalValuecalculated);
        
       tv_address.text = [self.orderInfo.mainShippingInfomation information];
        if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            tv_address.frame=CGRectMake(5, 56, 245, 58);
            tv_address.font = [UIFont fontWithName:@"Century Gothic" size:14];
        }else{
            tv_address.font = [UIFont fontWithName:@"Century Gothic" size:30];
              tv_address.frame=CGRectMake(8, 103, 630, 108);
        }
        
        
    }else{
        [cell.btnRemove setHidden:false];
        [cell.btnRemove setTag:indexPath.row];
        [cell.btnRemove addTarget:self action:@selector(onRemoveCell:) forControlEvents:UIControlEventTouchUpInside];
        ShippingInformation *infor = self.orderInfo.shippingArray[indexPath.row - 1];
        
        cell.lbDVDCount.text = infor.count;
         NSLog(@"%@",cell.lbDVDCount.text);
        NSString *str_count2=[[NSString alloc]initWithFormat:@"%@",cell.lbDVDCount.text];
        
        totalValuecalculated=[str_count2 floatValue]+totalValuecalculated;
         NSLog(@"%f",totalValuecalculated);
       tv_address.text = [infor information];
        if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            tv_address.font = [UIFont fontWithName:@"Century Gothic" size:14];
             tv_address.frame=CGRectMake(5, 56, 245, 58);
        }else{
             tv_address.frame=CGRectMake(8, 103, 630, 108);
            tv_address.font = [UIFont fontWithName:@"Century Gothic" size:30];
        }
    }

    return cell;
}

- (void) onRemoveCell:(UIButton*) button {
    NSInteger index = button.tag;
    if (index == 0) {
        return;
    }
    [self.orderInfo.shippingArray removeObjectAtIndex:index - 1];
    [self.tblOrder deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
//-(void)onEnterPromoCode:(UIButton*) button {
//    NSLog(@"hello");
//    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Please enter Promo code" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    av.tag=100;
//    av.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [av textFieldAtIndex:0].delegate = self;
//    [av show];
//}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        UITextField *textField = [alertView textFieldAtIndex:0];
       str_promocode =[[NSString alloc]initWithFormat:@"%@",textField.text];
        NSLog(@"The name is %@",str_promocode);
        NSLog(@"Using the Textfield: %@",[[alertView textFieldAtIndex:0] text]);
        
        
        if (textField.text.length == 0)
        {

        }
        else
        {
            totalValue=totalValuecalculated;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            AFSecurityPolicy *securityPolicy;
            AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.burnvideo.net/"]];
            NSLog(@"%f",totalValue);
            if (totalValue==0.0) {
                totalValue=1.0;
            }
            int dvdCount=(int)totalValue;
            NSLog(@"%d",dvdCount);
            totalValue=totalValue*5.99;
               NSString *str_totalValue=[[NSString alloc]initWithFormat:@"%f",totalValue];
            NSDictionary *dic = @{@"name":textField.text
                                  , @"value":str_totalValue
                                  };
            NSLog(@"%@",dic);
            securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            securityPolicy.allowInvalidCertificates = YES;
            man.securityPolicy = securityPolicy;
            [man POST:@"check-promo" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    [SVProgressHUD dismiss];
                    NSDictionary *dic = (NSDictionary*) responseObject;
                    int retCode = [[dic objectForKey:@"status"] intValue];
                    
                    if (retCode == 1) {
                         float value = [[dic objectForKey:@"value"] floatValue];
                        float discountedTotal=totalValue-value;
                        UIAlertView *alert = [[UIAlertView alloc]
                                              initWithTitle: @"Promo Code Applied"
                                              message: [NSString stringWithFormat: @"No of DVD's: %d \n Total Purchase: $%.02f \n Discount: $%.02f \n Discounted Total: $%.02f", dvdCount,totalValue, value,discountedTotal]
                                              delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
                        
                        applyOrNot=YES;

                        [alert show];
                    } else {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Invalid Promo Code" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                            applyOrNot=NO;
                        return ;
                    }
                        if(retCode==-101)
                    {
                        //                    [Utils showAlertView:@"promo code apply fail!" message:@"" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        return;
                    }
                        else if (retCode==-102)
                        {
                        //                    [Utils showAlertView:@"promo code apply fail!" message:@"" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        return;
                    }else{
                        //                    [Utils showAlertView:@"promo code apply fail!" message:@"" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                        return;
                    }
                }else{
                    [SVProgressHUD dismiss];
                    [Utils showAlertView:@"Promocode apply fail!" message:@"Response type is incorrect." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD dismiss];
                [Utils showAlertView:@"promocode apply fail!" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }];
        }
        

    }
    
}



- (void) onEditCell:(UIButton*) button {
    editingIndex = button.tag;
    ShippingInformation *info;
    if (editingIndex == 0) {
        info = self.orderInfo.mainShippingInfomation;
    }else{
        info = self.orderInfo.shippingArray[editingIndex - 1];
    }
    
    AdditionalOrderView *orderView = [AdditionalOrderView loadOrderSettingView:info];
    orderView.delegate = self;
    [orderView setTag:editingIndex];
    [orderView setFrame:CGRectMake(0, 0, result.width, result.height)];
    [self lew_presentPopupView:orderView animation:[LewPopupViewAnimationFade new] dismissed:^{
        
    }];

}

- (void)additionOrderView:(UIView *)view closedWithDone:(BOOL)isDone
{
    AdditionalOrderView *shippingview = (AdditionalOrderView*) view;
    [self lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
    if (isDone) {
        if (editingIndex == 0) {
            self.orderInfo.mainShippingInfomation.firstName = shippingview.tfFirstName.text;
            self.orderInfo.mainShippingInfomation.lastName  = shippingview.tfLastName.text;
            self.orderInfo.mainShippingInfomation.streetAddress = shippingview.tvStreet.text;
            self.orderInfo.mainShippingInfomation.city = shippingview.tfCity.text;
            self.orderInfo.mainShippingInfomation.state = shippingview.tfState.text;
            self.orderInfo.mainShippingInfomation.count = shippingview.lbCount.text;
            self.orderInfo.mainShippingInfomation.zipcode = shippingview.tfZipcode.text;
        }else{
            ShippingInformation *shippinginfo = self.orderInfo.shippingArray[editingIndex - 1];
            shippinginfo.firstName = shippingview.tfFirstName.text;
            shippinginfo.lastName  = shippingview.tfLastName.text;
            shippinginfo.streetAddress = shippingview.tvStreet.text;
            shippinginfo.city = shippingview.tfCity.text;
            shippinginfo.state = shippingview.tfState.text;
            shippinginfo.count = shippingview.lbCount.text;
            shippinginfo.zipcode = shippingview.tfZipcode.text;
        }
        [self.tblOrder reloadData];
    }
}
-(void)btn_promocodeapply
{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Promo Code" message:@"Please Enter Promo Code" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.tag=100;
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

@end
