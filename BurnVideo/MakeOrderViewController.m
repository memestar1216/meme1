//
//  MakeOrderViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "MakeOrderViewController.h"

@interface MakeOrderViewController ()
@end

@implementation MakeOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrayforNoOfDVDs = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20", nil];
    result = [[UIScreen mainScreen] bounds].size;
    appdel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
    // Do any additional setup after loading the view from its nib.
    
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"AdditionalOrderView" owner:nil options:nil];
        self.additionOrderView = viewArray[1];
        self.personalizeView = viewArray[0];
    }else{
        NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"AdditionalOrderView_iPad" owner:self options:nil];
        self.additionOrderView = viewArray[1];
        self.personalizeView = viewArray[0];
    }
    
    [self addDoneButtonToKeyboard:self.text_firstName];
    [self addDoneButtonToKeyboard:self.text_lastName];
    [self addDoneButtonToKeyboard:self.text_City];
    [self addDoneButtonToKeyboard:self.text_State];
    [self addDoneButtonToKeyboard:self.text_zipCode];
    [self addDoneButtonToKeyboardTextView:self.text_address];
    self.text_State.text = @"AL";
    self.lbCount.text = @"1";
    self.text_address.placeholderColor = [UIColor grayColor];
    [self setColor];
    orderInfo = [[Order alloc] init];
    if (self.orderID) {
        orderInfo.previousOrder = self.orderID;
    }else{
        orderInfo.selectedMediaArray = [NSMutableDictionary new];
        int i = 0;
        for (SelectionObject *object in appdel.selectedArray) {
            if (object.status == SELECTED) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                if (object.isImage) {
                    [dic setObject:@"image" forKey:@"ftype"];
                }else{
                    [dic setObject:@"video" forKey:@"ftype"];
                }
                [dic setObject:[object.remoteFileURL copy] forKey:@"furl"];
                [dic setObject:@"" forKey:@"fname"];
                [dic setObject:[NSNumber numberWithInt:(int)object.duration] forKey:@"fplaytime"];
                [dic setObject:[NSNumber numberWithInt:object.mediaSpace] forKey:@"fweight"];
                [orderInfo.selectedMediaArray setObject:dic forKey:[NSNumber numberWithInt:i++]];
            }
        }
        orderInfo.selectedCount = [appdel getMediaSpace];
    }
    if (appdel.user) {
        ShippingInformation *shippingInfo = [[ShippingInformation alloc] init];
        [shippingInfo loadShippingInformation];
        self.text_firstName.text = appdel.user.firstName;
        self.text_lastName.text = appdel.user.lastName;
        self.text_address.text = appdel.user.streetAddress;
        self.text_City.text = appdel.user.city;
        self.text_State.text = appdel.user.state;
        self.text_zipCode.text = appdel.user.zipcode;
        if (shippingInfo.firstName) {
            self.text_firstName.text = shippingInfo.firstName;
        }
        if (shippingInfo.lastName) {
            self.text_lastName.text = shippingInfo.lastName;
        }
        if (shippingInfo.city) {
            self.text_City.text = shippingInfo.city;
        }
        if (shippingInfo.zipcode) {
            self.text_zipCode.text = shippingInfo.zipcode;
        }
        if (shippingInfo.streetAddress) {
            self.text_address.text = shippingInfo.streetAddress;
        }
        if (shippingInfo.state) {
            self.text_State.text = shippingInfo.state;
        }
    }
}

-(void)setColor{
    UIColor *clr = [UIColor grayColor];
    self.text_City.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"City" attributes:@{NSForegroundColorAttributeName:clr}];
    
    self.text_firstName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName:clr}];
    self.text_lastName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName:clr}];
    
    self.text_zipCode.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Zip Code" attributes:@{NSForegroundColorAttributeName:clr}];
    self.text_State.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"State" attributes:@{NSForegroundColorAttributeName:clr}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationsObservers];
    topConstraint = topLayoutConstraint.constant;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationsObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btn_anotherAddress:(id)sender {
    self.additionOrderView.delegate = self;
    self.additionOrderView.tfState.text = @"AL";
    self.additionOrderView.lbCount.text = @"1";
    
    self.additionOrderView.tfFirstName.delegate = self;
    self.additionOrderView.tfLastName.delegate = self;
    self.additionOrderView.tfCity.delegate = self;
    self.additionOrderView.tfZipcode.delegate = self;
    
    [self.additionOrderView setFrame:CGRectMake(0, 0, result.width, result.height)];
    [self lew_presentPopupView:self.additionOrderView animation:[LewPopupViewAnimationFade new] dismissed:^{
        
    }];
}

