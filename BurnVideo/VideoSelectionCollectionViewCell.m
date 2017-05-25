//
//  VideoSelectionCollectionViewCell.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "VideoSelectionCollectionViewCell.h"


@implementation VideoSelectionCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (void) setAsset:(ALAsset *)asset
{
    // 2
    _asset = asset;
    self.videoImgView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    
}

@end
