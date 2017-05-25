//
//  MakeOrderViewController.h
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVDPersonalizeView.h"
#import "AdditionalOrderView.h"
#import "LPlaceholderTextView.h"
#import "CompleteOrderViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "NoOfDVDTableViewCell.h"

#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "ActionSheetStringPicker.h"
#import "Order.h"
#import "Utils.h"
#import "SettingManager.h"
#import "ShippingInformation.h"
#import "SelectionObject.h"

@interface MakeOrderViewController : UIViewController<AdditionOrderDelegate, DVDPersonalizeDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIPopoverPresentationControllerDelegate>
{
    NSString *str;
    AppDelegate *appdel;
    CGSize result;
    int personalizeIdentifier;
    NSArray *arrayforNoOfDVDs;
    
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    CGFloat topConstraint;
    Order *orderInfo;
}
@property (strong, nonatomic) IBOutlet UITextField *text_firstName;
@property (strong, nonatomic) IBOutlet UITextField *text_lastName;
@property (strong, nonatomic) IBOutlet LPlaceholderTextView *text_address;
@property (strong, nonatomic) IBOutlet UITextField *text_City;
@property (strong, nonatomic) IBOutlet UITextField *text_State;
@property (strong, nonatomic) IBOutlet UITextField *text_zipCode;
@property (weak, nonatomic) IBOutlet UILabel *lbCount;
@property (weak, nonatomic) IBOutlet UIButton *btnAdditionalOrder;
@property (strong, nonatomic) IBOutlet DVDPersonalizeView *personalizeView;
@property (strong, nonatomic) IBOutlet AdditionalOrderView *additionOrderView;

@property (strong, nonatomic) NSString *orderID;

@end
