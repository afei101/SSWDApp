//
//  NXDBManager.m
//  vshare
//
//  Created by cloudwu cloudwu on 12-1-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NXDBManager.h"
#import <Security/Security.h>
#import "pinyin.h"
#import "PICData.h"
#import "Nox.h"

static NSString *SFHFKeychainUtilsErrorDomain = @"SFHFKeychainUtilsErrorDomain";

static NXDBManager * gDBManager = nil;

@implementation NXDBManager

+ (NXDBManager *)shareInstance
{
    if(gDBManager == nil)
    {
        gDBManager = [[NXDBManager alloc] init];
    }
    NSString *key = [NSThread currentThread].name;
    if(key && ![key isEqualToString:@""])
    {
        [gDBManager.dbLock lock];
        NSManagedObjectContext *managedObjectContext = [gDBManager.contextPool objectForKey:key];
        if(managedObjectContext == nil)
        {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [gDBManager.contextPool setObject:managedObjectContext forKey:key];
            [gDBManager.threadPool setObject:[NSThread currentThread] forKey:key];
//            [managedObjectContext release];
//            managedObjectContext = nil;
        }
        [gDBManager.dbLock unlock];
    }
    return gDBManager;
}

- (id)init
{
    if(self = [super init])
    {
        mDBDAO = [NXDBDAO shareInstance];
        [self contextPool];
        [self threadPool];
        [self dbLock];
        mDBDAO.currentUuid = -1;
    }
    return self;
}

- (void)dealloc
{
//    [contextPool release];
    contextPool = nil;
//    [threadPool release];
    threadPool = nil;
//    [gDBManager release];
    gDBManager = nil;
    
//    [super dealloc];
}

- (NSMutableDictionary *)contextPool
{
    if(contextPool == nil)
    {
        contextPool = [[NSMutableDictionary alloc] init];
    }
    return contextPool;
}

- (NSMutableDictionary *)threadPool
{
    if(threadPool == nil)
    {
        threadPool = [[NSMutableDictionary alloc] init];
    }
    return threadPool;
}

- (NSLock *)dbLock
{
    if(dbLock == nil)
    {
        dbLock = [[NSLock alloc] init];
    }
    return dbLock;
}

