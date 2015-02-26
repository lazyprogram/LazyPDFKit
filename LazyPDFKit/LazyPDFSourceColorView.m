//==============================================================================
//
//  LazyPDFSourceColorView.m
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

#import "LazyPDFSourceColorView.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//==============================================================================

@implementation LazyPDFSourceColorView

//------------------------------------------------------------------------------
#pragma mark	UIView overrides
//------------------------------------------------------------------------------

- (void) drawRect: (CGRect) rect
{
	[super drawRect: rect];
	
	if (self.enabled && self.trackingInside) {
		CGRect bounds = [self bounds];
		
		[[UIColor whiteColor] set];
		CGContextStrokeRectWithWidth(UIGraphicsGetCurrentContext(),
		                             CGRectInset(bounds, 1, 1), 2);
		
		[[UIColor blackColor] set];
		UIRectFrame(CGRectInset(bounds, 2, 2));
	}
}

//------------------------------------------------------------------------------
#pragma mark	UIControl overrides
//------------------------------------------------------------------------------

- (void) setTrackingInside: (BOOL) newValue
{
	if (newValue != _trackingInside) {
		_trackingInside = newValue;
		[self setNeedsDisplay];
	}
}

//------------------------------------------------------------------------------

- (BOOL) beginTrackingWithTouch: (UITouch*) touch
                      withEvent: (UIEvent*) event
{
	if (self.enabled) {
		self.trackingInside = YES;
		
		return [super beginTrackingWithTouch: touch withEvent: event];
	}
	else {
		return NO;
	}
}

//------------------------------------------------------------------------------

- (BOOL) continueTrackingWithTouch: (UITouch*) touch withEvent: (UIEvent*) event
{
	BOOL isTrackingInside = CGRectContainsPoint([self bounds], [touch locationInView: self]);
	
	self.trackingInside = isTrackingInside;
	
	return [super continueTrackingWithTouch: touch withEvent: event];
}

//------------------------------------------------------------------------------

- (void) endTrackingWithTouch: (UITouch*) touch withEvent: (UIEvent*) event
{
	self.trackingInside = NO;
	
	[super endTrackingWithTouch: touch withEvent: event];
}

//------------------------------------------------------------------------------

- (void) cancelTrackingWithEvent: (UIEvent*) event
{
	self.trackingInside = NO;
	
	[super cancelTrackingWithEvent: event];
}

//------------------------------------------------------------------------------

@end

//==============================================================================
