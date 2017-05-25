//
//  AccountSummaryViewController.h
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Braintree.h"

@interface AccountSummaryViewController : UIViewController<BTPaymentMethodCreationDelegate>
@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *provider;
@end
