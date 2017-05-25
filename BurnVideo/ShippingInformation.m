//
//  ShippingInfomation.m
//  BurnVideo
//
//  Created by user on 8/6/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "ShippingInformation.h"
#import "SettingManager.h"
#import "AppDelegate.h"

#define SHIPPING_KEY_FIRSTNAME @"shipping_firstname"
#define SHIPPING_KEY_LASTNAME @"shipping_lastname"
#define SHIPPING_KEY_STREETADDRESS @"shipping_streetaddress"
#define SHIPPING_KEY_CITY @"shipping_city"
#define SHIPPING_KEY_ZIPCODE @"shipping_zipcode"
#define SHIPPING_KEY_STATE @"shipping_state"

#define SHIPPING_KEY_OBJECT @"shipping_object"

@implementation ShippingInformation

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadShippingInformation {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *shippingkey = [NSString stringWithFormat:@"%@_%@", SHIPPING_KEY_OBJECT, uid];
    NSDictionary *dic = (NSDictionary*)[SettingManager objectWithKey:shippingkey];
    if (dic) {
        self.firstName = dic[@"firstname"];
        self.lastName = dic[@"lastname"];
        self.streetAddress = dic[@"street"];
        self.city = dic[@"city"];
        self.zipcode = dic[@"zipcode"];
        self.state = dic[@"state"];
    }
}

- (void) save {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *shippingkey = [NSString stringWithFormat:@"%@_%@", SHIPPING_KEY_OBJECT, uid];
    [SettingManager setObject:[self toDictionary] withKey:shippingkey];
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:(self.firstName?self.firstName:@"") forKey:@"firstname"];
    [dic setObject:(self.lastName?self.lastName:@"") forKey:@"lastname"];
    [dic setObject:(self.streetAddress?self.streetAddress:@"") forKey:@"street"];
    [dic setObject:(self.city?self.city:@"") forKey:@"city"];
    [dic setObject:(self.state?self.state:@"") forKey:@"state"];
    [dic setObject:(self.zipcode?self.zipcode:@"") forKey:@"zipcode"];
    [dic setObject:(self.count?self.count:@"") forKey:@"count"];
    return dic;
}

- (NSString *)information
{
    if (self.firstName == nil
        || self.lastName == nil
        || self.streetAddress == nil
        || self.city == nil
        || self.zipcode == nil
        || self.state == nil)
        return @"";
    return [NSString stringWithFormat:@"%@ %@\r%@, %@, %@, %@", self.firstName, self.lastName, self.streetAddress, self.city, self.state, self.zipcode];
}

@end
