//
//  LazyPDFDataManager.h
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 3/3/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "File.h"
#import "Annotation.h"

@interface LazyPDFDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (LazyPDFDataManager *)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)addAnnotation:(NSMutableDictionary *)annDict;
- (File *)getFileByPath:(NSString *)filePath;
- (Annotation *)getAnnotation:(NSString *)filePath withPage:(NSNumber *)page;
- (UIImage *)getAnnotationImage:(NSString *)filePath withPage:(NSNumber *)page;
- (void)deleteFileByPath:(NSString *)filePath;
@end
