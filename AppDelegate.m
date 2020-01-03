//
//  AppDelegate.m
//  RealmDataMerging
//
//  Created by MacComp on 1/2/20.
//  Copyright © 2020 Umair Ahmed. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>

@interface Person : RLMObject
@property NSInteger id; //Primary Key
@property NSString *fullName;
@property int dailyWages;
@end

@implementation Person
+ (NSString *)primaryKey {
    return @"id";
}
@end

@interface AppDelegate ()
{
    NSArray *array_increased_wages;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    array_increased_wages=[NSArray arrayWithObjects:@"Umair",@"Awais", nil];//Need to update their wages
    
    RLMRealm *realm=[RLMRealm defaultRealm];
    NSError *error = nil;
    NSLog(@"Realm file path is %@",[RLMRealmConfiguration defaultConfiguration].fileURL);
         
    //----Move DBV1 from MainBundle to Document Directory---
    NSURL *defaultRealmURL = [RLMRealmConfiguration defaultConfiguration].fileURL;
          NSURL *v0URL = [[NSBundle mainBundle] URLForResource:@"DBV1" withExtension:@"realm"];
        [[NSFileManager defaultManager] removeItemAtURL:defaultRealmURL error:nil];
    BOOL success =[[NSFileManager defaultManager] copyItemAtPath:v0URL.path toPath:defaultRealmURL.path error:&error];

      dispatch_async(dispatch_get_main_queue(), ^{
              if(success)
               {
                   NSLog(@"Launch Realm Db Values %@", [[Person allObjectsInRealm:[RLMRealm defaultRealm]] description]);
                    [self update_Version1_Data];//Update RlmDB Version1 Data
               }
               else
               {
                    NSLog(@"didFinishLaunchingWithOptions Error is %@",error);
               }
        });
    
    return YES;
}


-(void)update_Version1_Data
{

    RLMRealm *realm = [RLMRealm defaultRealm];
       [realm beginWriteTransaction];
       for (Person *person in [Person objectsWhere:@"fullName IN %@",array_increased_wages]) {
           person.dailyWages += 600; //+600 increased in wages
           NSLog(@"%@",person.fullName);
       }
       [realm commitWriteTransaction];
     dispatch_async(dispatch_get_main_queue(), ^{
         NSLog(@"All Modify Objects in  update_Version1_Data are %@",[[Person allObjectsInRealm:realm] description]);
          [self version2_Merge_Data];
         //[self version2_Override_Data];
         
     });
    
    
}
-(void)version2_Override_Data
{
    NSError *error = nil;
    NSURL *defaultRealmURL=[RLMRealmConfiguration defaultConfiguration].fileURL;
    NSURL *version2RealmURL=[[NSBundle mainBundle] URLForResource:@"DBV2" withExtension:@"realm"];
    [[NSFileManager defaultManager] removeItemAtURL:defaultRealmURL error:nil];

    if ([[NSFileManager defaultManager] copyItemAtPath:version2RealmURL.path toPath:defaultRealmURL.path error:&error])
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"All Modify Objects in version2_Override_Data are %@",[[Person allObjectsInRealm:[RLMRealm defaultRealm]] description]);
                   
                });
        }
    else
        {
        NSLog(@"version2_Override_Data Error is %@",error);
        }
    

}
-(void)version2_Merge_Data
{
   
       NSURL *version2RealmURL=[[NSBundle mainBundle] URLForResource:@"DBV2" withExtension:@"realm"];
    RLMRealm *realm_bundle=[RLMRealm realmWithURL:version2RealmURL];
   RLMRealm *realm = [RLMRealm defaultRealm];
       [realm beginWriteTransaction];
       for (Person *person in [[Person allObjectsInRealm:realm_bundle] objectsWhere:@"NOT fullName IN %@",array_increased_wages]) {
            Person *person_addupdated=[[Person alloc] initWithValue:person];
            [[RLMRealm defaultRealm] addOrUpdateObject:person_addupdated];
           NSLog(@"version2_Merge_Data name is %@",person_addupdated.fullName);
       }
       [realm commitWriteTransaction];
       dispatch_async(dispatch_get_main_queue(), ^{
       NSLog(@"All Modify Objects in  version2_Merge_Data are %@",[[Person allObjectsInRealm:realm] description]);
  
         });
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
