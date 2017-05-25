//
//  VideoSelectionViewController.h
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *selectMediaView;
@property(strong, nonatomic)NSMutableArray *arrayForCheckUncheck, *groupName , *array ;
@property (strong, nonatomic) NSArray *arrayForFolderImages;

@property(strong, nonatomic)NSMutableDictionary *alldata;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
- (void) selectAlbum:(NSString *) albumUrl;

@end
