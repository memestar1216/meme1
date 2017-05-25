//
//  DVDPersonalizeView.m
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "DVDPersonalizeView.h"
#import "Utils.h"

@implementation DVDPersonalizeView

- (void)awakeFromNib
{
    [self.tvCaption setPlaceholderColor:[UIColor grayColor]];
    UIColor *clr = [UIColor grayColor];
    self.tfDVDTitle.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"Enter DVD Title" attributes:@{NSForegroundColorAttributeName:clr}];
    [self addDoneButtonToKeyboardTextView:self.tvCaption];
    [self addDoneButtonToKeyboard:self.tfDVDTitle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onDone:(id)sender {
    NSInteger count = self.tfDVDTitle.text.length + self.tvCaption.text.length;
    if (count > 30) {
        [Utils showAlertView:@"Personalize DVD" message:@"Length of title and caption is too long." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    if (self.delegate) {
        [self.delegate personalizeView:self closedWithDone:YES];
    }
}
- (IBAction)onCancel:(id)sender {
    if (self.delegate) {
        [self.delegate personalizeView:self closedWithDone:NO];
    }
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

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger count = self.tfDVDTitle.text.length + self.tvCaption.text.length;
    [self.lbCharacCount setText:[NSString stringWithFormat:@"%lu/30", (unsigned long)count]];
    if (count > 30) {
        [self.lbCharacCount setTextColor:[UIColor redColor]];
    }else{
        [self.lbCharacCount setTextColor:[UIColor darkGrayColor]];
    }
}

- (IBAction)onTitleChanged:(id)sender {
    NSInteger count = self.tfDVDTitle.text.length + self.tvCaption.text.length;
    [self.lbCharacCount setText:[NSString stringWithFormat:@"%lu/30", (unsigned long)count]];
    if (count > 30) {
        [self.lbCharacCount setTextColor:[UIColor redColor]];
    }else{
        [self.lbCharacCount setTextColor:[UIColor darkGrayColor]];
    }

}

@end
