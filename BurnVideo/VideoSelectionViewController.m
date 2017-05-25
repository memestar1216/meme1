//
//  VideoSelectionViewController.m
//  BurnVideo
//
//  Created by Pankaj_C_014 on 08/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "VideoSelectionViewController.h"
#import "VideoSelectionCollectionViewCell.h"
#import "AddMediaViewController.h"
#import "VideoSelectionByFolderViewController.h"
#import "AppDelegate.h"

#import "AlbumSelectionViewController.h"
#import "SettingManager.h"
#import "MediaCollectionViewCell.h"
#import "AlbumViewController.h"
#import "SelectionObject.h"
#import "UIProgressView+AFNetworking.h"
#import "SelectionManager.h"
#import "Utils.h"
#import "Common.h"

#define KEY_ALBUM_TITLE @"title"
#define KEY_ALBUM_IMAGE @"image"
#define KEY_ALBUM_URL @"url"
#define KEY_ALBUM_CHECKED @"checked"

@interface VideoSelectionViewController () <UICollectionViewDataSource , UICollectionViewDelegate, UIAlertViewDelegate>{
    NSArray *imgArr ;
    AppDelegate *appD;
    NSMutableArray *arrayForAllImages;
    
    NSMutableArray *assetsArray;
    
    NSArray *selectedLibrary;
    NSInteger selectedCount;
}


@end

@implementation VideoSelectionViewController
@synthesize array;

- (void)viewDidLoad {
    [super viewDidLoad];
    appD = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        cellWidth = (result.width - 80) / 2;
        [layout setItemSize:CGSizeMake(cellWidth, cellWidth)];
        [layout setMinimumInteritemSpacing:20];
        [layout setMinimumLineSpacing:20];
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
    
    assetsArray = [NSMutableArray new];
    selectedCount = [SettingManager integerValueWithKey:SETTING_KEY_MEDIACOUNT];
    [self updateTitle:selectedCount];
    
    ALAssetsLibrary *assetsLibrary = [self.class defaultAssetsLibrary];
    
    selectedLibrary = (NSArray*)[SettingManager objectWithKey:SETTING_KEY_ASSETGROUPS];
    for (NSString *groupurl in selectedLibrary) {
        [assetsLibrary groupForURL:[NSURL URLWithString:groupurl] resultBlock:^(ALAssetsGroup *group) {
            if (group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        SelectionObject *object = [[SelectionObject alloc] initWithAsset:result];
                        
                        NSInteger index = [appD.selectedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                            SelectionObject *selObj = (SelectionObject*) obj;
                            if ([selObj.assetURL.absoluteString isEqualToString:object.assetURL.absoluteString]) {
                                *stop = true;
                                return true;
                            }
                            return false;
                        }];
                        
                        if (appD.selectedArray != nil && index != NSNotFound) {
                            ((SelectionObject*)appD.selectedArray[index]).assetfile = result;
                            [assetsArray addObject:appD.selectedArray[index]];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                            SelectionObject *lastObj = [assetsArray lastObject];
                            if (lastObj.status == SELECTED || lastObj.status == UPLOADING) {
                                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                            }
                        }else{
                            [assetsArray addObject:object];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

- (void) updateTitle:(NSInteger) count
{
    if (count == 0) {
        [self.lbTitle setText:@"SELECT MEDIA SPACES"];
    }else{
        [self.lbTitle setText:[NSString stringWithFormat:@"%ld of %d Media Spaces Uploaded", (long)count, MEDIA_COUNT]];
    }
}

- (void) selectAlbum:(NSString *) albumUrl {
    [assetsArray removeAllObjects];
    [self.collectionView reloadData];
    ALAssetsLibrary *assetsLibrary = [self.class defaultAssetsLibrary];
    if (albumUrl && albumUrl.length) {
        [assetsLibrary groupForURL:[NSURL URLWithString:albumUrl] resultBlock:^(ALAssetsGroup *group) {
            if (group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        SelectionObject *object = [[SelectionObject alloc] initWithAsset:result];
                        
                        NSInteger index = [appD.selectedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                            SelectionObject *selObj = (SelectionObject*) obj;
                            if ([selObj.assetURL.absoluteString isEqualToString:object.assetURL.absoluteString]) {
                                *stop = true;
                                return true;
                            }
                            return false;
                        }];
                        if (index != NSNotFound) {
                            ((SelectionObject*)appD.selectedArray[index]).assetfile = result;
                            [assetsArray addObject:appD.selectedArray[index]];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                            SelectionObject *lastObj = [assetsArray lastObject];
                            if (lastObj.status == SELECTED || lastObj.status == UPLOADING) {
                                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                            }
                        }else{
                            [assetsArray addObject:object];
                            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                        }
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    } else {
        for (NSString *groupurl in selectedLibrary) {
            [assetsLibrary groupForURL:[NSURL URLWithString:groupurl] resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            SelectionObject *object = [[SelectionObject alloc] initWithAsset:result];
                            NSInteger index = [appD.selectedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                SelectionObject *selObj = (SelectionObject*) obj;
                                if ([selObj.assetURL.absoluteString isEqualToString:object.assetURL.absoluteString]) {
                                    *stop = true;
                                    return true;
                                }
                                return false;
                            }];

                            if (index != NSNotFound) {
                                ((SelectionObject*)appD.selectedArray[index]).assetfile = result;
                                [assetsArray addObject:appD.selectedArray[index]];
                                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                                SelectionObject *lastObj = [assetsArray lastObject];
                                if (lastObj.status == SELECTED || lastObj.status == UPLOADING) {
                                    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                                }
                            }else{
                                [assetsArray addObject:object];
                                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:assetsArray.count - 1 inSection:0]]];
                            }
                        }
                    }];
                }
            } failureBlock:^(NSError *error) {
                
            }];
        }
    }
    
}

