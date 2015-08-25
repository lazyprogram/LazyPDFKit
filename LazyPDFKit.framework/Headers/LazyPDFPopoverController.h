//
//  LazyPDFPopoverController.h
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
#import <QuartzCore/QuartzCore.h>

#import "ARCMacros.h"

#import "LazyPDFPopoverView.h"
#import "LazyPDFTouchView.h"


@class LazyPDFPopoverController;

@protocol LazyPDFPopoverControllerDelegate <NSObject>

@optional
- (void)popoverControllerDidDismissPopover:(LazyPDFPopoverController *)popoverController;
- (void)presentedNewPopoverController:(LazyPDFPopoverController *)newPopoverController 
          shouldDismissVisiblePopover:(LazyPDFPopoverController*)visiblePopoverController;
@end

@interface LazyPDFPopoverController : UIViewController
{
    UIView *_parentView;
}
//ARC-enable and disable support
#if __has_feature(objc_arc)
    @property(nonatomic,weak) id<LazyPDFPopoverControllerDelegate> delegate;
#else
    @property(nonatomic,assign) id<LazyPDFPopoverControllerDelegate> delegate;
#endif

/** @brief LazyPDFPopoverArrowDirectionAny, LazyPDFPopoverArrowDirectionVertical or LazyPDFPopoverArrowDirectionHorizontal for automatic arrow direction.
 **/

/** @brief allow reading in order to integrate other open-source **/
@property(nonatomic,readonly) LazyPDFTouchView* touchView;
@property(nonatomic,readonly) LazyPDFPopoverView* contentView;

@property(nonatomic,assign) LazyPDFPopoverArrowDirection arrowDirection;

@property(nonatomic,assign) CGSize contentSize;
@property(nonatomic,assign) CGPoint origin;
@property(nonatomic,assign) CGFloat alpha;

/** @brief The tint of the popover. **/
@property(nonatomic,assign) LazyPDFPopoverTint tint;

/** @brief Popover border, default is YES **/
@property(nonatomic, assign) BOOL border;

/** @brief Initialize the popover with the content view controller
 **/
-(id)initWithViewController:(UIViewController*)viewController;
-(id)initWithViewController:(UIViewController*)viewController
				   delegate:(id<LazyPDFPopoverControllerDelegate>)delegate;

/** @brief Presenting the popover from a specified view **/
-(void)presentPopoverFromView:(UIView*)fromView;

/** @brief Presenting the popover from a specified point **/
-(void)presentPopoverFromPoint:(CGPoint)fromPoint;

/** @brief Dismiss the popover **/
-(void)dismissPopoverAnimated:(BOOL)animated;

/** @brief Dismiss the popover with completion block for post-animation cleanup **/
typedef void (^LazyPDFPopoverCompletion)();
-(void)dismissPopoverAnimated:(BOOL)animated completion:(LazyPDFPopoverCompletion)completionBlock;

/** @brief Hide the shadows to get better performances **/
-(void)setShadowsHidden:(BOOL)hidden;

/** @brief Refresh popover **/
-(void)setupView;


@end
