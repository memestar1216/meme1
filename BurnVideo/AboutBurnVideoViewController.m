//
//  AboutBurnVideoViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AboutBurnVideoViewController.h"

@interface AboutBurnVideoViewController ()
@property (strong, nonatomic) IBOutlet UITextView *infoTextView;

@end

@implementation AboutBurnVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *htmlString = @"<center><font size=5><p> Signing up is free and you are never</p><p>charged until you place your first</p><p>order with Burn Video</p></font></center>";
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//    self.text_detailMsg.attributedText = attributedString;
//    self.text_detailMsg.textColor = [UIColor whiteColor];
    
//    NSString *htmlString = @"<left><big><font  size= '6.99' face = 'Century Gothic' ><p align = 'justify'> Burn Video is a subscription service that delivers your phone, tablet or personal computer's videos and photos to you on a custom-labeled DVD every month.</p><p align = 'justify'>You select up to 40 media spaces that get burned onto a DVD and then you choose a custom title and caption that will be colorfully printed onto the DVD.</p><p align = 'justify'>This is great way to view, preserve and share your precious memories month after month.</font></big></left>";
//    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//            self.infoTextView.attributedText = attributedString;
//        self.infoTextView.textColor = [UIColor blackColor];
//
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btn_back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
