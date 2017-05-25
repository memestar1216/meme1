//
//  AdditionalOrderView.h
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPlaceholderTextView.h"
#import "ShippingInformation.h"

@protocol AdditionOrderDelegate <NSObject>

- (void) additionOrderView:(UIView*) view closedWithDone:(BOOL) isDone;

@end

@interface AdditionalOrderView : UIView
@property (weak, nonatomic) IBOutlet UIView *whiteBackView;
@property (weak, nonatomic) IBOutlet UITextField *tfFirstName;
@property (weak, nonatomic) IBOutlet UITextField *tfLastName;
@property (weak, nonatomic) IBOutlet UITextField *tfZipcode;
@property (weak, nonatomic) IBOutlet UITextField *tfCity;
@property (weak, nonatomic) IBOutlet LPlaceholderTextView *tvStreet;
@property (weak, nonatomic) IBOutlet UITextField *tfState;
@property (weak, nonatomic) IBOutlet UILabel *lbCount;

- (IBAction)onDVDCount:(id)sender;

@property (weak, nonatomic) IBOutlet id<AdditionOrderDelegate> delegate;

+ (AdditionalOrderView*)loadOrderSettingView:(ShippingInformation*) shippingInfo;

@end