+ (void)setSqliteForManager:(long long)uuid
{
    [gDBManager.dbLock lock];
    if(gDBManager && uuid > 0)
    {
        for(NSString *key in [gDBManager.contextPool allKeys])
        {
            NSManagedObjectContext *managedObjectContext = [gDBManager.contextPool objectForKey:key];
            if(managedObjectContext.persistentStoreCoordinator)
                continue;
            NXDBDAO *dbDAO = [NXDBDAO shareInstance];
            dbDAO.currentUuid = uuid;
            NSPersistentStoreCoordinator *persistentStoreCoordinator = [dbDAO persistentStoreCoordinator];
            if(persistentStoreCoordinator)
            {
                [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
                [[NSNotificationCenter defaultCenter] addObserver:gDBManager
                                                         selector:@selector(mergeContextChangesForNotification:)
                                                             name:NSManagedObjectContextDidSaveNotification
                                                           object:managedObjectContext];
            }
        }
    }
    [gDBManager.dbLock unlock];
}

+ (void)removeAllContext
{
    [gDBManager.dbLock lock];
    if(gDBManager && gDBManager.contextPool)
    {
        [gDBManager.contextPool removeAllObjects];
        [gDBManager.threadPool removeAllObjects];
    }
    [[NXDBDAO shareInstance] removePersistentStoreCoordinator];
    [gDBManager.dbLock unlock];
}

- (void)mergeContextChangesForNotification:(NSNotification *)aNotification
{
    [gDBManager.dbLock lock];
    for(NSString *key in [gDBManager.contextPool allKeys])
    {
        NSManagedObjectContext *managedObjectContext = [gDBManager.contextPool objectForKey:key];
        if(managedObjectContext && managedObjectContext.persistentStoreCoordinator && managedObjectContext != aNotification.object)
        {
            NSThread *thread = [gDBManager.threadPool objectForKey:key];
            if(thread == [NSThread mainThread])
            {
                [managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:aNotification waitUntilDone:NO];
            }
            else if(thread)
            {
                [managedObjectContext performSelector:@selector(mergeChangesFromContextDidSaveNotification:) onThread:thread withObject:aNotification waitUntilDone:NO];
            }
        }
    }
    [gDBManager.dbLock unlock];
}

- (NSManagedObjectContext *)getManagedObjectContext
{
    [gDBManager.dbLock lock];
    NSManagedObjectContext *managedObjectContext = nil;
    NSString *key = [NSThread currentThread].name;
    if(key && ![key isEqualToString:@""])
    {
        managedObjectContext = [contextPool objectForKey:key];
    }
    if(managedObjectContext == nil)
    {
        NSLog(@"NXDBManager error : unknown thread access NXDBManager");
    }
    else if(!managedObjectContext.persistentStoreCoordinator)
    {
        managedObjectContext = nil;
        NSLog(@"NXDBManager error : not set sqlite for context");
    }
    [gDBManager.dbLock unlock];
    return managedObjectContext;
}

#pragma mark - UserModel access methods

/*
- (void)insertOrUpdateUserModel:(NSDictionary *)userDic userInfo:(NSArray *)userInfoArr
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = nil;
    if(userDic)
    {
        NSString *nickName = [userDic objectForKey:@"nickName"];
        NSString *firstChar = @"";
        for(int i = 0; i < nickName.length; i++)
        {
            char c = pinyinFirstLetter([nickName characterAtIndex:i]);
            if(c >= 'A' && c <='Z')
            {
                c += 32;
            }
            firstChar = [NSString stringWithFormat:@"%@%c",firstChar, c];
        }
        NSMutableDictionary *userDicPlus = [NSMutableDictionary dictionaryWithDictionary:userDic];
        [userDicPlus setValue:firstChar forKey:@"firstChar"];
        condition = [NSString stringWithFormat:@"uuid = %lld", [[userDicPlus objectForKey:@"uuid"] longLongValue]];
        [mDBDAO updateToTable:TABLE_USER withDictionary:userDicPlus condition:condition seqKey:@"firstChar" context:managedObjectContext];
    }
    for(NSDictionary *userInfoDic in userInfoArr)
    {
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", [[userInfoDic objectForKey:@"uuid"] longLongValue], [[userInfoDic objectForKey:@"type"] intValue]];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:userInfoDic condition:condition seqKey:@"uuid" context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}

- (UserModel *)loadUserModel:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)loadAllUserModel
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid > 10010"];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (void)deleteUserModel:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    [mDBDAO deleteFromTable:TABLE_USER condition:condition seqKey:@"firstChar" context:managedObjectContext];
    [mDBDAO deleteFromTable:TABLE_USERINFO condition:condition seqKey:@"uuid" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

#pragma mark - UserInfoModel access methods

- (void)insertOrUpdateUserInfoModel:(NSDictionary *)userInfoDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", [[userInfoDic objectForKey:@"uuid"] longLongValue], [[userInfoDic objectForKey:@"type"] intValue]];
    [mDBDAO updateToTable:TABLE_USERINFO withDictionary:userInfoDic condition:condition seqKey:@"uuid" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (NSArray *)loadUserInfoModel:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USERINFO delegate:self seqWithKey:@"uuid" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (UserInfoModel *)loadUserInfoModel:(long long)uuid type:(int)type
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, type];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USERINFO delegate:self seqWithKey:@"uuid" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (void)deleteUserInfoModel:(long long)uuid type:(int)type
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, type];
    [mDBDAO deleteFromTable:TABLE_USERINFO condition:condition seqKey:@"uuid" context:managedObjectContext];
    condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USERINFO delegate:self seqWithKey:@"uuid" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] <= 0)
    {
        [mDBDAO deleteFromTable:TABLE_USER condition:condition seqKey:@"uuid" context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}
*/


#pragma mark - new UserData access methods
- (void)insertOrUpdateUserData:(NSMutableArray *)userDataArray
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = nil;
    if (userDataArray && [userDataArray count]> 0) {
        
    
        for (UserData *userData in userDataArray) {
            if(userData)
            {
                long long uuid = userData.uuid;
                NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
                NSString *nickName = userData.nickName;
                NSString *firstChar = @"";
                for(int i = 0; i < nickName.length; i++)
                {
                    char c = pinyinFirstLetter([nickName characterAtIndex:i]);
                    if(c >= 'A' && c <='Z')
                    {
                        c += 32;
                    }
                    firstChar = [NSString stringWithFormat:@"%@%c",firstChar, c];
                }
                [userDic setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
                [userDic setValue:userData.nickName forKey:@"nickName"];
                [userDic setValue:firstChar forKey:@"firstChar"];
                [userDic setValue:userData.aliasName?userData.aliasName:@"" forKey:@"aliasName"]; 
                [userDic setValue:userData.headicon?userData.headicon:@"" forKey:@"portrait"];   
                [userDic setValue:userData.cover?userData.cover:@"" forKey:@"cover"];    
                [userDic setValue:[NSNumber numberWithLongLong:userData.createTime] forKey:@"createTime"]; 

                [userDic setValue:[NSNumber numberWithInt:userData.gender] forKey:@"gender"];   
                [userDic setValue:userData.address?userData.address:@"" forKey:@"address"];   
                [userDic setValue:[NSNumber numberWithLongLong:userData.renewTime] forKey:@"updateTime"];
                
                [userDic setValue:userData.profession?userData.profession:@"" forKey:@"job"];
                
                [userDic setValue:userData.introduction?userData.introduction:@"" forKey:@"brief"];   
                [userDic setValue:userData.QQNum?userData.QQNum:@"" forKey:@"qq"];   
                [userDic setValue:userData.PhoneNum?userData.PhoneNum:@"" forKey:@"phone"];   
                [userDic setValue:userData.email?userData.email:@"" forKey:@"email"];   
                [userDic setValue:userData.QQNickName?userData.QQNickName:@"" forKey:@"qq_NickName"];
                [userDic setValue:[NSNumber numberWithInt:userData.friendType] forKey:@"friendType"];
                [userDic setValue:[NSNumber numberWithInt:userData.clientType] forKey:@"clientType"]; 
                
                [userDic setValue:[NSNumber numberWithInt:userData.regType] forKey:@"regType"];
                  
                
                condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
                [mDBDAO updateToTable:TABLE_USER withDictionary:userDic condition:condition seqKey:@"firstChar" context:managedObjectContext];
//                [userDic release];
//                userDic = nil;
            }
        }
    [mDBDAO commitWithContext:managedObjectContext];
    }
}

/*
- (void)insertOrUpdateUserData:(UserData *)userData
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = nil;
    if(userData)
    {
        long long uuid = userData.uuid;
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
        NSString *nickName = userData.nickName;
        NSString *firstChar = @"";
        for(int i = 0; i < nickName.length; i++)
        {
            char c = pinyinFirstLetter([nickName characterAtIndex:i]);
            if(c >= 'A' && c <='Z')
            {
                c += 32;
            }
            firstChar = [NSString stringWithFormat:@"%@%c",firstChar, c];
        }
        [userDic setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [userDic setValue:userData.nickName forKey:@"nickName"];
        [userDic setValue:firstChar forKey:@"firstChar"];
        condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
        [mDBDAO updateToTable:TABLE_USER withDictionary:userDic condition:condition seqKey:@"firstChar" context:managedObjectContext];
        [userDic release];
        
        if(userData.headicon) 
        {
            NSMutableDictionary *stPic = [[NSMutableDictionary alloc] init];
            [stPic setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [stPic setValue:[NSNumber numberWithInt:USER_PORTRAIT] forKey:@"type"];
            [stPic setValue:userData.headicon forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_PORTRAIT];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:stPic condition:condition seqKey:@"uuid" context:managedObjectContext];
            [stPic release];
        }
        if(userData.cover) 
        {
            NSMutableDictionary *stCover = [[NSMutableDictionary alloc] init];
            [stCover setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [stCover setValue:[NSNumber numberWithInt:USER_COVER] forKey:@"type"];
            [stCover setValue:userData.cover forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_COVER];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:stCover condition:condition seqKey:@"uuid" context:managedObjectContext];
            [stCover release];
        }
        NSMutableDictionary *createTime = [[NSMutableDictionary alloc] init];
        [createTime setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [createTime setValue:[NSNumber numberWithInt:USER_CREATETIME] forKey:@"type"];
        [createTime setValue:[NSString stringWithFormat:@"%lld", userData.createTime] forKey:@"value"];
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_CREATETIME];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:createTime condition:condition seqKey:@"uuid" context:managedObjectContext];
        [createTime release];
        NSMutableDictionary *gender = [[NSMutableDictionary alloc] init];
        [gender setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [gender setValue:[NSNumber numberWithInt:USER_SEX] forKey:@"type"];
        [gender setValue:[NSString stringWithFormat:@"%d", userData.gender] forKey:@"value"];
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_SEX];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:gender condition:condition seqKey:@"uuid" context:managedObjectContext];
        [gender release];
        if(userData.address) 
        {
            NSMutableDictionary *address = [[NSMutableDictionary alloc] init];
            [address setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [address setValue:[NSNumber numberWithInt:USER_ADDRESS] forKey:@"type"];
            [address setValue:userData.address forKey:@"value"];
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_ADDRESS];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:address condition:condition seqKey:@"uuid" context:managedObjectContext];
            [address release];
        }
        NSMutableDictionary *updateTime = [[NSMutableDictionary alloc] init];
        [updateTime setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [updateTime setValue:[NSNumber numberWithInt:USER_UPDATETIME] forKey:@"type"];
        [updateTime setValue:[NSString stringWithFormat:@"%lld", userData.renewTime] forKey:@"value"];
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_UPDATETIME];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:updateTime condition:condition seqKey:@"uuid" context:managedObjectContext];
        [updateTime release];
        if(userData.profession) 
        {
            NSMutableDictionary *job = [[NSMutableDictionary alloc] init];
            [job setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [job setValue:[NSNumber numberWithInt:USER_JOB] forKey:@"type"];
            [job setValue:userData.profession forKey:@"value"];
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_JOB];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:job condition:condition seqKey:@"uuid" context:managedObjectContext];
            [job release];
        }
        if(userData.introduction) 
        {
            NSMutableDictionary *desc = [[NSMutableDictionary alloc] init];
            [desc setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [desc setValue:[NSNumber numberWithInt:USER_BRIEF] forKey:@"type"];
            [desc setValue:userData.introduction forKey:@"value"];
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_BRIEF];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:desc condition:condition seqKey:@"uuid" context:managedObjectContext];
            [desc release];
        }
        if(userData.QQNum) 
        {
            NSMutableDictionary *stQQ = [[NSMutableDictionary alloc] init];
            [stQQ setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [stQQ setValue:[NSNumber numberWithInt:USER_QQ] forKey:@"type"];
            [stQQ setValue:userData.QQNum forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_QQ];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:stQQ condition:condition seqKey:@"uuid" context:managedObjectContext];
            [stQQ release];
        }
        if(userData.PhoneNum) 
        {
            NSMutableDictionary *phone = [[NSMutableDictionary alloc] init];
            [phone setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [phone setValue:[NSNumber numberWithInt:USER_PHONE] forKey:@"type"];
            [phone setValue:userData.PhoneNum forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_PHONE];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:phone condition:condition seqKey:@"uuid" context:managedObjectContext];
            [phone release];
        }
        if(userData.email) 
        {
            NSMutableDictionary *mail = [[NSMutableDictionary alloc] init];
            [mail setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [mail setValue:[NSNumber numberWithInt:USER_EMAIL] forKey:@"type"];
            [mail setValue:userData.email forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_EMAIL];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:mail condition:condition seqKey:@"uuid" context:managedObjectContext];
            [mail release];
        }
        if(userData.QQNickName)
        {
            NSMutableDictionary *stQQNickname = [[NSMutableDictionary alloc] init];
            [stQQNickname setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
            [stQQNickname setValue:[NSNumber numberWithInt:USER_QQ_NICKNAME] forKey:@"type"];
            [stQQNickname setValue:userData.QQNickName forKey:@"value"];        
            condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_QQ_NICKNAME];
            [mDBDAO updateToTable:TABLE_USERINFO withDictionary:stQQNickname condition:condition seqKey:@"uuid" context:managedObjectContext];
            [stQQNickname release];
        }
        NSMutableDictionary *friendType = [[NSMutableDictionary alloc] init];
        [friendType setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [friendType setValue:[NSNumber numberWithInt:USER_FRIENDTYPE]  forKey:@"type"];
        [friendType setValue:[NSString stringWithFormat:@"%d",userData.friendType] forKey:@"value"];        
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_FRIENDTYPE];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:friendType condition:condition seqKey:@"uuid" context:managedObjectContext];
        [friendType release];
        
        NSMutableDictionary *regType = [[NSMutableDictionary alloc] init];
        [regType setValue:[NSNumber numberWithLongLong:uuid] forKey:@"uuid"];
        [regType setValue:[NSNumber numberWithInt:USER_REGTYPE]  forKey:@"type"];
        [regType setValue:[NSString stringWithFormat:@"%d",userData.regType] forKey:@"value"];        
        condition = [NSString stringWithFormat:@"uuid = %lld AND type = %d", uuid, USER_REGTYPE];
        [mDBDAO updateToTable:TABLE_USERINFO withDictionary:regType condition:condition seqKey:@"uuid" context:managedObjectContext];
        [regType release];
        
        [mDBDAO commitWithContext:managedObjectContext];
    }
}
*/

- (UserData *)loadUserData:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    __autoreleasing UserData *userData = nil;
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        UserModel *userModel = [[sectionInfo objects] objectAtIndex:0];
        userData = [[UserData alloc] initWithUUID:uuid];
        userData.nickName = userModel.nickName;
        userData.headicon = userModel.portrait;
        userData.cover = userModel.cover;
        userData.gender = [userModel.gender intValue] ;
        userData.address = userModel.address;
        userData.renewTime = [userModel.updateTime longLongValue] ;
        userData.profession = userModel.job ;
        userData.introduction = userModel.brief ;
        userData.QQNum = userModel.qq ;
        userData.PhoneNum = userModel.phone ;
        userData.email = userModel.email ;
        userData.nickName =  userModel.nickName ;
        userData.clientType = [userModel.clientType intValue];
        userData.friendType = [userModel.friendType intValue];
        userData.regType = [userModel.regType intValue];
        userData.aliasName = userModel.aliasName;
        userData.createTime = [userModel.createTime longLongValue];
    }
  
    
    return userData;
}

/*
- (UserData *)loadUserData:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    UserData *userData = nil;
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        UserModel *userModel = [[sectionInfo objects] objectAtIndex:0];
        userData = [[UserData alloc] initWithUUID:uuid];
        userData.nickName = userModel.nickName;
    }
    if(userData)
    {
        condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
        NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USERINFO delegate:self seqWithKey:@"uuid" ascending:NO condition:condition limit:0 context:managedObjectContext];
        id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
        if([sectionInfo numberOfObjects] > 0)
        {
            for(UserInfoModel *userInfoModel in [sectionInfo objects])
            {
                [self formatUserInfoModelToUserData:userInfoModel userData:userData];
            }
        }
    }
    return [userData autorelease];
}
*/

