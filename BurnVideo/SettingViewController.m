//
//  SettingViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "SettingViewController.h"
#import "AccountSummaryViewController.h"
#import "OrderHistoryViewController.h"
#import "MakeOrderViewController.h"
#import "AlbumSelectionViewController.h"
#import  "AppDelegate.h"
#import "AboutBurnVideoViewController.h"
#import "AboutBurnVideoThirdViewController.h"
#import "AboutBurnVideoSecondViewController.h"
#import "AddMediaViewController.h"

@interface SettingViewController (){
    AppDelegate *appdel;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appdel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_actSummary:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    AccountSummaryViewController *obj = [[AccountSummaryViewController alloc]initWithNibName:@"AccountSummaryViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        AccountSummaryViewController *obj = [[AccountSummaryViewController alloc]initWithNibName:@"AccountSummaryViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
    
}
- (IBAction)btn_orderHistory:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    OrderHistoryViewController *obj = [[OrderHistoryViewController alloc]initWithNibName:@"OrderHistoryViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        OrderHistoryViewController *obj = [[OrderHistoryViewController alloc]initWithNibName:@"OrderHistoryViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
}
//- (IBAction)btn_sendVideoTofmly:(id)sender {
//    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
//    MakeOrderViewController *obj = [[MakeOrderViewController alloc]initWithNibName:@"MakeOrderViewController" bundle:nil];
//    [self.navigationController pushViewController:obj animated:YES];
//    }
//    else{
//        MakeOrderViewController *obj = [[MakeOrderViewController alloc]initWithNibName:@"MakeOrderViewCotroller_iPad" bundle:nil];
//        [self.navigationController pushViewController:obj animated:YES];
//
//    }
//
//}
- (IBAction)btn_AlbumSelection:(id)sender {
    appdel.a =1;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    AlbumSelectionViewController *obj = [[AlbumSelectionViewController alloc]initWithNibName:@"AlbumSelectionViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        AlbumSelectionViewController *obj = [[AlbumSelectionViewController alloc]initWithNibName:@"AlbumSelectionViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
}



- (IBAction)btn_whtisburnVideo:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    AboutBurnVideoViewController *obj = [[AboutBurnVideoViewController alloc]initWithNibName:@"AboutBurnVideoViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        AboutBurnVideoViewController *obj = [[AboutBurnVideoViewController alloc]initWithNibName:@"AboutBurnVideoViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];

    }
    
}
- (IBAction)btn_instruction:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    AboutBurnVideoSecondViewController *obj = [[AboutBurnVideoSecondViewController alloc]initWithNibName:@"AboutBurnVideoSecondViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        AboutBurnVideoSecondViewController *obj = [[AboutBurnVideoSecondViewController alloc]initWithNibName:@"AboutBurnVideoSecondViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];

    }
    
    
}
- (IBAction)btn_terms:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    AboutBurnVideoThirdViewController *obj = [[AboutBurnVideoThirdViewController alloc]initWithNibName:@"AboutBurnVideoThirdViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        AboutBurnVideoThirdViewController *obj = [[AboutBurnVideoThirdViewController alloc]initWithNibName:@"AboutBurnVideoThirdViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];

    }

}

- (IBAction)btn_back:(id)sender {
    
    //[self.navigationController popViewControllerAnimated:YES];
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        AddMediaViewController *obj = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
    }
    else{
        AddMediaViewController *obj = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
        
    }

}

@end
