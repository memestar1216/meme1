//
//  DVDPersonalizeView.h
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LPlaceholderTextView.h"

@protocol DVDPersonalizeDelegate <NSObject>

- (void) personalizeView:(UIView*) view closedWithDone:(BOOL) isDone;

@end

@interface DVDPersonalizeView : UIView<UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfDVDTitle;
@property (weak, nonatomic) IBOutlet LPlaceholderTextView *tvCaption;
@property (weak, nonatomic) IBOutlet UILabel *lbCharacCount;

@property (weak, nonatomic) IBOutlet id<DVDPersonalizeDelegate> delegate;

@end
