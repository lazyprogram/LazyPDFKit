//
//  File.h
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 3/3/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Annotation;

@interface File : NSManagedObject

@property (nonatomic, retain) NSDate * fileDate;
@property (nonatomic, retain) NSNumber * fileSize;
@property (nonatomic, retain) NSNumber * pageCount;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSSet *annotation;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addAnnotationObject:(Annotation *)value;
- (void)removeAnnotationObject:(Annotation *)value;
- (void)addAnnotation:(NSSet *)values;
- (void)removeAnnotation:(NSSet *)values;

@end