- (NSArray *)loadAllUserData
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSArray *results = nil;
    NSString *condition = [NSString stringWithFormat:@"uuid > 10010"];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        for(UserModel *userModel in [sectionInfo objects])
        {
            UserData *userData = [[UserData alloc] initWithUUID:[userModel.uuid longLongValue]];
            userData.nickName = userModel.nickName;
            userData.firstChar = userModel.firstChar;
            userData.headicon = userModel.portrait;
            userData.cover = userModel.cover;
            userData.gender = [userModel.gender intValue];
            userData.address = userModel.address;
            userData.renewTime = [userModel.updateTime longLongValue];
            userData.profession = userModel.job ;
            userData.introduction = userModel.brief ;
            userData.QQNum = userModel.qq ;
            userData.PhoneNum = userModel.phone ;
            userData.email = userModel.email ;
            userData.clientType = [userModel.clientType intValue];
            userData.friendType = [userModel.friendType intValue];
            userData.regType = [userModel.regType intValue];
            userData.aliasName = userModel.aliasName;
            userData.createTime = [userModel.createTime longLongValue];
            
            
            [userList addObject:userData];
//            [userData release];
//            userData = nil;
        }
        results = [NSArray arrayWithArray:userList];
//        [userList release];
//        userList = nil;
    }
    return results;
}


/*
- (NSArray *)loadAllUserData
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSArray *results = nil;
    NSString *condition = [NSString stringWithFormat:@"uuid > 10010"];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_USER delegate:self seqWithKey:@"firstChar" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        for(UserModel *userModel in [sectionInfo objects])
        {
            UserData *userData = [[UserData alloc] initWithUUID:[userModel.uuid longLongValue]];
            userData.nickName = userModel.nickName;
            condition = [NSString stringWithFormat:@"uuid = %lld", userData.uuid];
            NSFetchedResultsController *subResultsController = [mDBDAO selectFromTable:TABLE_USERINFO delegate:self seqWithKey:@"uuid" ascending:NO condition:condition limit:0 context:managedObjectContext];
            id<NSFetchedResultsSectionInfo> subSectionInfo = [[subResultsController sections] objectAtIndex:0];
            if([subSectionInfo numberOfObjects] > 0)
            {
                for(UserInfoModel *userInfoModel in [subSectionInfo objects])
                {
                    [self formatUserInfoModelToUserData:userInfoModel userData:userData];
                }
            }
            [userList addObject:userData];
            [userData release];
        }
        results = [NSArray arrayWithArray:userList];
        [userList release];
    }
    return results;
}
*/

- (void)deleteUser:(long long)uuid {
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"uuid = %lld", uuid];
    [mDBDAO deleteFromTable:TABLE_USER condition:condition seqKey:@"firstChar" context:managedObjectContext];
    
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)formatUserInfoModelToUserData:(UserInfoModel *)userInfoModel userData:(UserData *)userData
{
    int type = [userInfoModel.type intValue];
    switch(type)
    {
        case USER_PORTRAIT:
            userData.headicon = userInfoModel.value;
            break;
        case USER_CREATETIME:
            userData.createTime = [userInfoModel.value longLongValue];
            break;
        case USER_COVER:
            userData.cover = userInfoModel.value;
            break;
        case USER_SEX:
            userData.gender = [userInfoModel.value intValue];
            break; 
        case USER_ADDRESS:
            userData.address = userInfoModel.value;
            break;
        case USER_UPDATETIME:
            userData.renewTime = [userInfoModel.value longLongValue];
            break;
        case USER_JOB:
            userData.profession = userInfoModel.value;
            break;
        case USER_BRIEF:
            userData.introduction = userInfoModel.value;
            break;
        case USER_QQ:
            userData.QQNum = userInfoModel.value;
            break;
        case USER_PHONE:
            userData.PhoneNum = userInfoModel.value;
            break;
        case USER_EMAIL:
            userData.email = userInfoModel.value;
            break;
        case USER_QQ_NICKNAME:
            userData.nickName = userInfoModel.value;
            break;
        case USER_CLIENTTYPE:
            userData.clientType = [userInfoModel.value intValue];
            break;
        case USER_FRIENDTYPE:
            userData.friendType = [userInfoModel.value intValue];
            break;
        case USER_REGTYPE:
            userData.regType = [userInfoModel.value intValue];
        default:
            break;
    }
}

#pragma mark - GroupModel access methods

- (void)insertOrUpdateGroupModel:(NSDictionary *)groupDic groupInfo:(NSArray *)groupInfoArr
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    if(groupDic)
    {
        NSString *condition = [NSString stringWithFormat:@"groupId = %d", [[groupDic objectForKey:@"groupId"] intValue]];
        [mDBDAO updateToTable:TABLE_GROUP withDictionary:groupDic condition:condition seqKey:@"title" context:managedObjectContext];
    }
    for(NSDictionary *groupInfoDic in groupInfoArr)
    {
        NSString *condition = nil;
        if([[groupInfoDic objectForKey:@"type"] intValue] == GROUP_UUID)
        {
            condition = [NSString stringWithFormat:@"groupId = %d AND type = %d AND value like '%@'", [[groupInfoDic objectForKey:@"groupId"] intValue], [[groupInfoDic objectForKey:@"type"] intValue], [groupInfoDic objectForKey:@"value"]];
        }
        else
        {
            condition = [NSString stringWithFormat:@"groupId = %d AND type = %d", [[groupInfoDic objectForKey:@"groupId"] intValue], [[groupInfoDic objectForKey:@"type"] intValue]];
        }
        [mDBDAO updateToTable:TABLE_GROUPINFO withDictionary:groupInfoDic condition:condition seqKey:@"groupId" context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}


- (GroupModel *)loadGroupModel:(int)groupId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"groupId = %d", groupId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUP delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)loadAllGroupModel
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUP delegate:self seqWithKey:@"groupId" ascending:NO condition:nil limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (void)deleteGroupModel:(int)groupId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"groupId = %d", groupId];
    [mDBDAO deleteFromTable:TABLE_GROUP condition:condition seqKey:@"groupId" context:managedObjectContext];
    [mDBDAO deleteFromTable:TABLE_GROUPINFO condition:condition seqKey:@"groupId" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
    
}

#pragma mark - GroupInfoModel access methods

- (void)insertOrUpdateGroupInfoModel:(NSArray *)groupInfoArr
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    for(NSDictionary *groupInfoDic in groupInfoArr)
    {
        NSString *condition = nil;
        if([[groupInfoDic objectForKey:@"type"] intValue] == GROUP_UUID)
        {
            condition = [NSString stringWithFormat:@"groupId = %d AND type = %d AND value like '%@'", [[groupInfoDic objectForKey:@"groupId"] intValue], [[groupInfoDic objectForKey:@"type"] intValue], [groupInfoDic objectForKey:@"value"]];
        }
        else
        {
            condition = [NSString stringWithFormat:@"groupId = %d AND type = %d", [[groupInfoDic objectForKey:@"groupId"] intValue], [[groupInfoDic objectForKey:@"type"] intValue]];
        }
        [mDBDAO updateToTable:TABLE_GROUPINFO withDictionary:groupInfoDic condition:condition seqKey:@"groupId" context:managedObjectContext];
        [mDBDAO commitWithContext:managedObjectContext];
    }
}

- (NSArray *)loadGroupInfoModel:(int)groupId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"groupId = %d", groupId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadGroupInfoModel:(int)groupId type:(int)type
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"groupId = %d AND type = %d", groupId, type];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadGroupInfoModelForUuid:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"type = %d AND value = %@", GROUP_UUID, [[NSNumber numberWithLongLong:uuid] stringValue]];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (void)deleteGroupInfoModel:(int)groupId withUuid:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"groupId = %d AND type = %d AND value like '%@'", groupId, GROUP_UUID, [[NSNumber numberWithLongLong:uuid] stringValue]];
    [mDBDAO deleteFromTable:TABLE_GROUPINFO condition:condition seqKey:@"groupId" context:managedObjectContext];
    condition = [NSString stringWithFormat:@"groupId = %d AND type = %d", groupId, GROUP_UUID];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] <= 0)
    {
        condition = [NSString stringWithFormat:@"groupId = %d", groupId];
        [mDBDAO deleteFromTable:TABLE_GROUP condition:condition seqKey:@"groupId" context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)deleteGroupInfoModelWithUuid:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"type = %d AND value like '%@'",GROUP_UUID, [[NSNumber numberWithLongLong:uuid] stringValue]];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    NSMutableArray *referGroupIds = [NSMutableArray arrayWithCapacity:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        for(GroupInfoModel *groupInfoModel in [sectionInfo objects])
        {
            if(![referGroupIds containsObject:groupInfoModel.groupId])
            {
                [referGroupIds addObject:groupInfoModel.groupId];
            }
        }
    }
    [mDBDAO deleteFromTable:TABLE_GROUPINFO condition:condition seqKey:@"groupId" context:managedObjectContext];
    for(int i = 0; i < [referGroupIds count]; i++)
    {
        condition = [NSString stringWithFormat:@"groupId = %lld AND type = %d", [[referGroupIds objectAtIndex:i] longLongValue], GROUP_UUID];
        NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
        id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
        if([sectionInfo numberOfObjects] <= 0)
        {
            condition = [NSString stringWithFormat:@"groupId = %lld", [[referGroupIds objectAtIndex:i] longLongValue]];
            [mDBDAO deleteFromTable:TABLE_GROUP condition:condition seqKey:@"groupId" context:managedObjectContext];
        }
    }
    [mDBDAO commitWithContext:managedObjectContext];
}
#pragma mark - GroupInfo access methods

