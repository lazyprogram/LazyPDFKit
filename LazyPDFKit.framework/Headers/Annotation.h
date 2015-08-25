//
//  Annotation.h
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 3/3/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Annotation : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) File *file;

@end
