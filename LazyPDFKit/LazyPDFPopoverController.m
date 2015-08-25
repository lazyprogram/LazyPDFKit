//
//  LazyPDFPopoverController.m
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



#import "LazyPDFPopoverController.h"

//ivars
@interface LazyPDFPopoverController()
{
    LazyPDFTouchView *_touchView;
    LazyPDFPopoverView *_contentView;
    UIViewController *_viewController;
    UIWindow *_window;
    UIView *_fromView;
    UIDeviceOrientation _deviceOrientation;
    
    BOOL _shadowsHidden;
    CGColorRef _shadowColor;
}
@end


//private methods
@interface LazyPDFPopoverController(Private)
-(CGPoint)originFromView:(UIView*)fromView;


-(CGFloat)parentWidth;
-(CGFloat)parentHeight;

#pragma mark Space management
/* This methods help the controller to found a proper way to display the view.
 * If the "from point" will be on the left, the arrow will be on the left and the 
 * view will be move on the right of the from point.
 */

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v;

@end

@implementation LazyPDFPopoverController
@synthesize delegate = _delegate;
@synthesize contentView = _contentView;
@synthesize touchView = _touchView;
@synthesize contentSize = _contentSize;
@synthesize origin = _origin;
@synthesize arrowDirection = _arrowDirection;
@synthesize tint = _tint;
@synthesize border = _border;
@synthesize alpha = _alpha;

-(void)addObservers
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];   
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(deviceOrientationDidChange:) 
     name:@"UIDeviceOrientationDidChangeNotification" 
     object:nil]; 

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willPresentNewPopover:) name:@"LazyPDFNewPopoverPresented" object:nil];
    
    _deviceOrientation = [UIDevice currentDevice].orientation;
    
}

-(void)removeObservers
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewController removeObserver:self forKeyPath:@"title"];
}


-(void)dealloc
{
    [self removeObservers];
    if(_shadowColor) CGColorRelease(_shadowColor);
    
#ifdef LazyPDF_DEBUG
    NSLog(@"LazyPDFPopoverController dealloc");
#endif

    SAFE_ARC_RELEASE(_contentView);
    SAFE_ARC_RELEASE(_touchView);
    self.delegate = nil;
    
    SAFE_ARC_RELEASE(_viewController);
    _viewController = nil;
    
    SAFE_ARC_SUPER_DEALLOC();
}

-(id)initWithViewController:(UIViewController*)viewController {
	return [self initWithViewController:viewController delegate:nil];
}

