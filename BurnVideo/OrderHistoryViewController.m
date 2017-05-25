//
//  OrderHistoryViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "OrderHistoryViewController.h"
#import "MakeOrderViewController.h"
#import "OrderTableViewCell.h"

#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "Utils.h"
#import "Common.h"
#import "SettingManager.h"

@interface OrderHistoryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *orders;
    __weak IBOutlet UITableView *tblArray;
}

@end

@implementation OrderHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orders = [NSMutableArray new];
    [self getOrders];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getOrders {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid};
    [man POST:@"GetOrderList" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                [orders addObjectsFromArray:[dic objectForKey:@"data"]];
                [tblArray reloadData];
            }else {
                [Utils showAlertView:@"Order" message:dic[@"msg"] cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }
        }else{
            [Utils showAlertView:@"Order" message:@"Response data error" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [Utils showAlertView:@"Get Order History" message:error.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }];
}

- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orders.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ordercell" forIndexPath:indexPath];
    cell.btnReburn.tag = indexPath.row;
    [cell.btnReburn addTarget:self action:@selector(onClickedReorder:) forControlEvents:UIControlEventTouchUpInside];
    NSDictionary *dic = [orders objectAtIndex:indexPath.row];
    cell.lbOrderID.text = [NSString stringWithFormat:@"A%08d", [dic[@"id"] intValue]];
    
    if (![dic[@"dvdtitle"] isKindOfClass:[NSNull class]]) {
        cell.lbDVDTitle.text = dic[@"dvdtitle"];
    }else{
        cell.lbDVDTitle.text = @"No Title!";
    }
    
    if ([dic[@"dvdcount"] isKindOfClass:[NSNull class]]) {
        cell.lbCount.text = @"1";
    }else{
        if ([dic[@"dvdcount"] isKindOfClass:[NSString class]]) {
            cell.lbCount.text = dic[@"dvdcount"];
        }else{
            cell.lbCount.text = [dic[@"dvdcount"] stringValue];
        }
    }
    
    NSDateFormatter *toformatter = [[NSDateFormatter alloc] init];
    toformatter.dateFormat = @"MM/dd/yyyy";
    NSDateFormatter *fromformatter = [[NSDateFormatter alloc] init];
    fromformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [fromformatter dateFromString:dic[@"inserttime"]];
    NSLog(@"%@", dic[@"inserttime"]);
    NSDate *date2 = [fromformatter dateFromString:dic[@"updatetime"]];
    NSLog(@"%@", dic[@"updatetime"]);
    cell.lbOrderDate.text = [toformatter stringFromDate:date1];
    if ([dic[@"status"] intValue] != 3) {
        if ([dic[@"status"] intValue] == 4) {
            [cell.btnReburn setTitle:@"Canceled" forState:UIControlStateNormal];
            [cell.btnReburn setEnabled:false];
            cell.lbShippingDate.text = @"-";
        }else{
            [cell.btnReburn setTitle:@"Processing" forState:UIControlStateNormal];
            [cell.btnReburn setEnabled:false];
            cell.lbShippingDate.text = @"-";
        }
    }else{
        [cell.btnReburn setTitle:@"Reburn" forState:UIControlStateNormal];
        [cell.btnReburn setEnabled:true];
        cell.lbShippingDate.text = [toformatter stringFromDate:date2];
    }
    
    return cell;
}

- (void) onClickedReorder:(UIButton*) sender {
    [self performSegueWithIdentifier:@"reorder" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reorder"]) {
        MakeOrderViewController *orderVC = (MakeOrderViewController*) segue.destinationViewController;
        NSInteger index = [(UIButton*)sender tag];
        NSDictionary *dic = [orders objectAtIndex:index];
        if ([dic[@"id"] isKindOfClass:[NSString class]]) {
            [orderVC setOrderID:dic[@"id"]];
        }else{
            [orderVC setOrderID:[dic[@"id"] stringValue]];
        }
        
    }
}

@end
