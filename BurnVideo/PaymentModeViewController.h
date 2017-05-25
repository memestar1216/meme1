//
//  PaymentModeViewController.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Braintree.h"
#import <PassKit/PassKit.h>

@interface PaymentModeViewController : UIViewController<BTPaymentMethodCreationDelegate>

@property (nonatomic, strong) Braintree *braintree;

@property (nonatomic, strong) BTPaymentProvider *provider;

@end
