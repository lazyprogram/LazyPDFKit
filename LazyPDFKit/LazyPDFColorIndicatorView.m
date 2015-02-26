//==============================================================================
//
//  LazyPDFColorIndicatorView.m
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


#import "LazyPDFColorIndicatorView.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//==============================================================================

@implementation LazyPDFColorIndicatorView

//------------------------------------------------------------------------------

- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame: frame];
	
	if (self) {
		self.opaque = NO;
		self.userInteractionEnabled = NO;
	}
	
	return self;
}

//------------------------------------------------------------------------------

- (void) setColor: (UIColor*) newColor
{
	if (![_color isEqual: newColor]) {
		_color = newColor;
		
		[self setNeedsDisplay];
	}
}

//------------------------------------------------------------------------------

- (void) drawRect: (CGRect) rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint center = { CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
	CGFloat radius = CGRectGetMidX(self.bounds);
	
	// Fill it:
	
	CGContextAddArc(context, center.x, center.y, radius - 1.0f, 0.0f, 2.0f * (float) M_PI, YES);
	[self.color setFill];
	CGContextFillPath(context);
	
	// Stroke it (black transucent, inner):
	
	CGContextAddArc(context, center.x, center.y, radius - 1.0f, 0.0f, 2.0f * (float) M_PI, YES);
	CGContextSetGrayStrokeColor(context, 0.0f, 0.5f);
	CGContextSetLineWidth(context, 2.0f);
	CGContextStrokePath(context);
	
	// Stroke it (white, outer):
	
	CGContextAddArc(context, center.x, center.y, radius - 2.0f, 0.0f, 2.0f * (float) M_PI, YES);
	CGContextSetGrayStrokeColor(context, 1.0f, 1.0f);
	CGContextSetLineWidth(context, 2.0f);
	CGContextStrokePath(context);
}

//------------------------------------------------------------------------------

@end

//==============================================================================
