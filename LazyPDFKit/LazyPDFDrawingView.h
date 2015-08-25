//
// LazyPDFDrawingView.h
//
//  Created by Palanisamy Easwaramoorthy on 23/2/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


#import <UIKit/UIKit.h>

#define LazyPDFDrawingViewVersion   1.0.0

typedef enum {
    LazyPDFDrawingToolTypePen,
    LazyPDFDrawingToolTypeLine,
    LazyPDFDrawingToolTypeRectagleStroke,
    LazyPDFDrawingToolTypeRectagleFill,
    LazyPDFDrawingToolTypeEllipseStroke,
    LazyPDFDrawingToolTypeEllipseFill,
    LazyPDFDrawingToolTypeEraser,
    LazyPDFDrawingToolTypeText
} LazyPDFDrawingToolType;

@protocol LazyPDFDrawingViewDelegate, LazyPDFDrawingTool;

@interface LazyPDFDrawingView : UIView<UITextViewDelegate>

@property (nonatomic, assign) LazyPDFDrawingToolType drawTool;
@property (nonatomic, assign) id<LazyPDFDrawingViewDelegate> delegate;

// public properties
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat lineAlpha;

// get the current drawing
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong) UIImage *prev_image;
@property (nonatomic, readonly) NSUInteger undoSteps;

// load external image
- (void)loadImage:(UIImage *)image;
- (void)loadImageData:(NSData *)imageData;

// erase all
- (void)clear;

// undo / redo
- (BOOL)canUndo;
- (void)undoLatestStep;

- (BOOL)canRedo;
- (void)redoLatestStep;

@end

#pragma mark -

@protocol LazyPDFDrawingViewDelegate <NSObject>

@optional
- (void)drawingView:(LazyPDFDrawingView *)view willBeginDrawUsingTool:(id<LazyPDFDrawingTool>)tool;
- (void)drawingView:(LazyPDFDrawingView *)view didEndDrawUsingTool:(id<LazyPDFDrawingTool>)tool;

@end
