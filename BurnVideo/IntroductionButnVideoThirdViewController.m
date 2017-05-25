//
//  IntroductionButnVideoThirdViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "IntroductionButnVideoThirdViewController.h"
#import "IntroductionButnVideoLastViewController.h"

@interface IntroductionButnVideoThirdViewController ()

@end

@implementation IntroductionButnVideoThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn_forward:(id)sender {
    
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){

    IntroductionButnVideoLastViewController * obj = [[IntroductionButnVideoLastViewController alloc]initWithNibName:@"IntroductionButnVideoLastViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
        
    }
    
    else{
        IntroductionButnVideoLastViewController * obj = [[IntroductionButnVideoLastViewController alloc]initWithNibName:@"IntroductionButnVideoLastViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];

    }

}


- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            
            IntroductionButnVideoLastViewController * obj = [[IntroductionButnVideoLastViewController alloc]initWithNibName:@"IntroductionButnVideoLastViewController" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
            
        }
        
        else{
            IntroductionButnVideoLastViewController * obj = [[IntroductionButnVideoLastViewController alloc]initWithNibName:@"IntroductionButnVideoLastViewController_iPad" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
            
        }
        
    }
    
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


@end
