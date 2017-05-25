//
//  ShippingTableViewCell.h
//  BurnVideo
//
//  Created by user on 8/16/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShippingTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbDVDCount;
@property (strong, nonatomic) IBOutlet UIButton *btnRemove;
//@property (strong, nonatomic) IBOutlet UITextView *lbAddress;
@property (strong, nonatomic) IBOutlet UIButton *btnEdit;
@property (strong, nonatomic) IBOutlet UIView *view_bg;


@end
