//
//  BillingInformationViewController.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Braintree.h"

@interface BillingInformationViewController : UIViewController<BTPaymentMethodCreationDelegate>
@property (strong, nonatomic) IBOutlet UIView *addNewCreditCardView;

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *provider;
@end
