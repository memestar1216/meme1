//
//  MediaCollectionViewCell.m
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "MediaCollectionViewCell.h"

@implementation MediaCollectionViewCell
- (void)setSelected:(BOOL)selected
{
    isSelected = selected;
    [self.imvCheckView setHighlighted:selected];
}

- (BOOL)isSelected
{
    return isSelected;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imvCheckView setHighlighted:NO];
    isSelected = false;
    self.imvVideo.hidden = true;
    self.progressView.hidden = true;
    self.progressView.progress = 0;
    self.uploadedMark.hidden = true;
}

@end
