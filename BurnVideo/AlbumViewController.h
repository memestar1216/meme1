//
//  AlbumViewController.h
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoSelectionViewController.h"

@interface AlbumViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) VideoSelectionViewController *videoSelectionVC;

@property (nonatomic, weak) IBOutlet UITableView *tblAlbumView;

@end
