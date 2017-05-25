//
//  PaymentDetailViewController.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Braintree.h"

@interface PaymentDetailViewController : UIViewController<BTPaymentMethodCreationDelegate>
@property (strong, nonatomic) IBOutlet UITextView *text_detailMsg;
@property (strong, nonatomic) IBOutlet UITextField *text_creditCard;
@property (strong, nonatomic) IBOutlet UITextField *text_securityCode;
@property (strong, nonatomic) IBOutlet UITextField *text_nameoncard;
@property (strong, nonatomic) IBOutlet UITextField *text_expDate;

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *provider;

@end
