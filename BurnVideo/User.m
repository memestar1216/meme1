
#//
//  User.m
//  BurnVideo
//
//  Created by user on 8/10/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithDictionary:(NSDictionary*) dic {
    self = [self init];
    if (self) {
        self.city = dic[@"city"];
        self.state = dic[@"state"];
        self.zipcode = dic[@"zipcode"];
        self.email = dic[@"email"];
        self.name = [NSString stringWithFormat:@"%@ %@", dic[@"first_name"], dic[@"last_name"]];
        self.firstName = dic[@"first_name"];
        self.lastName = dic[@"last_name"];
        self.streetAddress = dic[@"street"];
        if (dic[@"customer_id"] && ![dic[@"customer_id"] isKindOfClass:[NSNull class]]) {
            self.customerid = dic[@"customer_id"];
        }        
//        self.mediaSpace = ((dic[@"mon_weight"] && ![dic[@"mon_weight"] isKindOfClass:[NSNull class]])?[dic[@"mon_weight"] intValue]:40);
        
        if (dic[@"mon_freedvd"] && [dic[@"mon_freedvd"] integerValue]) {
            self.hasFreeDVD = true;
        }else{
            self.hasFreeDVD = false;
        }
        
        if (dic[@"mon_nextday"] && [dic[@"mon_nextday"] isKindOfClass:[NSString class]]) {
            NSDateFormatter *fromformatter = [[NSDateFormatter alloc] init];
            fromformatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            self.monthlyDate = [fromformatter dateFromString:dic[@"mon_nextday"]];
            if (self.monthlyDate == nil) {
                self.monthlyDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"mon_nextday"] doubleValue]];
            }
        }else if(dic[@"mon_nextday"] && [dic[@"mon_nextday"] isKindOfClass:[NSNumber class]]){
            self.monthlyDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"mon_nextday"] doubleValue]];
        }else{
            self.monthlyDate = nil;
        }
    }
    return self;
}

- (NSString *)information
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", self.name, self.streetAddress, self.city, self.state,self.zipcode];
}

- (NSString *)getMonthlyDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *lastDate;
    if (self.monthlyDate) {
        lastDate = [dateFormatter stringFromDate:self.monthlyDate];
    }else{
        NSDate *nextMonthlyDate = [NSDate dateWithTimeInterval:2592000 sinceDate:[NSDate date]];
        lastDate = [dateFormatter stringFromDate:nextMonthlyDate];
    }
    return lastDate;
}

@end
