//==============================================================================
//
//  LazyPDFHSBSupport.h
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

//------------------------------------------------------------------------------

float pin(float minValue, float value, float maxValue);

//------------------------------------------------------------------------------

	// These functions convert between an RGB value with components in the
	// 0.0f..1.0f range to HSV where Hue is 0 .. 360 and Saturation and
	// Value (aka Brightness) are percentages expressed as 0.0f..1.0f.
	//
	// Note that HSB (B = Brightness) and HSV (V = Value) are interchangeable
	// names that mean the same thing. I use V here as it is unambiguous
	// relative to the B in RGB, which is Blue.

void HSVtoRGB(float h, float s, float v, float* r, float* g, float* b);

void RGBToHSV(float r, float g, float b, float* h, float* s, float* v,
              BOOL preserveHS);

//------------------------------------------------------------------------------

CGImageRef createSaturationBrightnessSquareContentImageWithHue(float hue);
	// Generates a 256x256 image with the specified constant hue where the
	// Saturation and value vary in the X and Y axes respectively.

//------------------------------------------------------------------------------

typedef enum {
	LazyPDFComponentIndexHue = 0,
	LazyPDFComponentIndexSaturation = 1,
	LazyPDFComponentIndexBrightness = 2,
} LazyPDFComponentIndex;

CGImageRef createHSVBarContentImage(LazyPDFComponentIndex barComponentIndex, float hsv[3]);
	// Generates an image where the specified barComponentIndex (0=H, 1=S, 2=V)
	// varies across the x-axis of the 256x1 pixel image and the other components
	// remain at the constant value specified in the hsv array.

//------------------------------------------------------------------------------
