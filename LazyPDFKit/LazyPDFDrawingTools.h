//
// LazyPDFDrawingTools.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_feature(objc_arc)
#define LazyPDF_HAS_ARC 1
#define LazyPDF_RETAIN(exp) (exp)
#define LazyPDF_RELEASE(exp)
#define LazyPDF_AUTORELEASE(exp) (exp)
#else
#define LazyPDF_HAS_ARC 0
#define LazyPDF_RETAIN(exp) [(exp) retain]
#define LazyPDF_RELEASE(exp) [(exp) release]
#define LazyPDF_AUTORELEASE(exp) [(exp) autorelease]
#endif


@protocol LazyPDFDrawingTool <NSObject>

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) CGFloat lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint;
- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

- (void)draw;

@end

#pragma mark -

@interface LazyPDFDrawingPenTool : UIBezierPath<LazyPDFDrawingTool> {
    CGMutablePathRef path;
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint;

@end

#pragma mark -

@interface LazyPDFDrawingEraserTool : LazyPDFDrawingPenTool

@end

#pragma mark -

@interface LazyPDFDrawingLineTool : NSObject<LazyPDFDrawingTool>

@end

#pragma mark -

@interface LazyPDFDrawingTextTool : NSObject<LazyPDFDrawingTool>
@property (strong, nonatomic) NSAttributedString* attributedText;
@end

#pragma mark -

@interface LazyPDFDrawingRectangleTool : NSObject<LazyPDFDrawingTool>

@property (nonatomic, assign) BOOL fill;

@end

#pragma mark -

@interface LazyPDFDrawingEllipseTool : NSObject<LazyPDFDrawingTool>

@property (nonatomic, assign) BOOL fill;

@end
