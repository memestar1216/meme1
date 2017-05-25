//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KT2KeyboardAvoidingScrollViewDelegate <UIScrollViewDelegate>

-(void)resignResponder;

@end

@interface KT2KeyboardAvoidingScrollView : UIScrollView {
    CGRect priorFrame;
}

@property (assign, nonatomic) id <KT2KeyboardAvoidingScrollViewDelegate,UIScrollViewDelegate>
delegate;



@end
