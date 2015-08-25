//==============================================================================
//
//  LazyPDFColorBarPicker.m
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


#import "LazyPDFColorBarPicker.h"

#import "LazyPDFColorIndicatorView.h"
#import "LazyPDFHSBSupport.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//------------------------------------------------------------------------------

#define kContentInsetX 20

//==============================================================================

@implementation LazyPDFColorBarView

//------------------------------------------------------------------------------

static CGImageRef createContentImage()
{
	float hsv[] = { 0.0f, 1.0f, 1.0f };
	return createHSVBarContentImage(LazyPDFComponentIndexHue, hsv);
}

//------------------------------------------------------------------------------

- (void) drawRect: (CGRect) rect
{
	CGImageRef image = createContentImage();
	
	if (image) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextDrawImage(context, [self bounds], image);
		
		CGImageRelease(image);
	}
}

//------------------------------------------------------------------------------

@end

//==============================================================================

@implementation LazyPDFColorBarPicker {
	LazyPDFColorIndicatorView* indicator;
}

//------------------------------------------------------------------------------
#pragma mark	Drawing
//------------------------------------------------------------------------------

- (void) layoutSubviews
{
	if (indicator == nil) {
		CGFloat kIndicatorSize = 24.0f;
		indicator = [[LazyPDFColorIndicatorView alloc] initWithFrame: CGRectMake(0, 0, kIndicatorSize, kIndicatorSize)];
		[self addSubview: indicator];
	}
	
	indicator.color = [UIColor colorWithHue: self.value
	                             saturation: 1.0f
	                             brightness: 1.0f
	                                  alpha: 1.0f];
	
	CGFloat indicatorLoc = kContentInsetX + (self.value * (self.bounds.size.width - 2 * kContentInsetX));
	indicator.center = CGPointMake(indicatorLoc, CGRectGetMidY(self.bounds));
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) setValue: (float) newValue
{
	if (newValue != _value) {
		_value = newValue;
		
		[self sendActionsForControlEvents: UIControlEventValueChanged];
		[self setNeedsLayout];
	}
}

//------------------------------------------------------------------------------
#pragma mark	Tracking
//------------------------------------------------------------------------------

- (void) trackIndicatorWithTouch: (UITouch*) touch
{
	float percent = ([touch locationInView: self].x - kContentInsetX)
				  / (self.bounds.size.width - 2 * kContentInsetX);
	
	self.value = pin(0.0f, percent, 1.0f);
}

//------------------------------------------------------------------------------

- (BOOL) beginTrackingWithTouch: (UITouch*) touch
                      withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch: touch];
	
	return YES;
}

//------------------------------------------------------------------------------

- (BOOL) continueTrackingWithTouch: (UITouch*) touch
                         withEvent: (UIEvent*) event
{
	[self trackIndicatorWithTouch: touch];
	
	return YES;
}

//------------------------------------------------------------------------------
#pragma mark	Accessibility
//------------------------------------------------------------------------------

- (UIAccessibilityTraits) accessibilityTraits
{
	UIAccessibilityTraits t = super.accessibilityTraits;
	
	t |= UIAccessibilityTraitAdjustable;
	
	return t;
}

//------------------------------------------------------------------------------

- (void) accessibilityIncrement
{
	float newValue = self.value + 0.05;
	
	if (newValue > 1.0)
		newValue -= 1.0;
		
	self.value = newValue;
}

//------------------------------------------------------------------------------

- (void) accessibilityDecrement
{
	float newValue = self.value - 0.05;
	
	if (newValue < 0)
		newValue += 1.0;
	
	self.value = newValue;
}

//------------------------------------------------------------------------------

- (NSString*) accessibilityValue
{
	return [NSString stringWithFormat: @"%d degrees hue", (int) (self.value * 360.0)]; 
}

//------------------------------------------------------------------------------

@end

//==============================================================================
