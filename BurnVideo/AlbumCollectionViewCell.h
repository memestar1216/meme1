//
//  AlbumCollectionViewCell.h
//  BurnVideo
//
//  Created by user on 8/3/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewCell : UICollectionViewCell
{
    BOOL isSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imvContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imvCheckView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitleView;
@end
