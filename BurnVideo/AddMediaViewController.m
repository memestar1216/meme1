//
//  AddMediaViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AddMediaViewController.h"
#import "VideoSelectionViewController.h"
#import "MakeOrderViewController.h"
#import "SettingViewController.h"
#import  "AppDelegate.h"
#import "VideoSelectionByFolderViewController.h"

#import "SettingManager.h"
#import "Utils.h"
#import "Common.h"

@interface AddMediaViewController (){
    AppDelegate *appdel;
    __weak IBOutlet UILabel *lbTitle;
}

@end

@implementation AddMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appdel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
    appdel.mainVC = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger count = [SettingManager integerValueWithKey:SETTING_KEY_MEDIACOUNT];
    if (count == 0) {
        [lbTitle setText:@"SELECT MEDIA SPACES"];
    }else{
        [lbTitle setText:[NSString stringWithFormat:@"%ld of %d Media Spaces Uploaded", (long)count, MEDIA_COUNT]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_AddOrRmvMedia:(id)sender {
    appdel.identifierForFolderAndAllImages = 1;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    VideoSelectionViewController *obj = [[VideoSelectionViewController alloc]initWithNibName:@"VideoSelectionViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        VideoSelectionViewController *obj = [[VideoSelectionViewController alloc]initWithNibName:@"VideoSelectionViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    
}
- (IBAction)btn_order:(id)sender {
    appdel.titleIdentifier =1;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    MakeOrderViewController *obj = [[MakeOrderViewController alloc]initWithNibName:@"MakeOrderViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        MakeOrderViewController *obj = [[MakeOrderViewController alloc]initWithNibName:@"MakeOrderViewCotroller_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}
- (IBAction)btn_information:(id)sender {
    appdel.titleIdentifier =0;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    SettingViewController *obj = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        SettingViewController *obj = [[SettingViewController alloc]initWithNibName:@"SettingViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}

- (IBAction)btn_forward:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        VideoSelectionByFolderViewController *obj = [[VideoSelectionByFolderViewController alloc]initWithNibName:@"VideoSelectionByFolderViewController" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
    else{
        VideoSelectionByFolderViewController *obj = [[VideoSelectionByFolderViewController alloc]initWithNibName:@"VideoSelectionByFolderViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"createorder"]) {
        if ([SettingManager integerValueWithKey:SETTING_KEY_MEDIACOUNT] == 0) {
            [Utils showAlertView:@"Order" message:@"Please select media." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return false;
        }else{
            if ([appdel checkAllUploaded]) {
                if (appdel.user.monthlyDate == nil || appdel.user.hasFreeDVD) {
                    return true;
                }else{
                    if (self.oneTimeOrder) {
                        self.oneTimeOrder = false;
                        return true;
                    }
                    
                    /*
                    [Utils showAlertView:@"Order" message:@"You are placing an order before your next due date. This will be a one-time order. Do you wish to proceed?" cancelButtonTitle:@"Cancel" doneButtonTitle:@"OK" alertHandle:^(UIAlertView *alertView, NSInteger index) {
                        if (index) {
                            self.oneTimeOrder = true;
                            [self performSegueWithIdentifier:@"createorder" sender:self];
                        }
                    }];
                     */
                    
                    self.oneTimeOrder = true;
                    [self performSegueWithIdentifier:@"createorder" sender:self];
                    return false;
                     
                }
            }else{
                [Utils showAlertView:@"Order" message:@"Some files are still uploading. Please wait one moment before you continue." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                return false;
            }
        }
        return true;
    }
    if ([identifier isEqualToString:@"videoselection"]) {
        NSArray *selectedLibrary = (NSArray*)[SettingManager objectWithKey:SETTING_KEY_ASSETGROUPS];
        if (selectedLibrary == nil || selectedLibrary.count == 0) {
            [Utils showAlertView:@"Select Media" message:@"There is no Selected Album. Please select Album." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:^(UIAlertView *alertView, NSInteger index) {
                [self performSegueWithIdentifier:@"showSelectAlbum" sender:self];
            }];            
            return false;
        }
    }
    return true;
}


@end