- (NSArray *)loadAllGroupWithFriends {
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSMutableArray *groupInfoArray = [NSMutableArray arrayWithCapacity:0];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUP delegate:self seqWithKey:@"groupId" ascending:NO condition:nil limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        for (GroupModel *groupModel in [sectionInfo objects]) {
            CircleInfo *circleInfo = [[CircleInfo alloc] init];
            circleInfo.circleId = [groupModel.groupId intValue];
            circleInfo.strName = groupModel.title;
            
            NSString *condition = [NSString stringWithFormat:@"groupId = %d", circleInfo.circleId];
            NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_GROUPINFO delegate:self seqWithKey:@"groupId" ascending:NO condition:condition limit:0 context:managedObjectContext];
            id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
            if([sectionInfo numberOfObjects] > 0)
            {
                NSMutableArray *friends = [[NSMutableArray alloc] init];
                for(GroupInfoModel *groupInfoModel in [sectionInfo objects])
                {
                    switch ([groupInfoModel.type intValue]) {
                        case GROUP_UUID:
                            [friends addObject:[NSNumber numberWithLongLong:[groupInfoModel.value longLongValue]]];  
                            /*
                            NSMutableDictionary *userpool = [[Nox getInstance].pageData.PDList objectAtIndex:UserPool];
                            UserData * user = [userpool objectForKey:[NSNumber numberWithInt:[groupInfoModel.value intValue]]];
                            if(user != nil)
                                [user.inCircles addObject:groupInfoModel.groupId];
                            else
                                //                            NSLog(@"user %@ is not exist",gim.value);
                            */
                            break;
                        case GROUP_CREATETIME:
                            circleInfo.lCreateTime = [groupInfoModel.value longLongValue];
                            break;
                        case GROUP_CREATOR:
                            break;
                        default:
                            break;
                    }

                }
                circleInfo.vFriends = friends;
//                [friends release];
//                friends = nil;
            }
            
            [groupInfoArray addObject:circleInfo];
//            [circleInfo release];
//            circleInfo = nil;
        }

    }
    return groupInfoArray;
}

#pragma mark - ShareInfoModel access methods

- (void)insertShareInfoModel:(NSDictionary *)shareInfoDic pictureInfo:(NSArray *)picInfoArr partaker:(NSArray *)partakerArr
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    [mDBDAO insertToTable:TABLE_SHAREINFO withDictionary:shareInfoDic context:managedObjectContext];
    for(NSDictionary *picInfoDic in picInfoArr)
    {
        [mDBDAO insertToTable:TABLE_PICTUREINFO withDictionary:picInfoDic context:managedObjectContext];
    }
    for(NSDictionary *partakerDic in partakerArr)
    {
        [mDBDAO insertToTable:TABLE_PARTAKER withDictionary:partakerDic context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)insertOrUpdateShareInfoModel:(NSDictionary *)shareInfoDic pictureInfo:(NSArray *)picInfoArr partaker:(NSArray *)partakerArr
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", [[shareInfoDic objectForKey:@"lId"] longLongValue]];
    [mDBDAO updateToTable:TABLE_SHAREINFO withDictionary:shareInfoDic condition:condition seqKey:@"createTime" context:managedObjectContext];
    for(NSDictionary *picInfoDic in picInfoArr)
    {
        condition = [NSString stringWithFormat:@"fileKey like '%@' AND lId = %lld", [picInfoDic objectForKey:@"fileKey"], [[picInfoDic objectForKey:@"lId"] longLongValue]];
        [mDBDAO updateToTable:TABLE_PICTUREINFO withDictionary:picInfoDic condition:condition seqKey:@"lId" context:managedObjectContext];
    }
    for(NSDictionary *partakerDic in partakerArr)
    {
        condition = [NSString stringWithFormat:@"lId = %lld AND uuid = %lld", [[partakerDic objectForKey:@"lId"] longLongValue], [[partakerDic objectForKey:@"uuid"] longLongValue]];
        [mDBDAO updateToTable:TABLE_PARTAKER withDictionary:partakerDic condition:condition seqKey:@"lId" context:managedObjectContext];
    }
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)updateShareInfo:(NSDictionary *)shareInfoDic {
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", [[shareInfoDic objectForKey:@"lId"] longLongValue]];
    [mDBDAO updateToTable:TABLE_SHAREINFO withDictionary:shareInfoDic condition:condition seqKey:@"createTime" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (ShareInfoModel *)loadShareInfoModelById:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = nil;
    if(isDone)
        condition = [NSString stringWithFormat:@"status = 0 AND belonguuid = %lld", belongUuid];
    else
         condition = [NSString stringWithFormat:@"status > 0 AND belonguuid = %lld", belongUuid];

    if(uuid > 0)
        condition = [NSString stringWithFormat:@"%@ AND creator = %lld",condition, uuid];
    
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;

}

- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = nil;
    if(isDone)
        condition = @"status = 0";
    else
        condition = @"status > 0";
    if(uuid > 0)
        condition = [NSString stringWithFormat:@"%@ AND creator = %lld",condition, uuid];
    
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadShareInfoModelForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone timeStamp:(long long)time belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    
    NSString *condition = nil;
    if(isDone)
        condition = [NSString stringWithFormat:@"status = 0 AND belonguuid = %lld", belongUuid];
    else
        condition = [NSString stringWithFormat:@"status > 0 AND belonguuid = %lld", belongUuid];
    if(uuid > 0)
        condition = [NSString stringWithFormat:@"%@ AND creator = %lld AND createTime < %lld",condition, uuid, time];
    else
        condition = [NSString stringWithFormat:@"%@ AND createTime < %lld",condition, time];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

//Modi by wy 重载
- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number  belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = nil;
    
    
    if(uuid > 0)
        condition = [NSString stringWithFormat:@" belonguuid = %lld AND creator = %lld",belongUuid, uuid];
    
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
    
}

- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number 
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = nil;
    
    if(uuid > 0)
        condition = [NSString stringWithFormat:@" creator = %lld", uuid];
    
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadShareInfoModelForUuidNoStatus:(long long)uuid lastNumber:(int)number  timeStamp:(long long)time belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    
    NSString *condition = nil;
    
    if(uuid > 0)
        condition = [NSString stringWithFormat:@" belonguuid = %lld AND creator = %lld AND createTime < %lld",belongUuid, uuid, time];
    else
        condition = [NSString stringWithFormat:@" belonguuid = %lld AND createTime < %lld",belongUuid, time];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

//Modi by wy end

- (void)deleteShareInfoModel:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    [mDBDAO deleteFromTable:TABLE_SHAREINFO condition:condition seqKey:@"createTime" context:managedObjectContext];
    [mDBDAO deleteFromTable:TABLE_PICTUREINFO condition:condition seqKey:@"lId" context:managedObjectContext];
    [mDBDAO deleteFromTable:TABLE_PARTAKER condition:condition seqKey:@"lId" context:managedObjectContext];
    condition = [NSString stringWithFormat:@"parentId = %lld", lId];
    [mDBDAO deleteFromTable:TABLE_COMMENT condition:condition seqKey:@"createTime" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)deleteShareInfoModelWithUuid:(long long)uuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"creator = %lld", uuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    NSMutableArray *lIdList = [NSMutableArray arrayWithCapacity:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        for(ShareInfoModel *model in [sectionInfo objects])
        {
            [lIdList addObject:model.lId];
        }
    }
    for(NSNumber *lId in lIdList)
    {
        NSString *condition = [NSString stringWithFormat:@"lId = %lld", [lId longLongValue]];
        [mDBDAO deleteFromTable:TABLE_SHAREINFO condition:condition seqKey:@"createTime" context:managedObjectContext];
        [mDBDAO deleteFromTable:TABLE_PICTUREINFO condition:condition seqKey:@"lId" context:managedObjectContext];
        [mDBDAO deleteFromTable:TABLE_PARTAKER condition:condition seqKey:@"lId" context:managedObjectContext];
        condition = [NSString stringWithFormat:@"parentId = %lld", [lId longLongValue]];
        [mDBDAO deleteFromTable:TABLE_COMMENT condition:condition seqKey:@"createTime" context:managedObjectContext];
        [mDBDAO commitWithContext:managedObjectContext];
    }
}

#pragma mark - new ShareData access methods
- (void)insertOrUpdateShareData:(ShareData *)shareData belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    if(shareData) 
    {
        NSMutableDictionary *shareDataInfo = [[NSMutableDictionary alloc] init];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stId.lId] forKey:@"lId"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stId.lParentID] forKey:@"parentId"];
        [shareDataInfo setValue:[NSNumber numberWithInt:shareData.shareInfo.eShareType] forKey:@"type"];
        if(shareData.shareInfo.strTextContent && [shareData.shareInfo.strTextContent length]>0)
            [shareDataInfo setValue:shareData.shareInfo.strTextContent forKey:@"textContent"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.shareInfo.lCreatTime] forKey:@"createTime"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stPromoter.uuid] forKey:@"creator"];        
        [shareDataInfo setValue:[NSNumber numberWithInt:shareData.status] forKey:@"status"];
        if(shareData.shareInfo.strAddr && [shareData.shareInfo.strAddr length]>0) 
            [shareDataInfo setValue:shareData.shareInfo.strAddr forKey:@"lbsAddr"];
        [shareDataInfo setValue:[NSNumber numberWithInt:shareData.shareInfo.iReceivetype] forKey:@"recevierType"];
        [shareDataInfo setValue:[NSNumber numberWithInt:shareData.shareInfo.stGps.iLat] forKey:@"lbsLat"];
        [shareDataInfo setValue:[NSNumber numberWithInt:shareData.shareInfo.stGps.iLon] forKey:@"lbsLon"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:belongUuid] forKey:@"belonguuid"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:[shareData.shareInfo.lPicIds count]] forKey:@"picNum"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.comNum] forKey:@"commentNum"];
        [shareDataInfo setValue:[NSNumber numberWithLongLong:shareData.mbsRD] forKey:@"actionNum"];
        NSString *condition = [NSString stringWithFormat:@"lId = %lld", [[shareDataInfo objectForKey:@"lId"] longLongValue]];
        [mDBDAO updateToTable:TABLE_SHAREINFO withDictionary:shareDataInfo condition:condition seqKey:@"createTime" context:managedObjectContext];
