//
//  AppDelegate.m
//  BurnVideo
//
//  Created by  Krishna Sunkara on 05/06/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingManager.h"
#import "AFNetworking.h"
#import "Common.h"
#import "SelectionObject.h"

#import "Braintree.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "POSInputStreamLibrary.h"

#define UPLOADSESSION @"com.b24.dvdburner"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize a,titleIdentifier;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // register notification
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else { // for iOS 8 before version
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                    identityPoolId:CognitoIdentityPoolId];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    
    [Braintree setReturnURLScheme:@"com.b24.dvdburner.payments"];
    [self clearTemperoryDirectory];
    return YES;
}

- (void) loadSelectedArray {
    self.selectedArray = [NSMutableArray array];
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    NSArray *selectedArray = (NSArray*)[SettingManager objectWithKey:[NSString stringWithFormat:@"%@%@", SETTING_KEY_SELECTEDMEDIA, uid]];
    if (selectedArray == nil) {
        [SettingManager setIntegerValue:0 withKey:SETTING_KEY_MEDIACOUNT];
        return;
    }
    NSInteger selectedCount = 0;
    for (NSDictionary *dic in selectedArray) {
        SelectionObject *object = [[SelectionObject alloc] initWithDictionary:dic];
        if (object.remoteFileURL) {
            if ([[object.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                double value = [[object.assetfile valueForProperty:ALAssetPropertyDuration] doubleValue];
                int mediaCount = (value + 179) / (3 * 60);
                selectedCount += mediaCount;
            }else{
                selectedCount++;
            }
            [self.selectedArray addObject:object];
        }
    }
    [SettingManager setIntegerValue:selectedCount withKey:SETTING_KEY_MEDIACOUNT];
}

- (BOOL) checkAllUploaded {
    for (SelectionObject *object in self.selectedArray) {
        if (object.status == UPLOADING) {
            return false;
        }
    }
    return true;
}

- (NSInteger) getMediaSpace {
    NSInteger selectedCount = 0;
    for (SelectionObject *object in self.selectedArray) {
        if (object.status != UNSELECTED) {
            /*
            if ([[object.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                double value = [[object.assetfile valueForProperty:ALAssetPropertyDuration] doubleValue];
                NSLog(@"Duration=%f", value);
                //int mediaCount = (value + 179) / (1 * 60);
                int mediaCount = (value) / (1 * 60);
                selectedCount += mediaCount;
            }else{
                double size = object.assetfile valueForKey:ALASSetPro
                selectedCount++;
            }
             */
            
            ALAssetRepresentation *rep = [object.assetfile defaultRepresentation];
            double filesize=[rep size];
            
            NSLog(@"fileSize=%f", filesize);
            
            int mediaCount = ceil((filesize) / (50 * 1024 * 1024));
            selectedCount += mediaCount;
        }
    }
    [SettingManager setIntegerValue:selectedCount withKey:SETTING_KEY_MEDIACOUNT];
    return selectedCount;
}

- (void) saveSelectedArray {
    while (self.isSaving) {
        
    }
    self.isSaving = true;
    NSMutableArray *array = [NSMutableArray new];
    for (SelectionObject *object in self.selectedArray) {
        if (object.remoteFileURL) {
            [array addObject:[object toDictionary]];
        }
    }
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    [SettingManager setObject:array withKey:[NSString stringWithFormat:@"%@%@", SETTING_KEY_SELECTEDMEDIA, uid]];
    self.isSaving = false;
}

- (void) clearTemperoryDirectory
{
    NSString *tempPath = NSTemporaryDirectory();
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
    for (NSString *url in dirContents) {
        [[NSFileManager defaultManager] removeItemAtPath:[tempPath stringByAppendingPathComponent:url] error:nil];
    }
}

- (BOOL)application:(UIApplication *)__unused application openURL:(NSURL *)url  sourceApplication:(NSString *)sourceApplication annotation:(id)__unused annotation {
    if ([[url.scheme lowercaseString] isEqualToString:@"com.b24.dvdburner.payments"]) {
        return [Braintree handleOpenURL:url sourceApplication:sourceApplication];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Push Notification Delegate

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*) deviceToken {
    NSLog(@"My token is: %@", deviceToken);
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [SettingManager setStringValue:token withKey:SETTING_KEY_APNTOKEN];
    
    if ([SettingManager stringValueWithKey:SETTING_KEY_TOKEN]) {
        AFHTTPRequestOperationManager *man = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        
        NSDictionary *dic = @{@"token":[SettingManager stringValueWithKey:SETTING_KEY_TOKEN]
                              , @"uid":[SettingManager stringValueWithKey:SETTING_KEY_UID]
                              , @"code":token};
        
        [man POST:@"SetAPNCode" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"SetAPNCode: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"SetAPNCode: %@", error.localizedDescription);
        }];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%s..userInfo=%@",__FUNCTION__,userInfo);
    /**
     * Dump your code here according to your requirement after receiving push
     */
    
//    NSString* alert = [userInfo[@"aps"] valueForKey:@"alert"];
//    if (alert) {
//        [[[UIAlertView alloc] initWithTitle:@"Order" message:alert delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // Support all orientation
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        return UIInterfaceOrientationMaskAll;
    }
    // Support only portrait
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.identifier.BurnVideo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BurnVideo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BurnVideo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
