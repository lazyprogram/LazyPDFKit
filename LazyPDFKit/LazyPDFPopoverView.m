//
//  LazyPDFPopoverView.m
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


#import "LazyPDFPopoverView.h"
#import "ARCMacros.h"

#define LazyPDF_POPOVER_ARROW_HEIGHT 20.0
#define LazyPDF_POPOVER_ARROW_BASE 20.0
#define LazyPDF_POPOVER_RADIUS 10.0

//iVars
@interface LazyPDFPopoverView()
{
    //default LazyPDFPopoverArrowDirectionUp
    LazyPDFPopoverArrowDirection _arrowDirection;
    UIView *_contentView;
    UILabel *_titleLabel;
}
@end


@interface LazyPDFPopoverView(Private)
-(void)setupViews;
@end


@implementation LazyPDFPopoverView
@synthesize title;
@synthesize relativeOrigin;
@synthesize tint = _tint;
@synthesize draw3dBorder = _draw3dBorder;
@synthesize border = _border;

-(void)dealloc
{
#ifdef LazyPDF_DEBUG
    NSLog(@"LazyPDFPopoverView dealloc");
#endif

    SAFE_ARC_RELEASE(_titleLabel);
    SAFE_ARC_SUPER_DEALLOC();
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //we need to set the background as clear to see the view below
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(-3, 3);

        //to get working the animations
        self.contentMode = UIViewContentModeRedraw;

        //3d border default is on
        self.draw3dBorder = YES;
        
        //border
        self.border = YES;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        
        self.tint = LazyPDFPopoverDefaultTint;
        
        [self addSubview:_titleLabel];
        [self setupViews];
    }
    return self;
}

#pragma mark setters
-(void)setArrowDirection:(LazyPDFPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self setNeedsDisplay];
}

-(LazyPDFPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}
-(void)addContentView:(UIView *)contentView
{
    if(_contentView != contentView)
    {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        [self addSubview:_contentView];
    }
    [self setupViews];
}

-(void)setBorder:(BOOL)border
{
    _border = border;
    //NO BORDER
    if(self.border == NO) {
        _contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        self.draw3dBorder = NO;
        _contentView.layer.cornerRadius = LazyPDF_POPOVER_RADIUS;
    }
}

#pragma mark drawing

//the content with the arrow
-(CGPathRef)newContentPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(LazyPDFPopoverArrowDirection)direction
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat ah = LazyPDF_POPOVER_ARROW_HEIGHT; //is the height of the triangle of the arrow
    CGFloat aw = LazyPDF_POPOVER_ARROW_BASE/2.0; //is the 1/2 of the base of the arrow
    CGFloat radius = LazyPDF_POPOVER_RADIUS;
    CGFloat b = borderWidth;
    
    //NO BORDER
    if(self.border == NO) {
        b = 10.0;
    }
    
    CGRect rect;
    if(direction == LazyPDFPopoverArrowDirectionUp)
    {
        
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = ah + b;        
    }
    else if(direction == LazyPDFPopoverArrowDirectionDown)
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;                
    }
    
    
    else if(direction == LazyPDFPopoverArrowDirectionRight)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;                
    }
    else if(direction == LazyPDFPopoverArrowDirectionLeft)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = ah + b;
        rect.origin.y = b;
    }
    
    //NO ARROW
    else
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;        
    }
    
    
    
    //the arrow will be near the origin
    CGFloat ax = self.relativeOrigin.x - aw; //the start of the arrow when UP or DOWN
    if(ax < aw + b) ax = aw + b;
    else if (ax +2*aw + 2*b> self.bounds.size.width) ax = self.bounds.size.width - 2*aw - 2*b;

    CGFloat ay = self.relativeOrigin.y - aw; //the start of the arrow when RIGHT or LEFT
    if(ay < aw + b) ay = aw + b;
    else if (ay +2*aw + 2*b > self.bounds.size.height) ay = self.bounds.size.height - 2*aw - 2*b;
    
    
    
    //ROUNDED RECT
    // arrow UP
    CGRect  innerRect = CGRectInset(rect, radius, radius);
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;

    
    
    //drawing the border with arrow
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
 
    //top arrow
    if(direction == LazyPDFPopoverArrowDirectionUp)
    {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
        
    }
    

    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);

    //right arrow
    if(direction == LazyPDFPopoverArrowDirectionRight)
    {
        CGPathAddLineToPoint(path, NULL, outside_right, ay);
        CGPathAddLineToPoint(path, NULL, outside_right + ah+b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_right, ay + 2*aw);
    }
       

	CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);

    //down arrow
    if(direction == LazyPDFPopoverArrowDirectionDown)
    {
        CGPathAddLineToPoint(path, NULL, ax+2*aw, outside_bottom);
        CGPathAddLineToPoint(path, NULL, ax+aw, outside_bottom + ah);
        CGPathAddLineToPoint(path, NULL, ax, outside_bottom);
    }

	CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
    
    //left arrow
    if(direction == LazyPDFPopoverArrowDirectionLeft)
    {
        CGPathAddLineToPoint(path, NULL, outside_left, ay + 2*aw);
        CGPathAddLineToPoint(path, NULL, outside_left - ah-b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_left, ay);
    }
    

	CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);

    
    CGPathCloseSubpath(path);
    
    return path;
}



