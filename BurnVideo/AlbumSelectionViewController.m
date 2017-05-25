//
//  AlbumSelectionViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AlbumSelectionViewController.h"
#import "AlbumSelectionCollectionViewCell.h"
#import "AddMediaViewController.h"
#import "AppDelegate.h"
#import "SettingViewController.h"

#import "AlbumCollectionViewCell.h"
#import "SettingManager.h"
#import "Utils.h"
#define KEY_ALBUM_TITLE @"title"
#define KEY_ALBUM_COUNT @"count"
#define KEY_ALBUM_IMAGE @"image"
#define KEY_ALBUM_URL @"url"
#define KEY_ALBUM_CHECKED @"checked"

@interface AlbumSelectionViewController () <UICollectionViewDelegate , UICollectionViewDataSource>{
    NSArray *imgArr;
    NSArray *folderNameArr;
    AppDelegate *appdel;
    CGSize result;
    NSString *final;
    
    
    NSMutableArray *albums;
    
    NSMutableArray *selectedgroup;
}

@end

@implementation AlbumSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    albums = [NSMutableArray new];
    selectedgroup = [[NSMutableArray alloc] init];
    _arrcheckuncheck = [[NSMutableArray alloc]init];
     result = [[UIScreen mainScreen] bounds].size;
    appdel = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (appdel.mainVC == nil) {// not from setting
        self.btnBack.hidden = YES;
    }
    
    imgArr = [NSArray arrayWithObjects:@"photo_album@3x.png",@"photo_album@3x.png", @"photo@3x.png",@"select_photo@3x.png",nil];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cellWidth = (result.width - 80) / 2;
        [layout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [layout setMinimumInteritemSpacing:20];
        [layout setSectionInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    }else{
        cellWidth = (result.width - 150) / 3;
        [layout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [layout setMinimumInteritemSpacing:30];
        [layout setMinimumLineSpacing:30];
        [layout setSectionInset:UIEdgeInsetsMake(30, 30, 30, 30)];
    }
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView setAllowsMultipleSelection:YES];
    
    
    _alldata = [[NSMutableDictionary alloc]init];
    appdel  = (AppDelegate*)[[UIApplication sharedApplication]delegate ];
    _groupName = [[NSMutableArray alloc]init];
    
    //get selected list
    selectedgroup = (NSMutableArray *)[SettingManager objectWithKey:SETTING_KEY_ASSETGROUPS];
    
    // 1
    ALAssetsLibrary *assetsLibrary = [AlbumSelectionViewController defaultAssetsLibrary];
    // 2
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group){
            __block NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:[group valueForProperty:ALAssetsGroupPropertyName] forKey:KEY_ALBUM_TITLE];
            [dic setObject:[NSNumber numberWithInteger:group.numberOfAssets] forKey:KEY_ALBUM_COUNT];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    
                    if([[result valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto]){
                    
                        UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                        [dic setObject:image forKey:KEY_ALBUM_IMAGE];
                        *stop = YES;
                    }
                }
            }];
            
            NSURL *groupurl = [group valueForProperty:ALAssetsGroupPropertyURL];
            [dic setObject:groupurl forKey:KEY_ALBUM_URL];
            
            if (selectedgroup == nil) {
                [dic setObject:[NSNumber numberWithBool:false] forKey:KEY_ALBUM_CHECKED];
            }else{
                NSInteger anIndex = [selectedgroup indexOfObject:[groupurl absoluteString]];
                if(NSNotFound == anIndex) {
                    NSLog(@"Not Found");
                }else{
                    NSLog(@"Found");
                }
                if (anIndex == NSNotFound) {
                    [dic setObject:[NSNumber numberWithBool:NO] forKey:KEY_ALBUM_CHECKED];
                }else{
                    [dic setObject:[NSNumber numberWithBool:YES] forKey:KEY_ALBUM_CHECKED];
                }
            }

            
            [albums addObject:dic];
        }else {
            
            [self.collectionView reloadData];
            
            for (int i = 0; i < albums.count; i++) {
                NSMutableDictionary *dic = [albums objectAtIndex:i];
                
                if ([[dic objectForKey:KEY_ALBUM_CHECKED] boolValue] == YES) {
                    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                }
            }
            
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading images %@", error);
    }];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred  ;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return albums.count;
   
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumcell" forIndexPath:indexPath];
    NSDictionary *dic = [albums objectAtIndex:indexPath.row];
    if ([dic objectForKey:KEY_ALBUM_IMAGE]) {
        [cell.imvContentView setImage:[dic objectForKey:KEY_ALBUM_IMAGE]];
    }else{
        [cell.imvContentView setImage:[UIImage imageNamed:@"photo_album"]];
    }
    
    [cell.lbTitleView setText:[NSString stringWithFormat:@"%@(%ld)", [dic objectForKey:KEY_ALBUM_TITLE], (long)[[dic objectForKey:KEY_ALBUM_COUNT] integerValue]]];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

-(IBAction)checkbox:(id)sender{
     UIButton *aButton = (UIButton *)sender;
    if([sender isSelected]){
        [sender setSelected:false];
        [_arrcheckuncheck replaceObjectAtIndex:aButton.tag withObject:@"0"];
    }
    else{
        [sender setSelected:true];
        [_arrcheckuncheck replaceObjectAtIndex:aButton.tag withObject:@"1"];
    }
}

- (IBAction)btn_done:(id)sender {
    
    selectedgroup = [NSMutableArray new];
    NSArray *selected = [self.collectionView indexPathsForSelectedItems];
    for (NSIndexPath *indexpath in selected) {
        NSMutableDictionary *dic = [albums objectAtIndex:indexpath.row];
        NSURL *url = dic[KEY_ALBUM_URL];
        [selectedgroup addObject:[url absoluteString]];
    }
    
    [SettingManager setObject:selectedgroup withKey:SETTING_KEY_ASSETGROUPS];
    if (appdel.mainVC) {
        [self.navigationController popToViewController:appdel.mainVC animated:YES];
    }else{
        [self performSegueWithIdentifier:@"gotomain" sender:self];
    }
}
- (IBAction)btn_back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
