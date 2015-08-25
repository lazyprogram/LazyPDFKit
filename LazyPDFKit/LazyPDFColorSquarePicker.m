//==============================================================================
//
//  LazyPDFColorSquarePicker.m
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


#import "LazyPDFColorSquarePicker.h"

#import "LazyPDFColorIndicatorView.h"
#import "LazyPDFHSBSupport.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//------------------------------------------------------------------------------

#define kContentInsetX 20
#define kContentInsetY 20

#define kIndicatorSize 24

//==============================================================================

@implementation LazyPDFColorSquareView

//------------------------------------------------------------------------------

- (void) updateContent
{
	CGImageRef imageRef = createSaturationBrightnessSquareContentImageWithHue(self.hue * 360);
	self.image = [UIImage imageWithCGImage: imageRef];
	CGImageRelease(imageRef);
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) setHue: (float) value
{
	if (value != _hue || self.image == nil) {
		_hue = value;
		
		[self updateContent];
	}
}

//------------------------------------------------------------------------------

@end

//==============================================================================

@implementation LazyPDFColorSquarePicker {
	LazyPDFColorIndicatorView* indicator;
}

//------------------------------------------------------------------------------
#pragma mark	Appearance
//------------------------------------------------------------------------------

- (void) setIndicatorColor
{
	if (indicator == nil)
		return;
	
	indicator.color = [UIColor colorWithHue: self.hue
	                             saturation: self.value.x
	                             brightness: self.value.y
	                                  alpha: 1.0f];
}

//------------------------------------------------------------------------------

- (NSString*) spokenValue
{
	return [NSString stringWithFormat: @"%d%% saturation, %d%% brightness", 
						(int) (self.value.x * 100), (int) (self.value.y * 100)];
}

//------------------------------------------------------------------------------

- (void) layoutSubviews
{
	if (indicator == nil) {
		CGRect indicatorRect = { CGPointZero, { kIndicatorSize, kIndicatorSize } };
		indicator = [[LazyPDFColorIndicatorView alloc] initWithFrame: indicatorRect];
		[self addSubview: indicator];
	}
	
	[self setIndicatorColor];
	
	CGFloat indicatorX = kContentInsetX + (self.value.x * (self.bounds.size.width - 2 * kContentInsetX));
	CGFloat indicatorY = self.bounds.size.height - kContentInsetY
					   - (self.value.y * (self.bounds.size.height - 2 * kContentInsetY));
	
	indicator.center = CGPointMake(indicatorX, indicatorY);
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) setHue: (float) newValue
{
	if (newValue != _hue) {
		_hue = newValue;
		
		[self setIndicatorColor];
	}
}

//------------------------------------------------------------------------------

- (void) setValue: (CGPoint) newValue
{
	if (!CGPointEqualToPoint(newValue, _value)) {
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
	CGRect bounds = self.bounds;
	
	CGPoint touchValue;
	
	touchValue.x = ([touch locationInView: self].x - kContentInsetX)
				 / (bounds.size.width - 2 * kContentInsetX);
	
	touchValue.y = ([touch locationInView: self].y - kContentInsetY)
				 / (bounds.size.height - 2 * kContentInsetY);
	
	touchValue.x = pin(0.0f, touchValue.x, 1.0f);
	touchValue.y = 1.0f - pin(0.0f, touchValue.y, 1.0f);
	
	self.value = touchValue;
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

@end

//==============================================================================