//        [shareDataInfo release];
//        shareDataInfo = nil;
        if(shareData.shareInfo.vReceive)
        {
            int index = 0;
            for(PICData *pic in shareData.shareInfo.lPicIds) 
            {
                NSMutableDictionary *picrDic = [[NSMutableDictionary alloc] init];
                [picrDic setValue:pic.md5String forKey:@"fileKey"];
                [picrDic setValue:[NSNumber numberWithInt:index] forKey:@"index"];
                [picrDic setValue:[NSNumber numberWithInt:0] forKey:@"segment"];
                [picrDic setValue:[NSNumber numberWithInt:0] forKey:@"segmentSent"];
                [picrDic setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stId.lId] forKey:@"lId"];
                [picrDic setValue:[NSNumber numberWithInt:pic.height] forKey:@"height"];
                [picrDic setValue:[NSNumber numberWithInt:pic.width] forKey:@"width"];
                condition = [NSString stringWithFormat:@"fileKey like '%@' and lId = %lld ", [picrDic objectForKey:@"fileKey"] ,[[picrDic objectForKey:@"lId"] longLongValue]];
                [mDBDAO updateToTable:TABLE_PICTUREINFO withDictionary:picrDic condition:condition seqKey:@"lId" context:managedObjectContext];
                index++;
//                [picrDic release];
//                picrDic = nil;
            }
        }
        if(shareData.shareInfo.vReceive) 
        {
            for(UserIdInfo *user in shareData.shareInfo.vReceive) 
            {
                NSMutableDictionary *partakerDic = [[NSMutableDictionary alloc] init];
                [partakerDic setValue:[NSNumber numberWithLongLong:user.uuid ]forKey:@"uuid"];
                [partakerDic setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stId.lId] forKey:@"lId"];
                [partakerDic setValue:[NSNumber numberWithInt:0] forKey:@"status"];
                condition = [NSString stringWithFormat:@"lId = %lld AND uuid = %lld", [[partakerDic objectForKey:@"lId"] longLongValue], [[partakerDic objectForKey:@"uuid"] longLongValue]];
                [mDBDAO updateToTable:TABLE_PARTAKER withDictionary:partakerDic condition:condition seqKey:@"lId" context:managedObjectContext];
//                [partakerDic release];
//                partakerDic = nil;
            }
        }
        if(shareData.shareInfo.vReceiveReadon)
        {
            for(UserIdInfo *user in shareData.shareInfo.vReceive) 
            {
                NSMutableDictionary *partakerDic = [[NSMutableDictionary alloc] init];
                [partakerDic setValue:[NSNumber numberWithLongLong:user.uuid ]forKey:@"uuid"];
                [partakerDic setValue:[NSNumber numberWithLongLong:shareData.shareInfo.stId.lId] forKey:@"lId"];
                [partakerDic setValue:[NSNumber numberWithInt:1] forKey:@"status"];
                condition = [NSString stringWithFormat:@"lId = %lld AND uuid = %lld", [[partakerDic objectForKey:@"lId"] longLongValue], [[partakerDic objectForKey:@"uuid"] longLongValue]];
                [mDBDAO updateToTable:TABLE_PARTAKER withDictionary:partakerDic condition:condition seqKey:@"lId" context:managedObjectContext];
//                [partakerDic release];
//                partakerDic = nil;
            }
        }
        if(shareData.commend)
        {
            NSMutableDictionary *commentDic = [[NSMutableDictionary alloc] init];
            [commentDic setValue:[NSNumber numberWithLongLong:shareData.commend.stId.lId] forKey:@"lId"];
            [commentDic setValue:[NSNumber numberWithLongLong:shareData.commend.stId.lParentID] forKey:@"parentId"];
            [commentDic setValue:[NSNumber numberWithLongLong:shareData.commend.stPromoter.uuid] forKey:@"creator"];
            [commentDic setValue:[NSNumber numberWithLongLong:shareData.commend.lCreateTime] forKey:@"createTime"];
            [commentDic setValue:shareData.commend.strTextContent forKey:@"textContent"];
            condition = [NSString stringWithFormat:@"lId = %lld", [[commentDic objectForKey:@"lId"] longLongValue]];
            [mDBDAO updateToTable:TABLE_COMMENT withDictionary:commentDic condition:condition seqKey:@"createTime" context:managedObjectContext];
//            [commentDic release];
//            commentDic = nil;
        }
        [mDBDAO commitWithContext:managedObjectContext];
    }
}

- (ShareData *)loadShareDataById:(long long)lId
{
    __autoreleasing ShareData *shareData = nil;
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        ShareInfoModel *shareModel = [[sectionInfo objects] objectAtIndex:0];
        shareData = [self formatShareInfoModelToShareData:shareModel];
    }
    return shareData;
}

- (NSArray *)loadShareDataForUuid:(long long)uuid lastNumber:(int)number statusDone:(BOOL)isDone timeStamp:(long long)time belongUuid:(long long)belongUuid
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    
    NSString *condition = nil;
    NSArray *results = nil;
    if(isDone)
        condition = [NSString stringWithFormat:@"status = 0"];
    else
        condition = [NSString stringWithFormat:@"status > 0"];
    if(uuid > 0)
        condition = [NSString stringWithFormat:@"creator = %lld", uuid];
    if(time > 0)
        condition = [NSString stringWithFormat:@"%@ AND createTime < %lld",condition, time];
    if(belongUuid > 0)
        condition = [NSString stringWithFormat:@"%@ AND belonguuid = %lld",condition, belongUuid];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_SHAREINFO delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:number context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        NSMutableArray *shareList = [[NSMutableArray alloc] init];
        for(ShareInfoModel *shareModel in [sectionInfo objects])
        {
            ShareData *shareData = [self formatShareInfoModelToShareData:shareModel];
            [shareList addObject:shareData];
//            [shareData release];
//            shareData = nil;
        }
        results = [NSArray arrayWithArray:shareList];
//        [shareList release];
//        shareList = nil;
    }
    return results;
}

- (ShareData *)formatShareInfoModelToShareData:(ShareInfoModel *)shareModel
{
    ShareData * shareData = [[ShareData alloc] init];
    ShareInfo * shareInfo = [[ShareInfo alloc] init];
    shareData.shareInfo = shareInfo;
//    [shareInfo release];
//    shareInfo = nil;
    CommonId* comId = [[CommonId alloc] init];
    shareData.shareInfo.stId = comId;
//    [comId release];
//    comId = nil;
    shareData.shareInfo.stId.lId = [shareModel.lId longLongValue];
    shareData.shareInfo.stId.lParentID = [shareModel.parentId longLongValue];
    shareData.comNum = [shareModel.commentNum intValue];
    shareData.mbsRD = [shareModel.actionNum intValue];
    shareData.shareInfo.lCreatTime = [shareModel.createTime longLongValue];
    UserIdInfo * userInfo = [[UserIdInfo alloc] init];
    shareData.shareInfo.stPromoter = userInfo;
//    [userInfo release];
//    userInfo = nil;
    shareData.shareInfo.stPromoter.uuid = [shareModel.creator longLongValue];
    GPSInfo * gps = [[GPSInfo alloc] init];
    shareData.shareInfo.stGps = gps;
//    [gps release];
//    gps = nil;
    shareData.shareInfo.stGps.iLat = [shareModel.lbsLat intValue];
    shareData.shareInfo.stGps.iLon = [shareModel.lbsLon intValue];
    shareData.shareInfo.strAddr = shareModel.lbsAddr;
    shareData.status = [shareModel.status intValue];
    shareData.shareInfo.strTextContent = shareModel.textContent;
    shareData.shareInfo.eShareType = [shareModel.type intValue];
    shareData.shareInfo.iReceivetype = [shareModel.recevierType intValue];
    
    NSArray* pic = [self loadPictureInfoModelById:[shareModel.lId longLongValue]];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    shareData.shareInfo.lPicIds = array;
//    [array release];
//    array = nil;
    for (PictureInfoModel* pim in pic)
    {
        PICData *picData = [[PICData alloc] initWithModelData:pim];
        [shareData.shareInfo.lPicIds addObject:picData];
//        [picData release];
//        picData = nil;
    }
    
    NSArray *partakers = [self loadPartakerModel:[shareModel.lId longLongValue]];
    for(PartakerModel *partakerModel in partakers)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        shareData.shareInfo.vReceive = array;
//        [array release];
//        array = nil;
        NSMutableArray *array1 = [[NSMutableArray alloc] init];
        shareData.shareInfo.vLiker = array1;
//        [array1 release];
//        array1 = nil;
        UserIdInfo *userInfo = [[UserIdInfo alloc] init];
        userInfo.uuid = [partakerModel.uuid longLongValue];
        [shareData.shareInfo.vReceive addObject:userInfo];
//        [userInfo release];
//        userInfo = nil;
    }
    
    NSArray *readOns = [self loadPartakerModel:[shareModel.lId longLongValue] ReadOn:YES];
    for(PartakerModel *partakerModel in readOns)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        shareData.shareInfo.vReceiveReadon = array;
//        [array release];
//        array = nil;
        NSMutableArray *array1 = [[NSMutableArray alloc] init];
        shareData.shareInfo.vLiker = array1;
//        [array1 release];
//        array1 = nil;
        UserIdInfo *userInfo = [[UserIdInfo alloc] init];
        userInfo.uuid = [partakerModel.uuid longLongValue];
        [shareData.shareInfo.vReceiveReadon addObject:userInfo];
//        [userInfo release];
//        userInfo = nil;
    }
    
    CommentModel *commentModel =  ((CommentModel*)[[self loadCommentModelByParentId:[shareModel.lId longLongValue] firstLimited:YES] objectAtIndex:0]);
    CommentInfo *comInfo = [[CommentInfo alloc] init];
    shareData.commend = comInfo;
//    [comInfo release];
//    comInfo = nil;
    shareData.commend.lCreateTime = [commentModel.createTime longLongValue];
    CommonId *comId1 = [[CommonId alloc] init];
    shareData.commend.stId = comId1;
