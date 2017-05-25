//
//  User.h
//  BurnVideo
//
//  Created by user on 8/10/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *streetAddress;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *zipcode;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *customerid;
@property (nonatomic) BOOL hasFreeDVD;
@property (nonatomic) NSDate *monthlyDate;

- (id) initWithDictionary:(NSDictionary*) dic;

- (NSString*) information;

- (NSString*) getMonthlyDateString;

@end
