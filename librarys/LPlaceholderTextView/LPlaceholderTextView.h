//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPlaceholderTextView : UITextView
{
    UILabel *_placeholderLabel;
}


@property (strong, nonatomic) IBInspectable NSString *placeholderText;
@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;


@end