//    [comId1 release];
//    comId1 = nil;
    shareData.commend.stId.lId = [commentModel.lId longLongValue];
    shareData.commend.stId.lParentID = [commentModel.parentId longLongValue];
    shareData.commend.strTextContent = commentModel.textContent;
    UserIdInfo *userIdInfo = [[UserIdInfo alloc] init];
    shareData.commend.stPromoter = userIdInfo;
//    [userIdInfo release];
//    userIdInfo = nil;
    shareData.commend.stPromoter.uuid = [commentModel.creator longLongValue];
    
    return shareData;
}

#pragma mark - PictureInfoModel access methods

-(void)insertPictureInfoModel:(NSDictionary *)picInfoDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    [mDBDAO insertToTable:TABLE_PICTUREINFO withDictionary:picInfoDic context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (NSArray *)loadPictureInfoModelById:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_PICTUREINFO delegate:self seqWithKey:@"index" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (PictureInfoModel *)loadPictureInfoModelByFileKey:(NSString *)fileKey
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"fileKey like '%@'", fileKey];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_PICTUREINFO delegate:self seqWithKey:@"index" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (void)updatePictureInfoModel:(NSDictionary *)picInfoDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"fileKey like '%@' and lId = %lld", [picInfoDic objectForKey:@"fileKey"] ,[[picInfoDic objectForKey:@"lId"] longLongValue]];
    [mDBDAO updateToTable:TABLE_PICTUREINFO withDictionary:picInfoDic condition:condition seqKey:@"index" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)deletePictureInfoModel:(NSString *)fileKey
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"fileKey like '%@'", fileKey];
    [mDBDAO deleteFromTable:TABLE_PICTUREINFO condition:condition seqKey:@"index" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

#pragma mark - PartakerModel access methods

- (void)insertPartakerModel:(NSDictionary *)partakerDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    [mDBDAO insertToTable:TABLE_PARTAKER withDictionary:partakerDic context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (NSArray *)loadPartakerModel:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld  ", lId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_PARTAKER delegate:self seqWithKey:@"index" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadPartakerModel:(long long)lId ReadOn:(BOOL)read
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSLog(@"lid = %lld" ,lId);
    NSString *condition = [NSString stringWithFormat:@"lId = %lld AND status = %d  ", lId ,read?1:0];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_PARTAKER delegate:self seqWithKey:@"index" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (NSArray *)loadPartakerModel:(long long)lId ReadStatus:(int)status
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSLog(@"lid = %lld" ,lId);
    NSString *condition = [NSString stringWithFormat:@"lId = %lld AND status = %d", lId ,status];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_PARTAKER delegate:self seqWithKey:@"index" ascending:YES condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (void)updatePartakerModel:(NSDictionary *)partakerDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld AND uuid = %lld", [[partakerDic objectForKey:@"lId"] longLongValue], [[partakerDic objectForKey:@"uuid"] longLongValue]];
    [mDBDAO updateToTable:TABLE_PARTAKER withDictionary:partakerDic condition:condition seqKey:@"lId" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)deletePartakerModel:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    [mDBDAO deleteFromTable:TABLE_PARTAKER condition:condition seqKey:@"lId" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

#pragma mark - CommentModel access methods

- (void)insertCommentModel:(NSDictionary *)commentDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    [mDBDAO insertToTable:TABLE_COMMENT withDictionary:commentDic context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (NSArray *)loadCommentModelByParentId:(long long)parentId firstLimited:(BOOL)isLimited
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"parentId = %lld", parentId];
    int limit = isLimited ? 1 : 0;
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_COMMENT delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:limit context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [sectionInfo objects];
    }
    return nil;
}

- (CommentModel *)loadCommentModelByCommentId:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return nil;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    NSFetchedResultsController *resultsController = [mDBDAO selectFromTable:TABLE_COMMENT delegate:self seqWithKey:@"createTime" ascending:NO condition:condition limit:0 context:managedObjectContext];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[resultsController sections] objectAtIndex:0];
    if([sectionInfo numberOfObjects] > 0)
    {
        return [[sectionInfo objects] objectAtIndex:0];
    }
    return nil;
}

- (void)updateCommentModel:(NSDictionary *)commentDic
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", [[commentDic objectForKey:@"lId"] longLongValue]];
    [mDBDAO updateToTable:TABLE_COMMENT withDictionary:commentDic condition:condition seqKey:@"createTime" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

- (void)deleteCommentModel:(long long)lId
{
    NSManagedObjectContext *managedObjectContext = [self getManagedObjectContext];
    if(managedObjectContext == nil)
    {
        return;
    }
    NSString *condition = [NSString stringWithFormat:@"lId = %lld", lId];
    [mDBDAO deleteFromTable:TABLE_COMMENT condition:condition seqKey:@"createTime" context:managedObjectContext];
    [mDBDAO commitWithContext:managedObjectContext];
}

#pragma mark - UserDefaults access methods

+ (void)setCurrentUuid:(long long)uuid
{
    NSLog(@"setCurrentUuid uuid : %lld" , uuid);
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_UUIDLIST];
    NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_UUIDLIST];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_UUIDLIST];
        [userDefualts synchronize];
    }
}

+ (long long)getCurrentUuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_UUIDLIST];
    if(list != nil)
    {
        return [[list objectAtIndex:0] longLongValue];
    }
    return -1;
}


#pragma mark - UserDefaults access methods

+ (void)setCurrentNo:(long long)lNo
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NO];
    NSNumber *noObj = [NSNumber numberWithLongLong:lNo];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:USER_NO];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NO];
        [userDefualts synchronize];
    }
}

+ (long long)getCurrentNo
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NO];
    if(list != nil)
    {
        return [[list objectAtIndex:0] longLongValue];
    }
    return -1;
}

#pragma mark - UserDefaults access methods
+ (void)setCurrentPwd:(NSData*)pwd
{
    if(pwd == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_PWD];

    if(list == nil)
    {
        list = [NSArray arrayWithObject:pwd];
        [userDefualts setValue:list forKey:USER_PWD];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:pwd])
        {
            [temp removeObject:pwd];
        }
        [temp insertObject:pwd atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_PWD];
        [userDefualts synchronize];
    }
}

+ (NSData*)getCurrentPwd
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_PWD];
    if(list != nil)
    {
        return [list objectAtIndex:0];
    }
    return nil;
}

#pragma mark - UserDefaults access methods currentPwd
+ (void)setCurrentA8Token:(NSData*)A8Token
{
    if(A8Token == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:A8TOKEN];
    
    if(list == nil)
    {
        list = [NSArray arrayWithObject:A8Token];
        [userDefualts setValue:list forKey:A8TOKEN];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:A8Token])
        {
            [temp removeObject:A8Token];
        }
        [temp insertObject:A8Token atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:A8TOKEN];
        [userDefualts synchronize];
    }
}

+ (NSData*)getCurrentA8Token
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:A8TOKEN];
    if(list != nil)
    {
        return [list objectAtIndex:0];
    }
    return nil;
}

///
+ (void)setLoginUserId:(NSString*)qq
{
    if(qq == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERID];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:qq];
        [userDefualts setValue:list forKey:USER_USERID];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:qq])
        {
            [temp removeObject:qq];
        }
        [temp insertObject:qq atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_USERID];
        [userDefualts synchronize];
    }
}

+ (NSString*)getLoginUserId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_USERID];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

///
+ (void)setLoginUserName:(NSString*)name
{
    if(name == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:name];
        [userDefualts setValue:list forKey:USER_NAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:name])
        {
            [temp removeObject:name];
        }
        [temp insertObject:name atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getLoginUserName
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}


///
+ (void)setCurrentQQ:(NSString*)qq
{
    if(qq == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_QQNUM];
   // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:qq];
        [userDefualts setValue:list forKey:USER_QQNUM];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:qq])
        {
            [temp removeObject:qq];
        }
        [temp insertObject:qq atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_QQNUM];
        [userDefualts synchronize];
    }
}

+ (NSString*)getCurrentQQ
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_QQNUM];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

///
#pragma mark - UserDefaults access methods

+ (void)setCurrentFriendUuid:(long long)uuid
{
    NSLog(@"setCurrentFriendUuid uuid : %lld" , uuid);
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_FRIENDUUIDLIST];
    NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:uuidObj];
        [userDefualts setValue:list forKey:USER_FRIENDUUIDLIST];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:uuidObj])
        {
            [temp removeObject:uuidObj];
        }
        [temp insertObject:uuidObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_FRIENDUUIDLIST];
        [userDefualts synchronize];
    }
}

+ (long long)getCurrentFriendUuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_FRIENDUUIDLIST];
    if(list != nil)
    {
        return [[list objectAtIndex:0] longLongValue];
    }
    return -1;
}


///
+ (void)setCurrentFriendQQ:(NSString*)qq
{
    if(qq == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_FRIENDQQNUM];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:qq];
        [userDefualts setValue:list forKey:USER_FRIENDQQNUM];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:qq])
        {
            [temp removeObject:qq];
        }
        [temp insertObject:qq atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_FRIENDQQNUM];
        [userDefualts synchronize];
    }
}

+ (NSString*)getCurrentFriendQQ
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_FRIENDQQNUM];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

+ (int)getQQBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQ_BIND];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setQQBind:(int)isBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQ_BIND];
    NSNumber *noObj = [NSNumber numberWithInt:isBind];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:QQ_BIND];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:QQ_BIND];
        [userDefualts synchronize];
    }
}

+ (int)getRenRenBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:RENREN_BIND];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setRenRenBind:(int)isBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:RENREN_BIND];
    NSNumber *noObj = [NSNumber numberWithInt:isBind];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:RENREN_BIND];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:RENREN_BIND];
        [userDefualts synchronize];
    }
}


