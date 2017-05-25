//
//  OrderTableViewCell.h
//  BurnVideo
//
//  Created by user on 8/3/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbOrderID;
@property (weak, nonatomic) IBOutlet UILabel *lbDVDTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbCount;
@property (weak, nonatomic) IBOutlet UILabel *lbOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *lbShippingDate;
@property (weak, nonatomic) IBOutlet UIButton *btnReburn;

@end
