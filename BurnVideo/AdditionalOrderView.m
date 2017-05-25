//
//  AdditionalOrderView.m
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AdditionalOrderView.h"

#import "ActionSheetStringPicker.h"
#import "Utils.h"

@implementation AdditionalOrderView

+ (AdditionalOrderView*)loadOrderSettingView:(ShippingInformation*) shippingInfo {
    AdditionalOrderView *view;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        view = (AdditionalOrderView*)[[NSBundle mainBundle] loadNibNamed:@"AdditionalOrderView" owner:self options:nil][1];
    }else{
        view = (AdditionalOrderView*)[[NSBundle mainBundle] loadNibNamed:@"AdditionalOrderView_iPad" owner:self options:nil][1];
    }
    if (shippingInfo) {
        view.tfFirstName.text = shippingInfo.firstName;
        view.tfLastName.text = shippingInfo.lastName;
        view.tvStreet.text = shippingInfo.streetAddress;
        view.tfCity.text = shippingInfo.city;
        view.tfState.text = shippingInfo.state;
        view.tfZipcode.text = shippingInfo.zipcode;
        view.lbCount.text = shippingInfo.count;
    }
    
    return view;
}

- (void)awakeFromNib
{
    self.tvStreet.placeholderColor = [UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1];
    self.whiteBackView.layer.cornerRadius = 5;
    [self addDoneButtonToKeyboard:self.tfFirstName];
    [self addDoneButtonToKeyboard:self.tfLastName];
    [self addDoneButtonToKeyboard:self.tfCity];
    [self addDoneButtonToKeyboard:self.tfState];
    [self addDoneButtonToKeyboard:self.tfZipcode];
    [self addDoneButtonToKeyboardTextView:self.tvStreet];
}

- (void) addDoneButtonToKeyboard:(UITextField*) textView
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

- (void) addDoneButtonToKeyboardTextView:(UITextView*) textView
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onDone:(id)sender {
    if (self.delegate) {
        /*
        if (self.tfFirstName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfLastName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tvStreet.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfCity.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfState.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter State" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfZipcode.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        */
        
        if (self.tfFirstName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfFirstName.text.length < 2) {
            [Utils showAlertView:@"Order" message:@"Please enter valid First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfLastName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfLastName.text.length < 4) {
            [Utils showAlertView:@"Order" message:@"Please enter valid Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tvStreet.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tvStreet.text.length <= 8) {
            [Utils showAlertView:@"Order" message:@"Please enter valid Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfCity.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfCity.text.length < 3) {
            [Utils showAlertView:@"Order" message:@"Please enter valid City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        
        if (self.tfState.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter State" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.tfZipcode.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (!(self.tfZipcode.text.length == 5)) {
            [Utils showAlertView:@"Order" message:@"Please enter Valid Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        
        [self.delegate additionOrderView:self closedWithDone:YES];
    }
}

- (IBAction)onCancel:(id)sender {
    [self.delegate additionOrderView:self closedWithDone:NO];
}

- (IBAction)onDVDCount:(id)sender {
    NSArray *numbers = @[@"1", @"2", @"3", @"4", @"5"
                         ,@"6", @"7", @"8", @"9", @"10"
                         ,@"11", @"12", @"13", @"14", @"15"
                         ,@"16", @"17", @"18", @"19", @"20"];
    NSInteger index = [numbers indexOfObject:self.lbCount.text];
    if (index == NSNotFound) {
        index = 1;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select No. of DVDs" rows:numbers initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.lbCount.text = numbers[selectedIndex];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}
- (IBAction)onState:(id)sender {
    NSArray *states = @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"];
    NSInteger index = [states indexOfObject:self.tfState.text];
    if (index == NSNotFound) {
        index = 0;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select state" rows:states initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.tfState.text = states[selectedIndex];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}

@end