- (IBAction)btn_personalizeDVD:(id)sender {
    self.personalizeView.delegate = self;
    [self.personalizeView setFrame:CGRectMake(0, 0, result.width, result.height)];
    [self lew_presentPopupView:self.personalizeView animation:[LewPopupViewAnimationFade new] dismissed:^{
        
    }];
}
- (IBAction)onCountOfDVD:(id)sender {
    NSArray *numbers = @[@"1", @"2", @"3", @"4", @"5"
                         ,@"6", @"7", @"8", @"9", @"10"
                         ,@"11", @"12", @"13", @"14", @"15"
                         ,@"16", @"17", @"18", @"19", @"20"];
    NSLog(@"%@",self.lbCount.text);
 
    NSInteger index = [numbers indexOfObject:self.lbCount.text];
    if (index == NSNotFound) {
        index = 1;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select No. of DVDs" rows:numbers initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.lbCount.text = numbers[selectedIndex];
           NSLog(@"%@",self.lbCount.text);
          str=[[NSString alloc]initWithFormat:@"%@",self.lbCount.text];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}
- (IBAction)onState:(id)sender {
    NSArray *states = @[@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN", @"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN", @"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ", @"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY"];
    NSInteger index = [states indexOfObject:self.text_State.text];
    if (index == NSNotFound) {
        index = 0;
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select state" rows:states initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.text_State.text = states[selectedIndex];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:sender];
}

- (IBAction)btn_done:(id)sender {
    if (orderInfo.title == nil) {
        
       /*
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CompleteOrderViewController *destVC = [storyBoard instantiateViewControllerWithIdentifier:@"confirmorder"];
        
        
//        CompleteOrderViewController *destVC =segue.destinationViewController;
        ShippingInformation *shippinginfo = [[ShippingInformation alloc] init];
        shippinginfo.firstName = self.text_firstName.text;
        shippinginfo.lastName  = self.text_lastName.text;
        shippinginfo.streetAddress = self.text_address.text;
        shippinginfo.city = self.text_City.text;
        shippinginfo.state = self.text_State.text;
        shippinginfo.count = self.lbCount.text;
        shippinginfo.zipcode = self.text_zipCode.text;
        orderInfo.mainShippingInfomation = shippinginfo;
        destVC.orderInfo = orderInfo;
        
        
        
        
//        prod.arrForProducts=categoryObjfordidselewct.arrForCategoryProduct;
//        prod.str_titleLabel=categoryObjfordidselewct.categoryName;
        
        
        [self.navigationController pushViewController:destVC animated:YES];
    
        
       //    [self performSegueWithIdentifier:@"confirmorder" sender:self];
        */
        [Utils showAlertView:@"Order" message:@"Are you sure you do not want to personalize your DVD?" cancelButtonTitle:@"Yes" doneButtonTitle:@"No" alertHandle:^(UIAlertView *alertView, NSInteger index) {
            if (index) {
              
                return;
            }else{
                if (self.text_firstName.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_firstName.text.length < 2) {
                    [Utils showAlertView:@"Order" message:@"Please enter valid First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_lastName.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_lastName.text.length < 4) {
                    [Utils showAlertView:@"Order" message:@"Please enter valid Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_address.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_address.text.length < 8) {
                    [Utils showAlertView:@"Order" message:@"Please enter valid Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_City.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                
                if (self.text_City.text.length < 3) {
                    [Utils showAlertView:@"Order" message:@"Please enter valid City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                
                if (self.text_State.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter State" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (self.text_zipCode.text.length == 0) {
                    [Utils showAlertView:@"Order" message:@"Please enter Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                if (!(self.text_zipCode.text.length == 5)) {
                    [Utils showAlertView:@"Order" message:@"Please enter Valid Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    return;
                }
                
                [self performSegueWithIdentifier:@"confirmorder" sender:self];
                
              //  [self performSegueWithIdentifier:@"confirmorder" sender:self];
            }
        }];
    }else{
        if (self.text_firstName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_firstName.text.length < 2) {
            [Utils showAlertView:@"Order" message:@"Please enter valid First Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_lastName.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_lastName.text.length < 4) {
            [Utils showAlertView:@"Order" message:@"Please enter valid Last Name" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_address.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_address.text.length < 8) {
            [Utils showAlertView:@"Order" message:@"Please enter valid Street Address" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_City.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_City.text.length < 3) {
            [Utils showAlertView:@"Order" message:@"Please enter valid City" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        
        if (self.text_State.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter State" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (self.text_zipCode.text.length == 0) {
            [Utils showAlertView:@"Order" message:@"Please enter Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        if (!(self.text_zipCode.text.length == 5)) {
            [Utils showAlertView:@"Order" message:@"Please enter Valid Zipcode" cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            return;
        }
        
        [self performSegueWithIdentifier:@"confirmorder" sender:self];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==100) {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField.tag==101)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.text_City)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField.tag==106)
    {
        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterNoStyle];
        
        NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber * number = [nf numberFromString:newString];
        
        if (number){
            if (newString.length > 5) {
                return NO;
            }
            return YES;
        }else{
            return NO;
        }
    }else if (textField == self.additionOrderView.tfFirstName) {
        
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        
        return canEdit;
    }
    else if (textField == self.additionOrderView.tfLastName)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.additionOrderView.tfCity)
    {
        BOOL canEdit=NO;
        
        if (string.length == 0) {
            return YES;
        }
        
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                canEdit=NO;
            }
            else
            {
                canEdit=YES;
            }
        }
        return canEdit;
    }
    else if (textField == self.additionOrderView.tfZipcode)
    {
        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterNoStyle];
        
        NSString * newString = [NSString stringWithFormat:@"%@%@",textField.text,string];
        NSNumber * number = [nf numberFromString:newString];
        
        if (number){
            if (newString.length > 5) {
                return NO;
            }
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}
- (void)personalizeView:(UIView *)view closedWithDone:(BOOL)isDone
{
    [self lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
    if (isDone) {
        orderInfo.title = self.personalizeView.tfDVDTitle.text;
        orderInfo.caption = self.personalizeView.tvCaption.text;
    }else{
        orderInfo.title = @"";
        orderInfo.caption = @"";
    }
}

- (void)additionOrderView:(UIView *)view closedWithDone:(BOOL)isDone
{
    [self lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
    if (isDone) {
        ShippingInformation *shippinginfo = [[ShippingInformation alloc] init];
        shippinginfo.firstName = self.additionOrderView.tfFirstName.text;
        shippinginfo.lastName  = self.additionOrderView.tfLastName.text;
        shippinginfo.streetAddress = self.additionOrderView.tvStreet.text;
        shippinginfo.city = self.additionOrderView.tfCity.text;
        shippinginfo.state = self.additionOrderView.tfState.text;
        shippinginfo.count = self.additionOrderView.lbCount.text;
        shippinginfo.zipcode = self.additionOrderView.tfZipcode.text;
        [orderInfo.shippingArray addObject:shippinginfo];
        [self.btnAdditionalOrder setSelected:true];        
    }
    self.additionOrderView.tfFirstName.text = @"";
    self.additionOrderView.tfLastName.text = @"";
    self.additionOrderView.tvStreet.text = @"";
    self.additionOrderView.tfCity.text = @"";
    self.additionOrderView.tfState.text = @"AL";
    self.additionOrderView.lbCount.text = @"1";
    self.additionOrderView.tfZipcode.text = @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmorder"]) {
        CompleteOrderViewController *destVC =segue.destinationViewController;
        ShippingInformation *shippinginfo = [[ShippingInformation alloc] init];
        shippinginfo.firstName = self.text_firstName.text;
        shippinginfo.lastName  = self.text_lastName.text;
        shippinginfo.streetAddress = self.text_address.text;
        shippinginfo.city = self.text_City.text;
        shippinginfo.state = self.text_State.text;
        shippinginfo.count = self.lbCount.text;
        shippinginfo.zipcode = self.text_zipCode.text;
        orderInfo.mainShippingInfomation = shippinginfo;
        destVC.orderInfo = orderInfo;
    }
}

//textfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

- (void) addNotificationsObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeNotificationsObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

#define MORE_HEIGHT 80

- (void) keyboardWillShow:(NSNotification*) notification {
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self.view];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    // Use this view's coordinate system
    CGRect keyboardBounds = [self.view convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGRect firstResponderFrame = [firstResponder convertRect:firstResponder.bounds toView:self.view];
    CGFloat textbottom = CGRectGetMaxY(firstResponderFrame);
    
    CGFloat currentDiff = topLayoutConstraint.constant - topConstraint;
    
    CGFloat diff = textbottom - keyboardBounds.origin.y + MORE_HEIGHT;
    
    diff = MAX(currentDiff, diff);
    
    if (diff == 0) {
        return;
    }
    
    // Shrink view's height by the keyboard's height, and scroll to show the text field/view being edited
    topLayoutConstraint.constant = topLayoutConstraint.constant - diff;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification*) notification {
    // Restore dimensions to prior size
    
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    topLayoutConstraint.constant = topConstraint;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void) addDoneButtonToKeyboard:(UITextField*) textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

- (void) addDoneButtonToKeyboardTextView:(UITextView*) textView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:textView action:@selector(resignFirstResponder)];
    [toolbar setItems:@[leftSpace, doneButton] animated:false];
    textView.inputAccessoryView = toolbar;
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *resultview = [self findFirstResponderBeneathView:childView];
        if (resultview) return resultview;
    }
    return nil;
}

@end
