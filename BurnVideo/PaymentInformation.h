//
//  PaymentInfomation.h
//  BurnVideo
//
//  Created by user on 8/6/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentInformation : NSObject

@property (nonatomic) NSString *creditCardNo;
@property (nonatomic) NSString *nameOnCard;
@property (nonatomic) NSString *expDate;
@property (nonatomic) NSString *securityCode;

- (void) loadPaymentInformation;
- (void) save;
- (NSMutableDictionary*) toDictionary;

@end