-(CGGradientRef)newGradient
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // make a gradient
    CGFloat colors[8];
    
    if(self.tint == LazyPDFPopoverBlackTint)
    {
        if(_arrowDirection == LazyPDFPopoverArrowDirectionUp)
        {
            colors[0] = colors[1] = colors[2] = 0.6;
            colors[4] = colors[5] = colors[6] = 0.1;
            colors[3] = colors[7] = 1.0;
        }
        else
        {
            colors[0] = colors[1] = colors[2] = 0.4;
            colors[4] = colors[5] = colors[6] = 0.1;
            colors[3] = colors[7] = 1.0;
        }        
    }
    
    else if(self.tint == LazyPDFPopoverLightGrayTint)
    {
        if(_arrowDirection == LazyPDFPopoverArrowDirectionUp)
        {
            colors[0] = colors[1] = colors[2] = 0.8;
            colors[4] = colors[5] = colors[6] = 0.3;
            colors[3] = colors[7] = 1.0;
        }
        else
        {
            colors[0] = colors[1] = colors[2] = 0.6;
            colors[4] = colors[5] = colors[6] = 0.1;
            colors[3] = colors[7] = 1.0;
        }        
    }
    else if(self.tint == LazyPDFPopoverRedTint)
    {
        if(_arrowDirection == LazyPDFPopoverArrowDirectionUp)
        {
            colors[0] = 0.72; colors[1] = 0.35; colors[2] = 0.32;
            colors[4] = 0.36; colors[5] = 0.0;  colors[6] = 0.09;
            colors[3] = colors[7] = 1.0;

        }
        else
        {
            colors[0] = 0.82; colors[1] = 0.45; colors[2] = 0.42;
            colors[4] = 0.36; colors[5] = 0.0;  colors[6] = 0.09;
            colors[3] = colors[7] = 1.0;
        }        
    }
    
    else if(self.tint == LazyPDFPopoverGreenTint)
    {
        if(_arrowDirection == LazyPDFPopoverArrowDirectionUp)
        {
            colors[0] = 0.35; colors[1] = 0.72; colors[2] = 0.17;
            colors[4] = 0.18; colors[5] = 0.30;  colors[6] = 0.03;
            colors[3] = colors[7] = 1.0;
            
        }
        else
        {
            colors[0] = 0.45; colors[1] = 0.82; colors[2] = 0.27;
            colors[4] = 0.18; colors[5] = 0.30;  colors[6] = 0.03;
            colors[3] = colors[7] = 1.0;
        }        
    }
    else if(self.tint == LazyPDFPopoverWhiteTint)
    {
        colors[0] = colors[1] = colors[2] = 1.0;
        colors[0] = colors[1] = colors[2] = 1.0;
        colors[3] = colors[7] = 1.0;
    }
    

    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);

    CFRelease(colorSpace);
    return gradient;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    

    CGGradientRef gradient = [self newGradient];
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();    
    CGContextSaveGState(ctx);
    
    //content fill
    CGPathRef contentPath = [self newContentPathWithBorderWidth:2.0 arrowDirection:_arrowDirection];
    
    
    CGContextAddPath(ctx, contentPath);
    CGContextClip(ctx);

    //  Draw a linear gradient from top to bottom
    CGPoint start;
    CGPoint end;
    if(_arrowDirection == LazyPDFPopoverArrowDirectionUp || _arrowDirection == LazyPDFPopoverNoArrow)
    {
        start = CGPointMake(self.bounds.size.width/2.0, 0);
        end = CGPointMake(self.bounds.size.width/2.0,40);
    }
    else 
    {
        start = CGPointMake(self.bounds.size.width/2.0, 0);
        end = CGPointMake(self.bounds.size.width/2.0,20);
    }


    
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    
    CGGradientRelease(gradient);
    //fill the other part of path
    if(self.tint == LazyPDFPopoverBlackTint)
    {
        CGContextSetRGBFillColor(ctx, 0.1, 0.1, 0.1, 1.0);        
    }
    else if(self.tint == LazyPDFPopoverLightGrayTint)
    {
        CGContextSetRGBFillColor(ctx, 0.3, 0.3, 0.3, 1.0);        
    }
    else if(self.tint == LazyPDFPopoverRedTint)
    {
        CGContextSetRGBFillColor(ctx, 0.36, 0.0, 0.09, 1.0);        
    }
    else if(self.tint == LazyPDFPopoverGreenTint)
    {
        CGContextSetRGBFillColor(ctx, 0.18, 0.30, 0.03, 1.0);        
    }
    else if(self.tint == LazyPDFPopoverWhiteTint)
    {
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 1.0);
    }

    
    CGContextFillRect(ctx, CGRectMake(0, end.y, self.bounds.size.width, self.bounds.size.height-end.y));
    //internal border
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, contentPath);
    CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
    CGPathRelease(contentPath);

    //external border
    CGPathRef externalBorderPath = [self newContentPathWithBorderWidth:1.0 arrowDirection:_arrowDirection];
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, externalBorderPath);
    CGContextSetRGBStrokeColor(ctx, 0.4, 0.4, 0.4, 1.0);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
    CGPathRelease(externalBorderPath);

    //3D border of the content view
    if(self.draw3dBorder) {
        CGRect cvRect = _contentView.frame;
        //firstLine
        CGContextSetRGBStrokeColor(ctx, 0.7, 0.7, 0.7, 1.0);
        CGContextStrokeRect(ctx, cvRect);
        //secondLine
        cvRect.origin.x -= 1; cvRect.origin.y -= 1; cvRect.size.height += 2; cvRect.size.width += 2;
        CGContextSetRGBStrokeColor(ctx, 0.4, 0.4, 0.4, 1.0);
        CGContextStrokeRect(ctx, cvRect);        
    }
    
    
    CGContextRestoreGState(ctx);
}

