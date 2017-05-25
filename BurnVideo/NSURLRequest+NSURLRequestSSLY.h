//
//  NSURLRequest+NSURLRequestSSLY.h
//  BurnVideo
//
//  Created by JAIMINI on 10/25/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest_NSURLRequestSSLY : NSURLRequest
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

@end
