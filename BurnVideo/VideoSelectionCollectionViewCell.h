//
//  VideoSelectionCollectionViewCell.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoSelectionCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *checkboxImgView;
@property (strong, nonatomic) IBOutlet UIImageView *videoImgView;
@property (strong, nonatomic) IBOutlet UIButton *checkBoxButton;
@property(nonatomic, strong) ALAsset *asset;
@end
