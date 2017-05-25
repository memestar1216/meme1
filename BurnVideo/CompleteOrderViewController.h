//
//  CompleteOrderViewController.h
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Order.h>

@interface CompleteOrderViewController : UIViewController<UITextFieldDelegate,NSURLConnectionDelegate>
{
    float totalValuecalculated ;

    float totalValue ;
    UIButton *_btn1;
    NSString *str_promocode;
    bool applyOrNot;
}
@property (weak, nonatomic) IBOutlet UILabel *lbMainCount;
@property (weak, nonatomic) IBOutlet UILabel *lbMainAddress;
@property (weak, nonatomic) IBOutlet UILabel *lbSubCount;
@property (weak, nonatomic) IBOutlet UILabel *lbSubAddress;

@property (nonatomic) Order *orderInfo;
@property (weak, nonatomic) IBOutlet UIView *subOrderView;
@property (weak, nonatomic) IBOutlet UIView *mainviews;
@property (weak, nonatomic) IBOutlet UITableView *tblOrder;
@property (weak, nonatomic) IBOutlet UIButton *btn_promocode;

@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (weak, nonatomic) IBOutlet UILabel *lbConfirm;
//- (IBAction)btn_promocode:(id)sender;

@end 
