//
//  AppDelegate.h
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BVHomePageViewController.h"
#import "User.h"

#import <AWSCore/AWSCore.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BVHomePageViewController *bvhpViewController;
    int a;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) int a, titleIdentifier , identifierForFolderAndAllImages;
@property (nonatomic, strong)NSMutableArray *arrayForcheckuncheck ,*groupName;
@property (nonatomic, strong)NSMutableDictionary *dictAllData;

@property (nonatomic, weak) UIViewController *mainVC;

@property (nonatomic) User *user;

@property (atomic, assign) BOOL isSaving;
@property (nonatomic, strong) NSMutableArray *selectedArray;

- (NSInteger) getMediaSpace;
- (void) saveSelectedArray;
- (void) loadSelectedArray;
- (BOOL) checkAllUploaded;

//- (void) loadUser;
- (void) saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