+ (int)getQQWeiboBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQWEIBO_BIND];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setQQWeiboBind:(int)isBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQWEIBO_BIND];
    NSNumber *noObj = [NSNumber numberWithInt:isBind];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:QQWEIBO_BIND];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:QQWEIBO_BIND];
        [userDefualts synchronize];
    }
}

+ (int)getSinaBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:SINA_BIND];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setSinaBind:(int)isBind{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:SINA_BIND];
    NSNumber *noObj = [NSNumber numberWithInt:isBind];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:SINA_BIND];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:SINA_BIND];
        [userDefualts synchronize];
    }
}


+ (void)setSinaBindId:(NSString*)bindId
{
    if(bindId == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:SINA_BIND_NAME];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:bindId];
        [userDefualts setValue:list forKey:SINA_BIND_NAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:bindId])
        {
            [temp removeObject:bindId];
        }
        [temp insertObject:bindId atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:SINA_BIND_NAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getSinaBindId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:SINA_BIND_NAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}


+ (void)setQQWeiboBindId:(NSString*)bindId
{
    if(bindId == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQWEIBO_BIND_NAME];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:bindId];
        [userDefualts setValue:list forKey:QQWEIBO_BIND_NAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:bindId])
        {
            [temp removeObject:bindId];
        }
        [temp insertObject:bindId atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:QQWEIBO_BIND_NAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getQQWeiboBindId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQWEIBO_BIND_NAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

+ (void)setRenRenBindId:(NSString*)bindId
{
    if(bindId == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:RENREN_BIND_NAME];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:bindId];
        [userDefualts setValue:list forKey:RENREN_BIND_NAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:bindId])
        {
            [temp removeObject:bindId];
        }
        [temp insertObject:bindId atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:RENREN_BIND_NAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getRenRenBindId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:RENREN_BIND_NAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else    
            return [list objectAtIndex:0];
    }
    return nil;
}


+ (void)setQQBindId:(NSString*)bindId
{
    if(bindId == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQ_BIND_NAME];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:bindId];
        [userDefualts setValue:list forKey:QQ_BIND_NAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:bindId])
        {
            [temp removeObject:bindId];
        }
        [temp insertObject:bindId atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:QQ_BIND_NAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getQQBindId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:QQ_BIND_NAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}


+ (int)getLoginType{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:LOGIN_TYPE];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setLoginType:(int)loginType{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:LOGIN_TYPE];
    NSNumber *noObj = [NSNumber numberWithInt:loginType];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:LOGIN_TYPE];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:LOGIN_TYPE];
        [userDefualts synchronize];
    }
}

//////////////////////////////////
+ (void)setCurrentSID:(NSString*)sid
{
    if(sid == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_QQSID];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:sid];
        [userDefualts setValue:list forKey:USER_QQSID];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:sid])
        {
            [temp removeObject:sid];
        }
        [temp insertObject:sid atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_QQSID];
        [userDefualts synchronize];
    }
}

+ (NSString*)getCurrentSID
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_QQSID];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

//////////////////////////////////
+ (void)setQQWeiboLoginName:(NSString*)name
{
    if(name == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_QWEIBO];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:name];
        [userDefualts setValue:list forKey:USER_NAME_QWEIBO];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:name])
        {
            [temp removeObject:name];
        }
        [temp insertObject:name atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NAME_QWEIBO];
        [userDefualts synchronize];
    }
}

+ (NSString*)getQQWeiboLoginName
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_QWEIBO];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

//////////////////////////////////
+ (void)setSinaLoginName:(NSString*)name
{
    if(name == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_SINA];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:name];
        [userDefualts setValue:list forKey:USER_NAME_SINA];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:name])
        {
            [temp removeObject:name];
        }
        [temp insertObject:name atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NAME_SINA];
        [userDefualts synchronize];
    }
}

+ (NSString*)getSinaLoginName
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_SINA];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

//////////////////////////////////
+ (void)setRenRenLoginName:(NSString*)name
{
    if(name == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_RENREN];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:name];
        [userDefualts setValue:list forKey:USER_NAME_RENREN];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:name])
        {
            [temp removeObject:name];
        }
        [temp insertObject:name atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NAME_RENREN];
        [userDefualts synchronize];
    }
}

+ (NSString*)getRenRenLoginName
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NAME_RENREN];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

//////////////////////////////////
+ (void)setCurrentServerType:(int)type
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_FORMAL_SERVER];
    NSNumber *noObj = [NSNumber numberWithInt:type];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:IS_FORMAL_SERVER];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:IS_FORMAL_SERVER];
        [userDefualts synchronize];
    }
}

+ (int)getCurrentServerType
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_FORMAL_SERVER];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}
//////////////////////////////////

//////////////////////////////////
+ (int)getHasActivity{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_HAS_ACTIVITY];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setHasActivity:(int)iHasActivity{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_HAS_ACTIVITY];
    NSNumber *noObj = [NSNumber numberWithInt:iHasActivity];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:IS_HAS_ACTIVITY];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:IS_HAS_ACTIVITY];
        [userDefualts synchronize];
    }
}
//////////////////////////////////

//////////////////////////////////
//是否是第一次登陆
+ (int)getFirstLogin:(long long)uuid{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    NSString *firstLoginUuid = [NSString stringWithFormat:@"%@%lld" , IS_FIRST_LOGIN , uuid]; 
	NSArray *list = [userDefualts objectForKey:firstLoginUuid];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return 0;
}

+ (void)setFirstLogin:(int)iIsLogin uuid:(long long)uuid{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    NSString *firstLoginUuid = [NSString stringWithFormat:@"%@%lld" , IS_FIRST_LOGIN , uuid]; 
	NSArray *list = [userDefualts objectForKey:firstLoginUuid];
    NSNumber *noObj = [NSNumber numberWithInt:iIsLogin];
   
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:firstLoginUuid];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:firstLoginUuid];
        [userDefualts synchronize];
    }
}
//////////////////////////////////

//////////////////////////////////
//设置是否要进行app push变量
+ (void)setIsAppPush:(int)isPush
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_APP_PUSH];
    NSNumber *noObj = [NSNumber numberWithInt:isPush];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:noObj];
        [userDefualts setValue:list forKey:IS_APP_PUSH];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:noObj])
        {
            [temp removeObject:noObj];
        }
        [temp insertObject:noObj atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:IS_APP_PUSH];
        [userDefualts synchronize];
    }
}

+ (int)getIsPush
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:IS_APP_PUSH];
    if(list != nil)
    {
        return [[list objectAtIndex:0] intValue];
    }
    return -1;
}
/////////////////////////
//设置是否要进行app push变量
+ (void)setAppPushToken:(NSString*)pushToken
{
    if(pushToken == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:PUSH_TOKEN];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:pushToken];
        [userDefualts setValue:list forKey:PUSH_TOKEN];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:pushToken])
        {
            [temp removeObject:pushToken];
        }
        [temp insertObject:pushToken atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:PUSH_TOKEN];
        [userDefualts synchronize];
    }
}

+ (NSString*)getAppPushToken
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:PUSH_TOKEN];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

////////////////////////
+ (void)setCurrentSessionId:(NSString*)sessionId
{
    if(sessionId == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_SESSIONID];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:sessionId];
        [userDefualts setValue:list forKey:USER_SESSIONID];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:sessionId])
        {
            [temp removeObject:sessionId];
        }
        [temp insertObject:sessionId atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_SESSIONID];
        [userDefualts synchronize];
    }
}

+ (NSString*)getCurrentSessionId
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_SESSIONID];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

////////////////////////

/////////////////////////

+ (void)setCurrentNickName:(NSString*)nickName
{
    if(nickName == nil) {
        return;
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NICKNAME];
    // NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list == nil)
    {
        list = [NSArray arrayWithObject:nickName];
        [userDefualts setValue:list forKey:USER_NICKNAME];
        [userDefualts synchronize];
    }
    else
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        if([temp containsObject:nickName])
        {
            [temp removeObject:nickName];
        }
        [temp insertObject:nickName atIndex:0];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_NICKNAME];
        [userDefualts synchronize];
    }
}

+ (NSString*)getCurrentNickname
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_NICKNAME];
    if(list != nil)
    {
        if([[list objectAtIndex:0] isEqualToString:@""])
            return nil;
        else
            return [list objectAtIndex:0];
    }
    return nil;
}

+ (NSArray *)getUuidList
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	return [userDefualts objectForKey:USER_UUIDLIST];
}

+ (void)deleteUuid:(long long)uuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
	NSArray *list = [userDefualts objectForKey:USER_UUIDLIST];
    NSNumber *uuidObj = [NSNumber numberWithLongLong:uuid];
    if(list != nil && [list containsObject:uuidObj])
    {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:list];
        [temp removeObject:uuidObj];
        NSArray *newList = [NSArray arrayWithArray:temp];
        [userDefualts setValue:newList forKey:USER_UUIDLIST];
    }
}

+ (void)setPushToken:(NSString *)token
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts setValue:token forKey:USER_PUSHTOKEN];
    [userDefualts synchronize];
}

+ (NSString *)getPushToken
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    return [userDefualts objectForKey:USER_PUSHTOKEN];
}

+(void)delUserDefaults:(NSString *)type
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts setValue:nil forKey:[NSString stringWithFormat:@"%@", type]];
    [userDefualts synchronize];
}

+ (void)setUserDefaults:(NSString *)type withValue:(id)value forUuid:(long long)uuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts setValue:value forKey:[NSString stringWithFormat:@"%lld%@",uuid, type]];
    [userDefualts synchronize];
}

+(id)getUserDefaults:(NSString *)type 
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    id value = [userDefualts objectForKey:[NSString stringWithFormat:@"%@", type]];
    
    return value;
}

+ (NSString *)getLocalVersion
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    return [userDefualts objectForKey:USER_LOCALVERSION];
}

