//
//  AboutBurnVideoSecondViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 12/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AboutBurnVideoSecondViewController.h"

@interface AboutBurnVideoSecondViewController ()

@end

@implementation AboutBurnVideoSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
