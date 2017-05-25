//
//  AlbumSelectionCollectionViewCell.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumSelectionCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *folderImgView;
@property (strong, nonatomic) IBOutlet UILabel *folderNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *btncheckbox;

@end
