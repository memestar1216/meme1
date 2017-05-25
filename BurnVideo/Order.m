//
//  Order.m
//  BurnVideo
//
//  Created by user on 8/5/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "Order.h"

@implementation Order

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shippingArray = [NSMutableArray new];
    }
    return self;
}

- (NSString *)getDVDTitle
{
    if (self.title == nil || self.caption == nil) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@: %@", self.title, self.caption];
}

- (NSInteger)getTotalCount {
    NSInteger count = [self.mainShippingInfomation.count integerValue];
    for (ShippingInformation *info in self.shippingArray) {
        count += [info.count integerValue];
    }
    return count;
}

@end