+ (void)setLocalVersion:(NSString *)version
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts setValue:version forKey:USER_LOCALVERSION];
    [userDefualts synchronize];
}

+ (NSString *)getSinaAccessToken{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    return [userDefualts objectForKey:SINA_ACCESS_TOKEN];
}

+ (void)setSinaAccessToken:(NSString *)sinaAccessToken{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts removeObjectForKey:SINA_ACCESS_TOKEN];
    
    [userDefualts setValue:sinaAccessToken forKey:SINA_ACCESS_TOKEN];
    [userDefualts synchronize];
}

+ (void)setSinaExpireDate:(NSDate*)expireDate
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts removeObjectForKey:SINA_EXPIRE_DATE];
    [userDefualts setValue:expireDate forKey:SINA_EXPIRE_DATE];
    [userDefualts synchronize];
}

+ (NSDate*)getSinaExpireDate
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    return [userDefualts objectForKey:SINA_EXPIRE_DATE];
}

+ (NSString *)getSinaUserId{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    return [userDefualts objectForKey:SINA_USER_ID];
}

+ (void)setSinaUserId:(NSString *)sinaUserId{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts removeObjectForKey:SINA_USER_ID];
    [userDefualts setValue:sinaUserId forKey:SINA_USER_ID];
    [userDefualts synchronize];
}

/*
+ (void)setUserDefaults:(NSString *)type withValue:(id)value 
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    [userDefualts setValue:value forKey:[NSString stringWithFormat:@"%@", type]];
}


+(id)getUserDefaults:(NSString *)type 
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    id value = [userDefualts objectForKey:[NSString stringWithFormat:@"%@", type]];
   
    return value;
}
*/
+ (id)getUserDefaults:(NSString *)type byUuid:(long long)uuid
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    id value = [userDefualts objectForKey:[NSString stringWithFormat:@"%lld%@",uuid, type]];
    if(value)
        return value;
    else
    {
        if([type isEqualToString:USER_UNREADNUM] || [type isEqualToString:USER_INVITENUM])
            return [NSNumber numberWithInt:0];
        else if([type isEqualToString:USER_PUSHENABLE])
            return [NSNumber numberWithBool:YES];
        else if([type isEqualToString:USER_WEBPQUALIT])
            return [NSNumber numberWithInt:0];
        else if([type isEqualToString:USER_NEEDVERIFY])
            return [NSNumber numberWithInt:0] ;
    }
    return nil;
}

+ (void)setFeedList:(NSMutableArray *)feelist
{
    if(feelist == nil) {
        feelist = [NSMutableArray arrayWithCapacity:0];
    }
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    NSArray *list = [NSArray arrayWithArray:feelist];
    NSString *key = [NSString stringWithFormat:@"%@%lld", USER_FEEDLIST, [NXDBManager getCurrentUuid]];
    [userDefualts setValue:list forKey:key];
    [userDefualts synchronize];
}

+ (NSArray *)getFeedList
{
    NSUserDefaults *userDefualts = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@%lld", USER_FEEDLIST, [NXDBManager getCurrentUuid]];
    return [userDefualts objectForKey:key];
}

#pragma mark - SecKeychain access methods

+ (NSString *)getItemByUuid:(NSString *)uuid itemType:(NSString *)type error:(NSError **)error
{
	if (!uuid || !type) 
    {
		if (error != nil) 
        {
			*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		}
		return nil;
	}
	
	if (error != nil) 
    {
		*error = nil;
	}
    
	// Set up a query dictionary with the base query attributes: item type (generic), username, and service
//	 NSLog(@"initWithObjects3 begin");
	__autoreleasing NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, kSecAttrAccount, kSecAttrService, nil];
	__autoreleasing NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, uuid, type, nil];
   
	
	__autoreleasing NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithObjects: objects forKeys: keys];
//	  NSLog(@"initWithObjects3 end");
	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).
	
	NSDictionary *attributeResult = NULL;
	NSMutableDictionary *attributeQuery = [query mutableCopy];
	[attributeQuery setObject: (id) kCFBooleanTrue forKey:(__bridge id) kSecReturnAttributes];
    
    CFTypeRef cfAttributeResult = (__bridge CFTypeRef)attributeResult;
    
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) attributeQuery, &cfAttributeResult);
	
//	[attributeResult release];
//    attributeResult = nil;
//	[attributeQuery release];
//    attributeQuery = nil;
	
	if (status != noErr) 
    {
		// No existing item found--simply return nil for the password
		if (error != nil && status != errSecItemNotFound) 
        {
			//Only return an error if a real exception happened--not simply for "not found."
			*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];
		}
		
		return nil;
	}
	
	// We have an existing item, now query for the password data associated with it.
	
	NSData *resultData = nil;
	NSMutableDictionary *itemQuery = [query mutableCopy];
	[itemQuery setObject: (id) kCFBooleanTrue forKey: (__bridge id) kSecReturnData];
    
    CFTypeRef cfresultData = (__bridge CFTypeRef)resultData;
    
	status = SecItemCopyMatching((__bridge CFDictionaryRef) itemQuery, &cfresultData);
	
//	[resultData autorelease];
//    resultData = nil;
//	[itemQuery release];
//    itemQuery = nil;
	
	if (status != noErr) 
    {
		if (status == errSecItemNotFound) 
        {
			// We found attributes for the item previously, but no password now, so return a special error.
			// Users of this API will probably want to detect this error and prompt the user to
			// re-enter their credentials.  When you attempt to store the re-entered credentials
			// using storeUsername:andPassword:forServiceName:updateExisting:error
			// the old, incorrect entry will be deleted and a new one with a properly encrypted
			// password will be added.
			if (error != nil) 
            {
				*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -1999 userInfo: nil];
			}
		}
		else 
        {
			// Something else went wrong. Simply return the normal Keychain API error code.
			if (error != nil) 
            {
				*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];
			}
		}
		
		return nil;
	}
    
	__autoreleasing NSString *item = nil;	
    
	if (resultData) 
    {
		item = [[NSString alloc] initWithData: resultData encoding: NSUTF8StringEncoding];
	}
	else 
    {
		// There is an existing item, but we weren't able to get password data for it for some reason,
		// Possibly as a result of an item being incorrectly entered by the previous code.
		// Set the -1999 error so the code above us can prompt the user again.
		if (error != nil) 
        {
			*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -1999 userInfo: nil];
		}
	}
    
	return item;
}

+ (BOOL)storeUuid:(NSString *)uuid item:(NSString *)item itemType:(NSString *)type updateExisting:(BOOL)updateExisting error:(NSError **)error
{		
	if (!uuid || !item || !type) 
    {
		if (error != nil) 
        {
			*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		}
		return NO;
	}
	
	// See if we already have a password entered for these credentials.
	NSError *getError = nil;
    NSString *existingItem = [NXDBManager getItemByUuid:uuid itemType:type error:&getError];
    
	if ([getError code] == -1999) 
    {
		// There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
		// Delete the existing item before moving on entering a correct one.
        
		getError = nil;
		
        [NXDBManager deleteItemByUuid:uuid itemType:type error:&getError];
        
		if ([getError code] != noErr) 
        {
			if (error != nil) 
            {
				*error = getError;
			}
			return NO;
		}
	}
	else if ([getError code] != noErr) 
    {
		if (error != nil) 
        {
			*error = getError;
		}
		return NO;
	}
	
	if (error != nil) 
    {
		*error = nil;
	}
	
	OSStatus status = noErr;
    
	if (existingItem) 
    {
		// We have an existing, properly entered item with a password.
		// Update the existing item.
		
		if (![existingItem isEqualToString:item] && updateExisting) 
        {
			//Only update if we're allowed to update existing.  If not, simply do nothing.
//            NSLog(@"initWithObjects4 begin");
			__autoreleasing NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, 
                              kSecAttrService, 
                              kSecAttrLabel, 
                              kSecAttrAccount, 
                              nil];
			
			__autoreleasing NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, 
                                 type,
                                 type,
                                 uuid,
                                 nil];
			
		 __autoreleasing	NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];			
//            NSLog(@"initWithObjects4 end");
			status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObject: [item dataUsingEncoding: NSUTF8StringEncoding] forKey: (__bridge NSString *) kSecValueData]);
		}
	}
	else 
    {
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry).  Create a new entry.
//        NSLog(@"initWithObjects5 end");
		__autoreleasing NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, 
                          kSecAttrService, 
                          kSecAttrLabel, 
                          kSecAttrAccount, 
                          kSecValueData, 
                          nil];
		
		__autoreleasing NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, 
                             type,
                             type,
                             uuid,
                             [item dataUsingEncoding: NSUTF8StringEncoding],
                             nil];
		
		__autoreleasing NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];			
//        NSLog(@"initWithObjects5 end");
		status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
	}
	
	if (error != nil && status != noErr) 
    {
		// Something went wrong with adding the new item. Return the Keychain error code.
		*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];
        
        return NO;
	}
    
    return YES;
}

+ (BOOL)deleteItemByUuid:(NSString *)uuid itemType:(NSString *)type error:(NSError **)error
{
	if (!uuid || !type) 
    {
		if (error != nil) 
        {
			*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		}
		return NO;
	}
	
	if (error != nil) 
    {
		*error = nil;
	}
//    NSLog(@"initWithObjects6 end");
	__autoreleasing NSArray *keys = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil];
    
	__autoreleasing NSArray *objects = [[NSArray alloc] initWithObjects: (__bridge NSString *) kSecClassGenericPassword, uuid, type, kCFBooleanTrue, nil];
	
	__autoreleasing NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
//	  NSLog(@"initWithObjects6 end");
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);
	
	if (error != nil && status != noErr) 
    {
		*error = [NSError errorWithDomain: SFHFKeychainUtilsErrorDomain code: status userInfo: nil];		
        
        return NO;
	}
    
    return YES;
}

@end