-(id)initWithViewController:(UIViewController*)viewController
				   delegate:(id<LazyPDFPopoverControllerDelegate>)delegate
{
    self = [super init];
    if(self)
    {
		self.delegate = delegate;
        
        self.alpha = 1.0;
        self.arrowDirection = LazyPDFPopoverArrowDirectionAny;
        self.view.userInteractionEnabled = YES;
        _border = YES;
        
        _touchView = [[LazyPDFTouchView alloc] initWithFrame:self.view.bounds];
        _touchView.backgroundColor = [UIColor clearColor];
        _touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _touchView.clipsToBounds = NO;
        [self.view addSubview:_touchView];
        
#if __has_feature(objc_arc)
        //ARC on
        id bself = self;
#else
        //ARC off
        __block id bself = self;
#endif
        
        [_touchView setTouchedOutsideBlock:^{
            [bself dismissPopoverAnimated:YES];
        }];

        self.contentSize = CGSizeMake(200, 300); //default size

        _contentView = [[LazyPDFPopoverView alloc] initWithFrame:CGRectMake(0, 0, 
                                              self.contentSize.width, self.contentSize.height)];
        
        _viewController = SAFE_ARC_RETAIN(viewController);
        
        [_touchView addSubview:_contentView];
        
        [_contentView addContentView:_viewController.view];
        _viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.clipsToBounds = NO;

        _touchView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _touchView.clipsToBounds = NO;
        
        //setting contentview
        _contentView.title = _viewController.title;
        _contentView.clipsToBounds = NO;
        
        [_viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


-(void)setTint:(LazyPDFPopoverTint)tint
{
    _contentView.tint = tint;
    [_contentView setNeedsDisplay];
}

-(LazyPDFPopoverTint)tint
{
    return _contentView.tint;
}

#pragma mark - View lifecycle

-(void)setupView
{
    self.view.frame = CGRectMake(0, 0, [self parentWidth], [self parentHeight]);
    _touchView.frame = self.view.bounds;
    
    //view position, size and best arrow direction
    [self bestArrowDirectionAndFrameFromView:_fromView];

    [_contentView setNeedsDisplay];
    [_touchView setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize and load the content view
    [_contentView setArrowDirection:LazyPDFPopoverArrowDirectionUp];
    [_contentView addContentView:_viewController.view];

    [self setupView];
    [self addObservers];
}

#pragma mark Orientation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ([_viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
		return [_viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
	return YES;
}


#pragma mark presenting

-(CGFloat)parentWidth
{
    return _parentView.bounds.size.width;
    //return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.width : _parentView.frame.size.height;
}
-(CGFloat)parentHeight
{
    return _parentView.bounds.size.height;
    //return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.height : _parentView.frame.size.width;
}

-(void)presentPopoverFromPoint:(CGPoint)fromPoint
{
    self.origin = fromPoint;
    
    //NO BORDER
    if(self.border == NO)
    {
        _viewController.title = nil;
        _viewController.view.clipsToBounds = YES;
    }
    
    _contentView.relativeOrigin = [_parentView convertPoint:fromPoint toView:_contentView];

    [self.view removeFromSuperview];
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0)
    {
          _parentView=nil;
        _window = [windows objectAtIndex:0];
        //keep the first subview
        if(_window.subviews.count > 0)
        {
            _parentView = [_window.subviews objectAtIndex:0];
            [_parentView addSubview:self.view];
            [_viewController viewDidAppear:YES];
        }
        
   }
    else
    {
        [self dismissPopoverAnimated:NO];
    }
    
    
    
    [self setupView];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        
        self.view.alpha = self.alpha;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LazyPDFNewPopoverPresented" object:self];
    
    //navigation controller bar fix
    if([_viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nc = (UINavigationController*)_viewController;
        UINavigationBar *b = nc.navigationBar;
        CGRect bar_frame = b.frame;
        bar_frame.origin.y = 0;
        b.frame = bar_frame;
    }
}


-(CGPoint)originFromView:(UIView*)fromView
{
    CGPoint p;
    if([_contentView arrowDirection] == LazyPDFPopoverArrowDirectionUp ||
       [_contentView arrowDirection] == LazyPDFPopoverNoArrow)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y + fromView.frame.size.height;
    }
    else if([_contentView arrowDirection] == LazyPDFPopoverArrowDirectionDown)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y;        
    }
    else if([_contentView arrowDirection] == LazyPDFPopoverArrowDirectionLeft)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    }
    else if([_contentView arrowDirection] == LazyPDFPopoverArrowDirectionRight)
    {
        p.x = fromView.frame.origin.x;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    }

    return p;
}

-(void)presentPopoverFromView:(UIView*)fromView
{
    SAFE_ARC_RELEASE(_fromView);
    _fromView = SAFE_ARC_RETAIN(fromView);
    [self presentPopoverFromPoint:[self originFromView:_fromView]];
}

-(void)dismissPopover
{
    [self.view removeFromSuperview];
    if([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
    {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
     _window=nil;
     _parentView=nil;
    
}

-(void)dismissPopoverAnimated:(BOOL)animated {
	[self dismissPopoverAnimated:animated completion:nil];
}

-(void)dismissPopoverAnimated:(BOOL)animated completion:(LazyPDFPopoverCompletion)completionBlock
{
    if(animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self dismissPopover];
			if (completionBlock)
				completionBlock();
        }];
    }
    else
    {
        [self dismissPopover];
		if (completionBlock)
			completionBlock();
    }
         
}

-(void)setOrigin:(CGPoint)origin
{
    _origin = origin;
}

#pragma mark observing



-(void)deviceOrientationDidChange:(NSNotification*)notification
{
	_deviceOrientation = [UIDevice currentDevice].orientation;

	BOOL shouldResetView = NO;

    //iOS6 has a new orientation implementation.
    //we ask to reset the view if is >= 6.0
	if ([_viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] &&
        [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
	{
		UIInterfaceOrientation interfaceOrientation;
		switch (_deviceOrientation)
		{
			case UIDeviceOrientationLandscapeLeft:
				interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
				break;
			case UIDeviceOrientationLandscapeRight:
				interfaceOrientation = UIInterfaceOrientationLandscapeRight;
				break;
			case UIDeviceOrientationPortrait:
				interfaceOrientation = UIInterfaceOrientationPortrait;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
				break;
			default:
				return;	// just ignore face up / face down, etc.
		}
	}
	else
	{
		shouldResetView = YES;
	}

	if (shouldResetView)
		[UIView animateWithDuration:0.2 animations:^{
			[self setupView]; 
		}];
}

-(void)willPresentNewPopover:(NSNotification*)notification
{
    if(notification.object != self)
    {
        if([self.delegate respondsToSelector:@selector(presentedNewPopoverController:shouldDismissVisiblePopover:)])
        {
            [self.delegate presentedNewPopoverController:notification.object
                             shouldDismissVisiblePopover:self];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _viewController && [keyPath isEqualToString:@"title"])
    {
        _contentView.title = _viewController.title;
        [_contentView setNeedsDisplay];
    }
}


#pragma mark Space management

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v
{
    // thanks @Niculcea
    // If we presentFromPoint with _fromView nil will calculate based on self.orgin with 2x2 size.
    // Fix for presentFromPoint from avolovoy's LazyPDFPopover fork
    float width = 2.0f;
    float height = 2.0f;
    CGPoint p = CGPointMake(self.origin.x, self.origin.y);
    
    if (v != nil) {
        p = [v.superview convertPoint:v.frame.origin toView:self.view];
        width = v.frame.size.width;
        height = v.frame.size.height;
    }
    
    
    CGFloat ht = p.y; //available vertical space on top of the view
    CGFloat hb = [self parentHeight] -  (p.y + v.frame.size.height); //on the bottom
    CGFloat wl = p.x; //on the left
    CGFloat wr = [self parentWidth] - (p.x + v.frame.size.width); //on the right
        
    CGFloat best_h = MAX(ht, hb); //much space down or up ?
    CGFloat best_w = MAX(wl, wr);
    
    CGRect r;
    r.size = self.contentSize;

    LazyPDFPopoverArrowDirection bestDirection;
    
    //if the user wants vertical arrow, check if the content will fit vertically 
    if(LazyPDFPopoverArrowDirectionIsVertical(self.arrowDirection) || 
       (self.arrowDirection == LazyPDFPopoverArrowDirectionAny && best_h >= best_w))
    {

        //ok, will be vertical
        if(ht == best_h || self.arrowDirection == LazyPDFPopoverArrowDirectionDown)
        {
            //on the top and arrow down
            bestDirection = LazyPDFPopoverArrowDirectionDown;
            
            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y - r.size.height;
        }
        else
        {
            //on the bottom and arrow up
            bestDirection = LazyPDFPopoverArrowDirectionUp;

            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y + v.frame.size.height;
        }
        

    }
    
    
    else 
    {
        //ok, will be horizontal
        //the arrow must NOT be forced to left
        if((wl == best_w || self.arrowDirection == LazyPDFPopoverArrowDirectionRight) && self.arrowDirection != LazyPDFPopoverArrowDirectionLeft)
        {
            //on the left and arrow right
            bestDirection = LazyPDFPopoverArrowDirectionRight;

            r.origin.x = p.x - r.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;

        }
        else
        {
            //on the right then arrow left
            bestDirection = LazyPDFPopoverArrowDirectionLeft;

            r.origin.x = p.x + v.frame.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;
        }
        

    }
    
    
    
    //need to moved left ? 
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.origin.x = [self parentWidth] - r.size.width;
    }
    
    //need to moved right ?
    else if(r.origin.x < 0)
    {
        r.origin.x = 0;
    }
    
    
    //need to move up?
    if(r.origin.y < 0)
    {
        CGFloat old_y = r.origin.y;
        r.origin.y = 0;
        r.size.height += old_y;
    }
    
    //need to be resized horizontally ?
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.size.width = [self parentWidth] - r.origin.x;
    }
    
    //need to be resized vertically ?
    if(r.origin.y + r.size.height > [self parentHeight])
    {
        r.size.height = [self parentHeight] - r.origin.y;
    }
    
    
    if([[UIApplication sharedApplication] isStatusBarHidden] == NO)
    {
        if(r.origin.y <= 20) r.origin.y += 20;
    }

    //check if the developer wants and arrow
    if(self.arrowDirection != LazyPDFPopoverNoArrow)
        _contentView.arrowDirection = bestDirection;
    
    //no arrow
    else _contentView.arrowDirection = LazyPDFPopoverNoArrow;

    //using the frame calculated
    _contentView.frame = r;

    self.origin = CGPointMake(p.x + v.frame.size.width/2.0, p.y + v.frame.size.height/2.0);
    _contentView.relativeOrigin = [_parentView convertPoint:self.origin toView:_contentView];

    return r;
}


-(void)setShadowsHidden:(BOOL)hidden
{
    _shadowsHidden = hidden;
    if(hidden)
    {
        _contentView.layer.shadowOpacity = 0;
        _contentView.layer.shadowRadius = 0;
        _contentView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowColor = CGColorRetain(_contentView.layer.shadowColor);
        _contentView.layer.shadowColor = nil;
    }
    else
    {
        _contentView.layer.shadowOpacity = 0.7;
        _contentView.layer.shadowRadius = 5;
        _contentView.layer.shadowOffset = CGSizeMake(-3, 3);
        _contentView.layer.shadowColor = _shadowColor;
        if(_shadowColor)
        {
            CGColorRelease(_shadowColor);
            _shadowColor=nil;
        }
    }
}

#pragma mark 3D Border

-(void)setBorder:(BOOL)border
{
    _border = border;
    _contentView.border = border;
    [_contentView setNeedsDisplay];
}

#pragma mark Transparency
-(void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    self.view.alpha = alpha;
}




@end
