//
//  LazyPDFDataManager.m
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 3/3/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import "LazyPDFDataManager.h"

@interface LazyPDFDataManager (){
    NSString *fileEntity;
    NSString *annotationEntity;
}

@end

@implementation LazyPDFDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


static LazyPDFDataManager *instance = nil;


+ (LazyPDFDataManager *)sharedInstance {
    
    @synchronized(self) {
        
        if ( !instance || instance == NULL )
        {
            instance = [[LazyPDFDataManager alloc] init];
        }
        
        return instance;
    }
}

-(id)init {
    
    if (self = [super init]) {
        fileEntity = [NSString stringWithFormat:@"File"];
        annotationEntity = [NSString stringWithFormat:@"Annotation"];
        return self;
    }
    
    return nil;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"LazyPDF :: Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"LazyPDFModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSLog(@"[self applicationDocumentsDirectory] : %@",[self applicationDocumentsDirectory]);
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LazyPDFModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"LazyPDF :: Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)addAnnotation:(NSMutableDictionary *)annDict
{
    
    NSData *image = [annDict objectForKey:@"image"];
    NSNumber *page = [annDict objectForKey:@"page"];
    NSString *filePath = [annDict objectForKey:@"filePath"];
    File *file;
    Annotation *annotation;
    
    annotation = [self getAnnotation:filePath withPage:page];
    if (annotation==nil) {
        annotation = (Annotation *)[NSEntityDescription insertNewObjectForEntityForName:annotationEntity inManagedObjectContext:self.managedObjectContext];
        annotation.image = image;
        annotation.page = page;
    }else{
        annotation.image = image;
    }
    
    file = [self getFileByPath:filePath];
    if (file==nil) {
        NSNumber *fileSize = [annDict objectForKey:@"fileSize"];
        NSNumber *pageCount = [annDict objectForKey:@"pageCount"];
        NSDate *fileDate = [annDict objectForKey:@"fileDate"];
        
        file = (File *)[NSEntityDescription insertNewObjectForEntityForName:fileEntity inManagedObjectContext:self.managedObjectContext];
        file.filePath = filePath;
        file.fileSize = fileSize;
        file.pageCount = pageCount;
        file.fileDate = fileDate;
    }
    [file addAnnotationObject:annotation];
    [self saveContext];
}

- (File *)getFileByPath:(NSString *)filePath
{
    File *file = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:fileEntity inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(filePath = %@)", filePath];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if ([objects count] == 0)
    {
        //NSLog(@"No matches for file");
    }
    else
    {
        file = (File *)objects[0];
    }
    request= nil;
    return file;
}
- (Annotation *)getAnnotation:(NSString *)filePath withPage:(NSNumber *)page
{
    Annotation *annotation = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:annotationEntity inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *pred =[NSPredicate predicateWithFormat:@"(page=%@)",page];
    [request setPredicate:pred];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    if ([objects count] == 0)
    {
        //NSLog(@"No matches for annotations");
    }
    else
    {
        annotation = (Annotation *)objects[0];
    }
    request= nil;
    return annotation;
}
- (UIImage *)getAnnotationImage:(NSString *)filePath withPage:(NSNumber *)page
{
    UIImage *image=nil;
    Annotation *annotation = [self getAnnotation:filePath withPage:page];
    if (annotation.image!=nil) {
        image = [UIImage imageWithData:annotation.image];
    }
    return image;
}
- (void)deleteFileByPath:(NSString *)filePath
{
    File *file = [self getFileByPath:filePath];
    if (file!=nil) {
        [self.managedObjectContext deleteObject:file];
        [self saveContext];
    }
}
@end