-(void)setupViews
{
    //content posizion and size
    CGRect contentRect = _contentView.frame;
	
    if(_arrowDirection == LazyPDFPopoverArrowDirectionUp)
    {
        contentRect.origin = CGPointMake(10, 60);  
        contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-70);
        _titleLabel.frame = CGRectMake(10, 30, self.bounds.size.width-20, 20);    
		if (self.title==nil || self.title.length==0) {
			contentRect.origin = CGPointMake(10, 30);
			contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-40);
		}
    }
    else if(_arrowDirection == LazyPDFPopoverArrowDirectionDown)
    {
        contentRect.origin = CGPointMake(10, 40);        
        contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-70);
        _titleLabel.frame = CGRectMake(10, 10, self.bounds.size.width-20, 20);
		if (self.title==nil || self.title.length==0) {
			contentRect.origin = CGPointMake(10, 10); 
			contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-40);
		}
    }
    
    
    else if(_arrowDirection == LazyPDFPopoverArrowDirectionRight)
    {
        contentRect.origin = CGPointMake(10, 40);        
        contentRect.size = CGSizeMake(self.bounds.size.width-40, self.bounds.size.height-50);
        _titleLabel.frame = CGRectMake(10, 10, self.bounds.size.width-20, 20);    
		if (self.title==nil || self.title.length==0) {
			 contentRect.origin = CGPointMake(10, 10);
			contentRect.size = CGSizeMake(self.bounds.size.width-40, self.bounds.size.height-20);
		}
    }

    else if(_arrowDirection == LazyPDFPopoverArrowDirectionLeft)
    {
        contentRect.origin = CGPointMake(10 + LazyPDF_POPOVER_ARROW_HEIGHT, 40);        
        contentRect.size = CGSizeMake(self.bounds.size.width-40, self.bounds.size.height-50);
        _titleLabel.frame = CGRectMake(10, 10, self.bounds.size.width-20, 20); 
		if (self.title==nil || self.title.length==0) {
			contentRect.origin = CGPointMake(10+ LazyPDF_POPOVER_ARROW_HEIGHT, 10);
			contentRect.size = CGSizeMake(self.bounds.size.width-40, self.bounds.size.height-20);
		}
    }
    
    else if(_arrowDirection == LazyPDFPopoverNoArrow)
    {
        contentRect.origin = CGPointMake(10, 40);
        contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-50);
        _titleLabel.frame = CGRectMake(10, 10, self.bounds.size.width-20, 20);
		if (self.title==nil || self.title.length==0) {
			contentRect.origin = CGPointMake(10, 30);
			contentRect.size = CGSizeMake(self.bounds.size.width-20, self.bounds.size.height-40);
		}
    }

    _contentView.frame = contentRect;
    _titleLabel.text = self.title;    
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setupViews];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setupViews];
}

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setupViews];
}
@end
