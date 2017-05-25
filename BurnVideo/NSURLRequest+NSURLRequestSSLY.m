//
//  NSURLRequest+NSURLRequestSSLY.m
//  BurnVideo
//
//  Created by JAIMINI on 10/25/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "NSURLRequest+NSURLRequestSSLY.h"

@implementation NSURLRequest_NSURLRequestSSLY
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}


@end
