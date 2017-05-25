//
//  AlbumViewController.m
//  BurnVideo
//
//  Created by user on 8/4/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SettingManager.h"
#import "AlbumTableViewCell.h"
#import "AppDelegate.h"
#import "Common.h"

#define KEY_ALBUM_TITLE @"title"
#define KEY_ALBUM_COUNT @"count"
#define KEY_ALBUM_IMAGE @"image"
#define KEY_ALBUM_URL @"url"

@interface AlbumViewController ()
{
    NSArray *albumsArray;
    NSMutableArray *dataArray;
    __weak IBOutlet UILabel *lbTitle;
    AppDelegate *appdel;
}
@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    dataArray = [NSMutableArray new];
    albumsArray = (NSArray*)[SettingManager objectWithKey:SETTING_KEY_ASSETGROUPS];
    
    ALAssetsLibrary *assetsLibrary = [AlbumViewController defaultAssetsLibrary];
    
    __block NSMutableDictionary *allMediaDic = [NSMutableDictionary new];
    [allMediaDic setObject:@"All" forKey:KEY_ALBUM_TITLE];
    __block int totalCount = 0;
    [allMediaDic setObject:[NSNumber numberWithInt:totalCount] forKey:KEY_ALBUM_COUNT];
    [dataArray addObject:allMediaDic];
    
    for (NSString *groupurl in albumsArray) {
        [assetsLibrary groupForURL:[NSURL URLWithString:groupurl] resultBlock:^(ALAssetsGroup *group) {
            if (group) {
                __block NSMutableDictionary *dic = [NSMutableDictionary new];
                [dic setObject:[group valueForProperty:ALAssetsGroupPropertyName] forKey:KEY_ALBUM_TITLE];
                [dic setObject:[NSNumber numberWithInteger:group.numberOfAssets] forKey:KEY_ALBUM_COUNT];
                totalCount += group.numberOfAssets;
                [allMediaDic setObject:[NSNumber numberWithInt:totalCount] forKey:KEY_ALBUM_COUNT];

                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                        [dic setObject:image forKey:KEY_ALBUM_IMAGE];
                        *stop = YES;
                        if (totalCount != 0) {
                            [allMediaDic setObject:image forKey:KEY_ALBUM_IMAGE];
                        }
                    }
                }];
                NSURL *groupurl = [group valueForProperty:ALAssetsGroupPropertyURL];
                [dic setObject:groupurl forKey:KEY_ALBUM_URL];
                [dataArray addObject:dic];
                [self.tblAlbumView reloadData];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger count = [SettingManager integerValueWithKey:SETTING_KEY_MEDIACOUNT];
    if (count == 0) {
        [lbTitle setText:@"SELECT MEDIA SPACES"];
    }else{
        [lbTitle setText:[NSString stringWithFormat:@"%ld of %d Media Spaces Uploaded", (long)count, MEDIA_COUNT]];
    }
}

+ (ALAssetsLibrary *) defaultAssetsLibrary
{
    static dispatch_once_t pred  ;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumcell" forIndexPath:indexPath];
    NSMutableDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    if ([dic objectForKey:KEY_ALBUM_IMAGE]) {
        [cell.imvContentView setImage:[dic objectForKey:KEY_ALBUM_IMAGE]];
    }else{
        [cell.imvContentView setImage:[UIImage imageNamed:@"photo_album"]];
    }
    [cell.lbTitle setText:[NSString stringWithFormat:@"%@(%ld)", [dic objectForKey:KEY_ALBUM_TITLE], (long)[[dic objectForKey:KEY_ALBUM_COUNT] integerValue]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.videoSelectionVC selectAlbum:nil];
    }else{
        NSMutableDictionary *dic = dataArray[indexPath.row];
        NSURL *albumUrl = dic[KEY_ALBUM_URL];
        [self.videoSelectionVC selectAlbum:[albumUrl absoluteString]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
