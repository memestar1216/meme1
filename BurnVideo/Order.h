//
//  Order.h
//  BurnVideo
//
//  Created by user on 8/5/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShippingInformation.h"
#import "PaymentInformation.h"

@interface Order : NSObject

@property (nonatomic) NSMutableDictionary *selectedMediaArray;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic) ShippingInformation *mainShippingInfomation;
@property (nonatomic) NSMutableArray *shippingArray;
@property (nonatomic) NSInteger totalCount;
@property (nonatomic) PaymentInformation *paymentInformation;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *caption;
@property (nonatomic, copy) NSString *previousOrder;

- (NSString*) getDVDTitle;
- (NSInteger) getTotalCount;

@end
