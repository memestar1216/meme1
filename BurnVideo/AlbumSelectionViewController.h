//
//  AlbumSelectionViewController.h
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AlbumSelectionViewController : UIViewController
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;



@property(nonatomic,strong)NSMutableArray *assests;
@property(nonatomic,strong)NSMutableArray *groupName;
@property(nonatomic,strong)NSMutableArray *combineArray, *arrcheckuncheck;
@property(nonatomic,strong) NSMutableDictionary *alldata;
@end
