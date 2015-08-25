//
//  LazyPDFDrawToolbar.m
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 26/2/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import "LazyPDFConstants.h"
#import "LazyPDFDrawToolbar.h"
#import "LazyPDFDocument.h"

#import <MessageUI/MessageUI.h>

@implementation LazyPDFDrawToolbar
{
    UIButton *markButton;
    
    UIImage *markImageN;
    UIImage *markImageY;
}

#pragma mark - Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f

#define BUTTON_SPACE 1.0f
#define BUTTON_WIDTH 30.0f

#define BUTTON_FONT_SIZE 15.0f
#define TEXT_BUTTON_PADDING 24.0f

#define ICON_BUTTON_HEIGHT 30.0f

#define TITLE_FONT_SIZE 19.0f
#define TITLE_HEIGHT 28.0f

#pragma mark - Properties

@synthesize delegate;
@synthesize penButton;
@synthesize textButton;
@synthesize highlightButton;
@synthesize lineButton;
@synthesize squareButton;
@synthesize circleButton;
@synthesize circleFillButton;
@synthesize eraserButton;
@synthesize colorButton;
@synthesize undoButton;
@synthesize redoButton;
@synthesize clearButton;

#pragma mark - LazyPDFMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame document:nil];
}

- (instancetype)initWithFrame:(CGRect)frame document:(LazyPDFDocument *)document
{
    assert(document != nil); // Must have a valid LazyPDFDocument
    
    if ((self = [super initWithFrame:frame]))
    {
        CGFloat viewHeight = self.bounds.size.height; // Toolbar view width

#if (LazyPDF_FLAT_UI == TRUE) // Option
        UIImage *buttonH = nil; UIImage *buttonN = nil;
#else
        UIImage *buttonH = [[UIImage imageNamed:@"LazyPDF-Button-H" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        UIImage *buttonN = [[UIImage imageNamed:@"LazyPDF-Button-N" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
#endif // end of LazyPDF_FLAT_UI Option
        
        BOOL largeDevice = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        
        const CGFloat buttonSpacing = BUTTON_SPACE; const CGFloat iconButtonHeight = ICON_BUTTON_HEIGHT;
        
        CGFloat titleY = BUTTON_Y; CGFloat titleHeight = (viewHeight - (titleY + titleY));
        
        CGFloat leftButtonY = BUTTON_Y; // Left-side button start X position
        
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        
        //Pen Button
        penButton = [UIButton buttonWithType:UIButtonTypeCustom];
        penButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [penButton setImage:[UIImage imageNamed:@"pen-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [penButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [penButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [penButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        penButton.autoresizingMask = UIViewAutoresizingNone;
        penButton.exclusiveTouch = YES;
        penButton.tag = 1;
        [self addSubview:penButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Text Button
        textButton = [UIButton buttonWithType:UIButtonTypeCustom];
        textButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [textButton setImage:[UIImage imageNamed:@"text-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [textButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [textButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        textButton.autoresizingMask = UIViewAutoresizingNone;
        textButton.exclusiveTouch = YES;
        textButton.tag = 2;
        [self addSubview:textButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Highlight Button
        highlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        highlightButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [highlightButton setImage:[UIImage imageNamed:@"squarefill-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [highlightButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [highlightButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [highlightButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        highlightButton.autoresizingMask = UIViewAutoresizingNone;
        highlightButton.exclusiveTouch = YES;
        highlightButton.tag = 3;
        [self addSubview:highlightButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Line Button
        lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lineButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [lineButton setImage:[UIImage imageNamed:@"line-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [lineButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [lineButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [lineButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        lineButton.autoresizingMask = UIViewAutoresizingNone;
        lineButton.exclusiveTouch = YES;
        lineButton.tag = 4;
        [self addSubview:lineButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Square Button
        squareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        squareButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [squareButton setImage:[UIImage imageNamed:@"square-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [squareButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [squareButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [squareButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        squareButton.autoresizingMask = UIViewAutoresizingNone;
        squareButton.exclusiveTouch = YES;
        squareButton.tag = 5;
        [self addSubview:squareButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Circle Button
        circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        circleButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [circleButton setImage:[UIImage imageNamed:@"circle-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [circleButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [circleButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [circleButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        circleButton.autoresizingMask = UIViewAutoresizingNone;
        circleButton.exclusiveTouch = YES;
        circleButton.tag = 6;
        [self addSubview:circleButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //CircleFill Button
        circleFillButton = [UIButton buttonWithType:UIButtonTypeCustom];
        circleFillButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [circleFillButton setImage:[UIImage imageNamed:@"circlefill-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [circleFillButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [circleFillButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [circleFillButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        circleFillButton.autoresizingMask = UIViewAutoresizingNone;
        circleFillButton.exclusiveTouch = YES;
        circleFillButton.tag = 7;
        [self addSubview:circleFillButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Eraser Button
        eraserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eraserButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [eraserButton setImage:[UIImage imageNamed:@"eraser-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [eraserButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [eraserButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [eraserButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        eraserButton.autoresizingMask = UIViewAutoresizingNone;
        eraserButton.exclusiveTouch = YES;
        eraserButton.tag = 8;
        [self addSubview:eraserButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Color Button
        colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [colorButton setImage:[self getColorButtonImage:[UIColor blueColor] withSize:[NSNumber numberWithFloat:17.f]] forState:UIControlStateNormal];
        [colorButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [colorButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [colorButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        colorButton.autoresizingMask = UIViewAutoresizingNone;
        colorButton.exclusiveTouch = YES;
        colorButton.tag = 9;
        [self addSubview:colorButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        
        //Undo Button
        undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        undoButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [undoButton setImage:[UIImage imageNamed:@"undo-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [undoButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [undoButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        undoButton.autoresizingMask = UIViewAutoresizingNone;
        undoButton.exclusiveTouch = YES;
        undoButton.tag = 10;
        [self addSubview:undoButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Redo Button
        redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        redoButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [redoButton setImage:[UIImage imageNamed:@"redo-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [redoButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [redoButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [redoButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        redoButton.autoresizingMask = UIViewAutoresizingNone;
        redoButton.exclusiveTouch = YES;
        redoButton.tag = 11;
        [self addSubview:redoButton]; leftButtonY += (iconButtonHeight + buttonSpacing);
        titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        //Clear Button
        clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        clearButton.frame = CGRectMake(BUTTON_X, leftButtonY, BUTTON_WIDTH, iconButtonHeight);
        [clearButton setImage:[UIImage imageNamed:@"clear-but" inBundle:currentBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(drawButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [clearButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [clearButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        clearButton.autoresizingMask = UIViewAutoresizingNone;
        clearButton.exclusiveTouch = YES;
        clearButton.tag = 12;
        [self addSubview:clearButton]; //leftButtonY += (iconButtonHeight + buttonSpacing);
        //titleY += (iconButtonHeight + buttonSpacing); titleHeight -= (iconButtonHeight + buttonSpacing);
        
        [self clearButtonSelection:12];
    }
    
    return self;
}

- (void)hideToolbar
{
    if (self.hidden == NO)
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
    }
}

- (void)showToolbar
{
    if (self.hidden == YES)
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
    }
}

- (UIImage *)getColorButtonImage:(UIColor *)color withSize:(NSNumber *)size
{
    
    UIImage *colorCircle;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([size floatValue], [size floatValue]), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, [size intValue], [size intValue]);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    // set stroking color and draw circle
    //CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGRect circleRect = CGRectMake(0, 0, [size intValue], [size intValue]);
    circleRect = CGRectInset(circleRect, 3, 3);
    CGContextStrokeEllipseInRect(ctx, circleRect);
    
    CGContextRestoreGState(ctx);
    colorCircle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorCircle;
}

- (void)clearButtonSelection:(NSInteger)upto
{
    if(upto>=penButton.tag)
        penButton.backgroundColor = [UIColor clearColor];
    if(upto>=textButton.tag)
        textButton.backgroundColor = [UIColor clearColor];
    if(upto>=highlightButton.tag)
        highlightButton.backgroundColor = [UIColor clearColor];
    if(upto>=lineButton.tag)
        lineButton.backgroundColor = [UIColor clearColor];
    if(upto>=squareButton.tag)
        squareButton.backgroundColor = [UIColor clearColor];
    if(upto>=circleButton.tag)
        circleButton.backgroundColor = [UIColor clearColor];
    if(upto>=circleFillButton.tag)
        circleFillButton.backgroundColor = [UIColor clearColor];
    if(upto>=eraserButton.tag)
        eraserButton.backgroundColor = [UIColor clearColor];
    if(upto>=colorButton.tag)
        colorButton.backgroundColor = [UIColor clearColor];
    if(upto>=undoButton.tag)
        undoButton.backgroundColor = [UIColor clearColor];
    if(upto>=redoButton.tag)
        redoButton.backgroundColor = [UIColor clearColor];
    if(upto>=clearButton.tag)
        clearButton.backgroundColor = [UIColor clearColor];
}

#pragma mark - UIButton action methods

- (void)drawButtonTapped:(UIButton *)button
{
    [delegate tappedInToolbar:self drawButton:button];
}

@end
