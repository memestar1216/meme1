//
//  VideoSelectionByFolderViewController.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 09/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "VideoSelectionByFolderViewController.h"
#import "VideoSelectionTableViewCell.h"
#import "VideoSelectionViewController.h"
#import "AddMediaViewController.h"
#import "AppDelegate.h"

@interface VideoSelectionByFolderViewController () <UITableViewDataSource , UITableViewDelegate>{
    NSArray *imgArr,*folderNameArr, *arrcheckuncheck;
    NSMutableArray *folderNameArrFinal;
    AppDelegate *appD;
    
}

@end

@implementation VideoSelectionByFolderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    folderNameArrFinal = [[NSMutableArray alloc]init];
        appD = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    folderNameArr = appD.groupName;
    arrcheckuncheck = appD.arrayForcheckuncheck;
    
    for(int i =0; i<folderNameArr.count; i++){
        if([arrcheckuncheck[i] isEqualToString:@"1"]){
            [folderNameArrFinal addObject:folderNameArr[i]];
        }
    }

    imgArr = [NSArray arrayWithObjects:@"photo_album@3x.png",@"photo_album@3x.png", @"photo@3x.png",@"select_photo@3x.png",nil];
//    folderNameArr = [NSArray arrayWithObjects:@"camera(20)", @"Whatsapp(15)",@"Instagram(13)",@"Other(10)", nil];
    
    
    
   
    // [ self.tableView registerClass:[VideoSelectionTableViewCell class] forCellReuseIdentifier:@"VideoSelectionTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoSelectionTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"VideoSelectionTableViewCell"];
    self.tableView.separatorColor = [UIColor clearColor];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return folderNameArrFinal.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    VideoSelectionTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"VideoSelectionTableViewCell" forIndexPath:indexPath];
    cell.videoImgView.image = [UIImage imageNamed:[imgArr objectAtIndex:indexPath.row]];
    cell.folderNameLabel.text = [folderNameArrFinal objectAtIndex:indexPath.row];
    return  cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoSelectionViewController *vc = [[VideoSelectionViewController alloc]initWithNibName:@"VideoSelectionViewController" bundle:nil];
    NSArray *arr = [[NSArray alloc]init];
     NSArray *arrrr = [[NSArray alloc]init];
    arr = [_arrayForFolders objectAtIndex:indexPath.row];
    arrrr = [arr objectAtIndex:0];
    vc.arrayForFolderImages = arrrr;
    appD.identifierForFolderAndAllImages = 0;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)btn_back:(id)sender {
    appD.identifierForFolderAndAllImages = 1;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
    VideoSelectionViewController *vc = [[VideoSelectionViewController alloc]initWithNibName:@"VideoSelectionViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
    }
    else{
        VideoSelectionViewController *vc = [[VideoSelectionViewController alloc]initWithNibName:@"VideoSelectionViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)btn_done:(id)sender {
    
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        AddMediaViewController *vc = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        AddMediaViewController *vc = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
