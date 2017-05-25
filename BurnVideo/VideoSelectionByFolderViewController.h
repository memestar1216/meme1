//
//  VideoSelectionByFolderViewController.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoSelectionViewController.h"

@interface VideoSelectionByFolderViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayForFolders;

@property (weak, nonatomic) VideoSelectionViewController *parentView;

@end
