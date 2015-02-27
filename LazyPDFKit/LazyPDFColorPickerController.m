//==============================================================================
//
//  LazyPDFColorPickerController.m
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


#import "LazyPDFColorPickerController.h"

#import "LazyPDFColorBarPicker.h"
#import "LazyPDFColorSquarePicker.h"
#import "LazyPDFColorPickerNavigationController.h"
#import "LazyPDFHSBSupport.h"

//------------------------------------------------------------------------------

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC enabled (-fobjc-arc).
#endif

//------------------------------------------------------------------------------

static void HSVFromUIColor(UIColor* color, float* h, float* s, float* v)
{
	CGColorRef colorRef = [color CGColor];
	
	const CGFloat* components = CGColorGetComponents(colorRef);
	size_t numComponents = CGColorGetNumberOfComponents(colorRef);
	
	CGFloat r, g, b;
	
	if (numComponents < 3) {
		r = g = b = components[0];
	}
	else {
		r = components[0];
		g = components[1];
		b = components[2];
	}
	
	RGBToHSV(r, g, b, h, s, v, YES);
}

//==============================================================================

@interface LazyPDFColorPickerController ()

@property (nonatomic) IBOutlet LazyPDFColorBarView* barView;
@property (nonatomic) IBOutlet LazyPDFColorSquareView* squareView;
@property (nonatomic) IBOutlet LazyPDFColorBarPicker* barPicker;
@property (nonatomic) IBOutlet LazyPDFColorSquarePicker* squarePicker;
@property (nonatomic) IBOutlet UIView* sourceColorView;
@property (nonatomic) IBOutlet UIView* resultColorView;
@property (nonatomic) IBOutlet UINavigationController* navController;

@end

//==============================================================================

@implementation LazyPDFColorPickerController {
	float _hue;
	float _saturation;
	float _brightness;
}

//------------------------------------------------------------------------------
#pragma mark	Class methods
//------------------------------------------------------------------------------

+ (LazyPDFColorPickerController*) colorPickerViewController
{
	NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    return [[self alloc] initWithNibName: @"LazyPDFColorPickerView" bundle: currentBundle];
}

//------------------------------------------------------------------------------

+ (CGSize) idealSizeForViewInPopover
{
	return CGSizeMake(256 + (1 + 20) * 2, 420);
}

//------------------------------------------------------------------------------
#pragma mark	Creation
//------------------------------------------------------------------------------

- (id) initWithNibName: (NSString*) nibNameOrNil bundle: (NSBundle*) nibBundleOrNil
{
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	
	if (self) {
		self.navigationItem.title = NSLocalizedString(@"Set Color",
		                                              @"LazyPDFColorPicker default nav item title");
	}
	
	return self;
}

//------------------------------------------------------------------------------

- (void) presentModallyOverViewController: (UIViewController*) controller
{
	UINavigationController* nav = [[LazyPDFColorPickerNavigationController alloc] initWithRootViewController: self];
	
	nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
																						   target: self
																						   action: @selector(done:)];
	
	[controller presentViewController: nav animated: YES completion: nil];
}

//------------------------------------------------------------------------------
#pragma mark	UIViewController methods
//------------------------------------------------------------------------------

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	_barPicker.value = _hue;
	_squareView.hue = _hue;
	_squarePicker.hue = _hue;
	_squarePicker.value = CGPointMake(_saturation, _brightness);
	
	if (_sourceColor)
		_sourceColorView.backgroundColor = _sourceColor;
	
	if (_resultColor)
		_resultColorView.backgroundColor = _resultColor;
}

//------------------------------------------------------------------------------

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

//------------------------------------------------------------------------------

- (NSUInteger) supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		return UIInterfaceOrientationMaskAll;
	else
		return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

//------------------------------------------------------------------------------

- (UIRectEdge) edgesForExtendedLayout
{
	return UIRectEdgeNone;
}

//------------------------------------------------------------------------------
#pragma mark	IB actions
//------------------------------------------------------------------------------

- (IBAction) takeBarValue: (LazyPDFColorBarPicker*) sender
{
	_hue = sender.value;
	
	_squareView.hue = _hue;
	_squarePicker.hue = _hue;
	
	[self updateResultColor];
}

//------------------------------------------------------------------------------

- (IBAction) takeSquareValue: (LazyPDFColorSquarePicker*) sender
{
	_saturation = sender.value.x;
	_brightness = sender.value.y;
	
	[self updateResultColor];
}

//------------------------------------------------------------------------------

- (IBAction) takeBackgroundColor: (UIView*) sender
{
	self.resultColor = sender.backgroundColor;
}

//------------------------------------------------------------------------------

- (IBAction) done: (id) sender
{
	[self.delegate colorPickerControllerDidFinish: self];
}

//------------------------------------------------------------------------------
#pragma mark	Properties
//------------------------------------------------------------------------------

- (void) LazyPDFormDelegateDidChangeColor
{
	if (self.delegate && [(id) self.delegate respondsToSelector: @selector(colorPickerControllerDidChangeColor:)])
		[self.delegate colorPickerControllerDidChangeColor: self];
}

//------------------------------------------------------------------------------

- (void) updateResultColor
{
	// This is used when code internally causes the update.  We do this so that
	// we don't cause push-back on the HSV values in case there are rounding
	// differences or anything.
	
	[self willChangeValueForKey: @"resultColor"];
	
	_resultColor = [UIColor colorWithHue: _hue
							  saturation: _saturation
							  brightness: _brightness
								   alpha: 1.0f];
	
	[self didChangeValueForKey: @"resultColor"];
	
	_resultColorView.backgroundColor = _resultColor;
	
	[self LazyPDFormDelegateDidChangeColor];
}

//------------------------------------------------------------------------------

- (void) setResultColor: (UIColor*) newValue
{
	if (![_resultColor isEqual: newValue]) {
		_resultColor = newValue;
		
		float h = _hue;
		HSVFromUIColor(newValue, &h, &_saturation, &_brightness);
		
		if ((h == 0.0 && _hue == 1.0) || (h == 1.0 && _hue == 0.0)) {
			// these are equivalent, so do nothing
		}
		else if (h != _hue) {
			_hue = h;
			
			_barPicker.value = _hue;
			_squareView.hue = _hue;
			_squarePicker.hue = _hue;
		}
		
		_squarePicker.value = CGPointMake(_saturation, _brightness);
		
		_resultColorView.backgroundColor = _resultColor;
		
		[self LazyPDFormDelegateDidChangeColor];
	}
}

//------------------------------------------------------------------------------

- (void) setSourceColor: (UIColor*) newValue
{
	if (![_sourceColor isEqual: newValue]) {
		_sourceColor = newValue;
		
		_sourceColorView.backgroundColor = _sourceColor;
		
		self.resultColor = newValue;
	}
}

//------------------------------------------------------------------------------
#pragma mark	UIViewController(UIPopoverController) methods
//------------------------------------------------------------------------------

- (CGSize) contentSizeForViewInPopover
{
	return [[self class] idealSizeForViewInPopover];
}

//------------------------------------------------------------------------------

@end

//==============================================================================
