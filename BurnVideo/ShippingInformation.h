//
//  ShippingInfomation.h
//  BurnVideo
//
//  Created by user on 8/6/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShippingInformation : NSObject

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *streetAddress;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *zipcode;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *count;

- (void) loadShippingInformation;
- (void) save;
- (NSMutableDictionary*) toDictionary;

- (NSString *)information;

@end
