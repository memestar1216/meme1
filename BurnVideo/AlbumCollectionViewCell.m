//
//  AlbumCollectionViewCell.m
//  BurnVideo
//
//  Created by user on 8/3/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AlbumCollectionViewCell.h"

@implementation AlbumCollectionViewCell

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
}

@end
