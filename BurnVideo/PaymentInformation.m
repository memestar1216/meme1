//
//  PaymentInfomation.m
//  BurnVideo
//
//  Created by user on 8/6/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "PaymentInformation.h"
#import "SettingManager.h"

#import "AFNetworking.h"
#import "Common.h"

#define PAYMENT_KEY_CREDITCARDNO @"payment_creditcard"
#define PAYMENT_KEY_NAMEONCARD @"payment_nameoncard"
#define PAYMENT_KEY_EXPDATE @"payment_expdate"
#define PAYMENT_KEY_SECURITYCODE @"payment_securitycode"

#define PAYMENT_KEY_OBJECT @"payment_object"

@implementation PaymentInformation

- (void) loadPaymentInformation {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *shippingkey = [NSString stringWithFormat:@"%@_%@", PAYMENT_KEY_OBJECT, uid];
    NSDictionary *dic = (NSDictionary*)[SettingManager objectWithKey:shippingkey];
    if (dic) {
        self.creditCardNo = dic[@"creditCardNo"];
        self.nameOnCard = dic[@"nameOnCard"];
        self.expDate = dic[@"expDate"];
        self.securityCode = dic[@"securityCode"];
    }
}

- (void) save {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *shippingkey = [NSString stringWithFormat:@"%@_%@", PAYMENT_KEY_OBJECT, uid];
    NSDictionary *dic = [self toDictionary];
    if (dic) {
        [SettingManager setObject:dic withKey:shippingkey];
    }else{
        [SettingManager removeObjectForKey:shippingkey];
    }
}

- (NSMutableDictionary *)toDictionary {
    if (self.creditCardNo == nil
        || self.nameOnCard == nil
        || self.expDate == nil
        || self.securityCode == nil)
        return nil;
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:self.creditCardNo forKey:@"creditCardNo"];
    [dic setObject:self.nameOnCard forKey:@"nameOnCard"];
    [dic setObject:self.expDate forKey:@"expDate"];
    [dic setObject:self.securityCode forKey:@"securityCode"];
    return dic;
}

- (void)createCustomerAndFetchClientTokenWithCompletion:(void (^)(NSString *, NSError *))completionBlock {
    
    AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSString *token = [SettingManager stringValueWithKey:SETTING_KEY_TOKEN];
    
    
    NSDictionary *dic = @{@"token":token
                          , @"uid":uid};
    
    [man POST:@"GetBTClientToken" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary*) responseObject;
            int retCode = [[dic objectForKey:@"retCode"] intValue];
            if (retCode == 0) {
                completionBlock(responseObject[@"btClientToken"], nil);
            }else {
                completionBlock(nil, nil);
                return;
            }
        }else{
            completionBlock(nil, nil);
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
}

@end
