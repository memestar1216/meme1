//
//  BVHomePageViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "BVHomePageViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "IntroductionBurnVideoViewController.h"

@interface BVHomePageViewController ()

@end

@implementation BVHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_existingcustomer:(id)sender {
    NSLog(@"muraree");
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPad" bundle:nil];
        
        [self.navigationController pushViewController:controller animated:YES];

    }
    
    
    
}
- (IBAction)btn_newCustomer:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        IntroductionBurnVideoViewController *controller = [[IntroductionBurnVideoViewController alloc] initWithNibName:@"IntroductionBurnVideoViewController" bundle:nil];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
    else{
    IntroductionBurnVideoViewController *controller = [[IntroductionBurnVideoViewController alloc] initWithNibName:@"IntroductionBurnVideoViewController_iPad" bundle:nil];
        
        [self.navigationController pushViewController:controller animated:YES];
        
    }


}




@end
