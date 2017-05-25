//
//  MediaCollectionViewCell.h
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCollectionViewCell : UICollectionViewCell
{
    BOOL isSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *imvContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imvCheckView;
@property (weak, nonatomic) IBOutlet UIImageView *imvVideo;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *uploadedMark;
@property (weak, nonatomic) IBOutlet UILabel *lbTitleView;
@end