+ (ALAssetsLibrary *) defaultAssetsLibrary
{
    static dispatch_once_t pred;
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return assetsArray.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MediaCollectionViewCell *cell;
       cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mediacell" forIndexPath:indexPath];
    SelectionObject *object = assetsArray[indexPath.row];
    
    cell.imvContentView.image = [UIImage imageWithCGImage:object.assetfile.thumbnail];// object.thumbImage;
    if ([[object.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        cell.imvVideo.hidden = false;
    }else{
        cell.imvVideo.hidden = true;
    }
    if (object.status == UPLOADING) {
        cell.progressView.hidden = false;
        if (object.uploadRequest) {
            [object.uploadRequest setUploadProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (totalBytesExpectedToSend > 0) {
                        cell.progressView.progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
                    }
                });
            }];
        }        
    }
    
    [object setBlock:^(SelectionStatus status, NSError *err){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([appD checkAllUploaded]) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            MediaCollectionViewCell *cell = (MediaCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
            if (err) {
                cell.progressView.hidden = true;
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                [Utils showAlertView:@"Fail to Upload" message:err.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }else{
                if (status == UPLOADING) {
                    cell.progressView.hidden = false;
                }else{
                    cell.progressView.hidden = true;
                    if (status == UPLOADINGFAIL) {
                        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                        [Utils showAlertView:@"Fail to Upload" message:err.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    }
                }
                if ([appD checkAllUploaded]) {
                    [Utils showAlertView:@"Order" message:@"Your media files have uploaded. Click \"Done\" to continue with your order." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }
            }
            [self updateTitle:[appD getMediaSpace]];
        });
    }];
    
    [object setUploadProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (totalBytesExpectedToSend > 0) {
                MediaCollectionViewCell *cell = (MediaCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                cell.progressView.progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
            }
        });
    }];
    
    [cell.lbTitleView setText:object.assetfile.defaultRepresentation.filename];
    
    __block UIImageView *redMark = cell.uploadedMark;
    
    [redMark setHidden:![[SelectionManager sharedInstance] isUploadedAssetFile:object.assetURL.absoluteString]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([appD getMediaSpace] >= MEDIA_COUNT) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        return;
    }
    __block SelectionObject *object = assetsArray[indexPath.row];
    NSInteger index = [appD.selectedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        SelectionObject *selObj = (SelectionObject*) obj;
        if ([selObj.assetURL.absoluteString isEqualToString:object.assetURL.absoluteString]) {
            *stop = true;
            return true;
        }
        return false;
    }];

    if (index == NSNotFound) {
        [appD.selectedArray addObject:object];
    }else{
        object = [appD.selectedArray objectAtIndex:index];
    }
    
    ALAssetRepresentation *rep = [object.assetfile defaultRepresentation];
    double filesize=[rep size];
    
    NSLog(@"fileSize=%f", filesize);
    
    int mediaCount = ceil((filesize) / (50 * 1024 * 1024));
    
    if ([appD getMediaSpace] + mediaCount > MEDIA_COUNT) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        [Utils showAlertView:@"The file you have selected is too large for your remaining media space. Please choose a smaller file." message:nil cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
        return;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [object setSelect:^(SelectionStatus status, NSError *err) {
        MediaCollectionViewCell *cell = (MediaCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([appD checkAllUploaded]) {
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }
            if (err) {
                cell.progressView.hidden = true;
                [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                [Utils showAlertView:@"Fail to Upload" message:err.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
            }else{
                if (status == UPLOADING) {
                    cell.progressView.hidden = false;
                }else{
                    cell.progressView.hidden = true;
                    if (status == UPLOADINGFAIL) {
                        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
                        [Utils showAlertView:@"Fail to Upload" message:err.localizedDescription cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                    }
                }
                if ([appD checkAllUploaded]) {
                    [Utils showAlertView:@"Order" message:@"Your media files have uploaded. Click \"Done\" to continue with your order." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
                }
            }
            [self updateTitle:[appD getMediaSpace]];
        });
    }];
    [object setUploadProgress:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (totalBytesExpectedToSend > 0) {
                MediaCollectionViewCell *cell = (MediaCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
                cell.progressView.progress = (float)((double) totalBytesSent / totalBytesExpectedToSend);
            }
        });
    }];
    [self updateTitle:[appD getMediaSpace]];
}

- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionViewCell *cell = (MediaCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.progressView setHidden:true];
    SelectionObject *object = assetsArray[indexPath.row];
    NSInteger index = [appD.selectedArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        SelectionObject *selObj = (SelectionObject*) obj;
        if ([selObj.assetURL.absoluteString isEqualToString:object.assetURL.absoluteString]) {
            *stop = true;
            return true;
        }
        return false;
    }];
    
    if (index != NSNotFound) {
        SelectionObject *selObj = appD.selectedArray[index];
        [selObj setCancel];
    }
    [self updateTitle:[appD getMediaSpace]];
    if ([appD checkAllUploaded]) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (IBAction)btn_done:(id)sender {
    if ([appD checkAllUploaded]) {
        [appD saveSelectedArray];
        [self.navigationController popToViewController:appD.mainVC animated:YES];
    }else{
        [Utils showAlertView:@"Order" message:@"Please be patient while we are uploading your media files...." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }
}

- (IBAction)btn_back:(id)sender {
    if ([appD checkAllUploaded]) {
        [appD saveSelectedArray];
        [self.navigationController popToViewController:appD.mainVC animated:YES];
    }else{
        [Utils showAlertView:@"Order" message:@"Please be patient while we are uploading your media files...." cancelButtonTitle:@"OK" doneButtonTitle:nil alertHandle:nil];
    }
}
- (IBAction)btn_backToMediaSpace:(id)sender {
     appD.identifierForFolderAndAllImages = 1;
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        AddMediaViewController *obj = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
    }
    else{
        AddMediaViewController *obj = [[AddMediaViewController alloc]initWithNibName:@"AddMediaViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
    }
}
- (IBAction)btn_forward:(id)sender {
    if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        VideoSelectionByFolderViewController *obj = [[VideoSelectionByFolderViewController alloc]initWithNibName:@"VideoSelectionByFolderViewController" bundle:nil];
        obj.arrayForFolders = array;
        [self.navigationController pushViewController:obj animated:NO];
    }
    else{
        VideoSelectionByFolderViewController *obj = [[VideoSelectionByFolderViewController alloc]initWithNibName:@"VideoSelectionByFolderViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:NO];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AlbumViewController class]]) {
        AlbumViewController *desVC = (AlbumViewController*) segue.destinationViewController;
        desVC.videoSelectionVC = self;
    }
}



@end
