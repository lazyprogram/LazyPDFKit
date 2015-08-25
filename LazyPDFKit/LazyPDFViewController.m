//
//	LazyPDFViewController.m
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


#import "LazyPDFConstants.h"
#import "LazyPDFViewController.h"
#import "ThumbsViewController.h"
#import "LazyPDFThumbCache.h"
#import "LazyPDFThumbQueue.h"
#import "LazyPDFContentView.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "LazyPDFDrawingView.h"
#import "LazyPDFPopoverController.h"
#import "LazyPDFPropertyController.h"
#import "LazyPDFColorPickerController.h"
#import "LazyPDFContentView.h"
#import "LazyPDFContentPage.h"
#import "LazyPDFMainToolbar.h"
#import "LazyPDFMainPagebar.h"
#import "LazyPDFDrawToolbar.h"
#import "LazyPDFDataManager.h"


@interface LazyPDFViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate,
LazyPDFMainToolbarDelegate, LazyPDFMainPagebarDelegate, LazyPDFContentViewDelegate, ThumbsViewControllerDelegate,LazyPDFDrawingViewDelegate,LazyPDFPopoverControllerDelegate,LazyPDFDrawToolbarDelegate>
{
    LazyPDFPropertyController *lazyPropertyController;
    LazyPDFPopoverController *popover;
    UINavigationController *navController;
}
@property (strong, nonatomic) IBOutlet UIView *drawToolBar;

@end

@implementation LazyPDFViewController
{
    LazyPDFDocument *document;
    
    UIScrollView *theScrollView;
    
    LazyPDFMainToolbar *mainToolbar;
    
    LazyPDFDrawToolbar *drawToolbar;
    
    UIButton *flattenPDFButton;
    
    LazyPDFMainPagebar *mainPagebar;
    
    NSMutableDictionary *contentViews;
    
    UIUserInterfaceIdiom userInterfaceIdiom;
    
    NSInteger currentPage, minimumPage, maximumPage;
    
    UIDocumentInteractionController *documentInteraction;
    
    UIPrintInteractionController *printInteraction;
    
    CGFloat scrollViewOutset;
    
    CGSize lastAppearSize;
    
    NSDate *lastHideTime;
    
    BOOL ignoreDidScroll;
}

#pragma mark - Constants

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f
#define DRAWBAR_HEIGHT 400.0f
#define DRAWBAR_WIDTH 44.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - LazyPDFViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
    CGFloat contentHeight = scrollView.bounds.size.height; // Height
    
    CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);
    
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    [self updateContentSize:scrollView]; // Update content size first
    
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(NSNumber *key, LazyPDFContentView *contentView, BOOL *stop)
     {
         NSInteger page = [key integerValue]; // Page number value
         
         CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;
         
         viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
         
         contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0f);
     }
     ];
    
    NSInteger page = currentPage; // Update scroll view offset to current page
    
    CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
    {
        scrollView.contentOffset = contentOffset; // Update content offset
    }
    
    [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
    
    [mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
    CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (page - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    
    NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties
    
    LazyPDFContentView *contentView = [[LazyPDFContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // LazyPDFContentView
    
    contentView.message = self; [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]]; [scrollView addSubview:contentView];
    
    [contentView showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
    
    UIImage *image = [[LazyPDFDataManager sharedInstance] getAnnotationImage:[document filePath] withPage:[NSNumber numberWithInteger:page]];
    [contentView setContentDrawingImageView:image];
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // View width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages
    
    NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages
    
    if (pageA < minimumPage) pageA = minimumPage; if (pageB > maximumPage) pageB = maximumPage;
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
    
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
    {
        NSInteger page = [key integerValue]; // Page number value
        
        if ([pageSet containsIndex:page] == NO) // Remove content view
        {
            LazyPDFContentView *contentView = [contentViews objectForKey:key];
            
            [contentView removeFromSuperview]; [contentViews removeObjectForKey:key];
        }
        else // Visible content view - so remove it from page set
        {
            [pageSet removeIndex:page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) // We have pages to add
    {
        NSEnumerationOptions options = 0; // Default
        
        if (pages == 2) // Handle case of only two content views
        {
            if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
        }
        else if (pages == 3) // Handle three content views - show the middle one first
        {
            NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;
            
            [workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];
            
            [self addContentView:scrollView page:page];
        }
        
        [pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
         ^(NSUInteger page, BOOL *stop)
         {
             [self addContentView:scrollView page:page];
         }
         ];
    }
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger page = (contentOffsetX / viewWidth); page++; // Page number
    
    if (page != currentPage) // Only if on different page
    {
        currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, LazyPDFContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)showDocumentPage:(NSInteger)page
{
    if (page != currentPage) // Only if on different page
    {
        if ((page < minimumPage) || (page > maximumPage)) return;
        
        [self saveAnnotation];
        
        currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];
        
        CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
            [self layoutContentViews:theScrollView];
        else
            [theScrollView setContentOffset:contentOffset];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, LazyPDFContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)showDocument
{
    [self updateContentSize:theScrollView]; // Update content size first
    
    [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
    
    document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    [document archiveDocumentProperties]; // Save any LazyPDFDocument changes
    
    [[LazyPDFThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];
    
    [[LazyPDFThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
    if ([delegate respondsToSelector:@selector(dismissLazyPDFViewController:)] == YES)
    {
        [delegate dismissLazyPDFViewController:self]; // Dismiss the LazyPDFViewController
    }
    else // We have a "Delegate must respond to -dismissLazyPDFViewController:" error
    {
        NSAssert(NO, @"Delegate must respond to -dismissLazyPDFViewController:");
    }
}

#pragma mark - UIViewController methods

- (instancetype)initWithLazyPDFDocument:(LazyPDFDocument *)object
{
    if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
    {
        if ((object != nil) && ([object isKindOfClass:[LazyPDFDocument class]])) // Valid object
        {
            userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
            
            scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);
            
            [object updateDocumentProperties]; document = object; // Retain the supplied LazyPDFDocument object for our use
            
            [LazyPDFThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
        }
        else // Invalid LazyPDFDocument object
        {
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    assert(document != nil); // Must have a valid LazyPDFDocument
    
    self.view.backgroundColor = [UIColor grayColor]; // Neutral gray
    
    UIView *fakeStatusBar = nil; CGRect viewRect = self.view.bounds; // View bounds
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
    {
        if ([self prefersStatusBarHidden] == NO) // Visible status bar
        {
            CGRect statusBarRect = viewRect; statusBarRect.size.height = STATUS_HEIGHT;
            fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
            fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            fakeStatusBar.backgroundColor = [UIColor blackColor];
            fakeStatusBar.contentMode = UIViewContentModeRedraw;
            fakeStatusBar.userInteractionEnabled = NO;
            
            viewRect.origin.y += STATUS_HEIGHT; viewRect.size.height -= STATUS_HEIGHT;
        }
    }
    
    CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
    theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // All
    theScrollView.autoresizesSubviews = NO; theScrollView.contentMode = UIViewContentModeRedraw;
    theScrollView.showsHorizontalScrollIndicator = NO; theScrollView.showsVerticalScrollIndicator = NO;
    theScrollView.scrollsToTop = NO; theScrollView.delaysContentTouches = NO; theScrollView.pagingEnabled = YES;
    theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    theScrollView.backgroundColor = [UIColor clearColor]; theScrollView.delegate = self;
    [self.view addSubview:theScrollView];
    
    CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
    mainToolbar = [[LazyPDFMainToolbar alloc] initWithFrame:toolbarRect document:document]; // LazyPDFMainToolbar
    mainToolbar.delegate = self; // LazyPDFMainToolbarDelegate
    [self.view addSubview:mainToolbar];
    
    CGRect drawbarRect = CGRectMake(10, viewRect.origin.y+TOOLBAR_HEIGHT+10, DRAWBAR_WIDTH, DRAWBAR_HEIGHT);
    drawToolbar = [[LazyPDFDrawToolbar alloc] initWithFrame:drawbarRect document:document]; // LazyPDFMainToolbar
    drawToolbar.delegate = self; // LazyPDFDrawToolbarDelegate
    [self.view addSubview:drawToolbar];
    
    CGRect flattenRect = CGRectMake(self.view.bounds.size.width-120, viewRect.origin.y+TOOLBAR_HEIGHT+10, 110, 40);
    flattenPDFButton = [[UIButton alloc] initWithFrame:flattenRect];
    [flattenPDFButton setTitle:@"Flatten PDF" forState:UIControlStateNormal];
    [flattenPDFButton setTintColor:[UIColor blueColor]];
    [flattenPDFButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [flattenPDFButton addTarget:self action:@selector(flattenPDF) forControlEvents:UIControlEventTouchUpInside];
    //[[flattenPDFButton layer] setBorderWidth:2.0];
    //[[flattenPDFButton layer] setBorderColor:[UIColor blueColor].CGColor];
    [self.view addSubview:flattenPDFButton];
    
    CGRect pagebarRect = self.view.bounds; pagebarRect.size.height = PAGEBAR_HEIGHT;
    pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
    mainPagebar = [[LazyPDFMainPagebar alloc] initWithFrame:pagebarRect document:document]; // LazyPDFMainPagebar
    mainPagebar.delegate = self; // LazyPDFMainPagebarDelegate
    [self.view addSubview:mainPagebar];
    
    if (fakeStatusBar != nil) [self.view addSubview:fakeStatusBar]; // Add status bar background view
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
    [self.view addGestureRecognizer:singleTapOne];
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
    [self.view addGestureRecognizer:doubleTapOne];
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
    [self.view addGestureRecognizer:doubleTapTwo];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    minimumPage = 1; maximumPage = [document.pageCount integerValue];
    
    [self.view bringSubviewToFront:self.drawToolBar];
    self.drawToolBar.userInteractionEnabled = YES;
    [self updateButtonStatus];
    self.lineWidth = [NSNumber numberWithFloat:2.0];
    self.lineAlpha = [NSNumber numberWithFloat:1.0];
    self.lineColor = [UIColor blueColor];
    
    [self.view bringSubviewToFront:flattenPDFButton];
    [flattenPDFButton setUserInteractionEnabled:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
    {
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
        {
            [self updateContentViews:theScrollView]; // Update content views
        }
        
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
    {
        [self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
    }
    
#if (LazyPDF_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of LazyPDF_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    lastAppearSize = self.view.bounds.size; // Track view size
    
#if (LazyPDF_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of LazyPDF_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    mainToolbar = nil; mainPagebar = nil;
    
    drawToolbar = nil; flattenPDFButton = nil;
    
    theScrollView = nil; contentViews = nil; lastHideTime = nil;
    
    documentInteraction = nil; printInteraction = nil;
    
    lastAppearSize = CGSizeZero; currentPage = 0;
    
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{

    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
    {
        
        [self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
        [drawToolbar setFrame:CGRectMake(drawToolbar.frame.origin.x, drawToolbar.frame.origin.y, DRAWBAR_WIDTH, DRAWBAR_HEIGHT)];
        [flattenPDFButton setFrame:CGRectMake(self.view.bounds.size.width-120, flattenPDFButton.frame.origin.y
                                              , 110, 40)];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ignoreDidScroll = NO;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;
    
    return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != minimumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x -= theScrollView.bounds.size.width; // View X--
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)incrementPageNumber
{
    if ((maximumPage > minimumPage) && (currentPage != maximumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x += theScrollView.bounds.size.width; // View X++
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect
        
        if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            LazyPDFContentView *targetView = [contentViews objectForKey:key]; // View
            
            id target = [targetView processSingleTap:recognizer]; // Target object
            
            if (target != nil) // Handle the returned target object
            {
                if ([target isKindOfClass:[NSURL class]]) // Open a URL
                {
                    NSURL *url = (NSURL *)target; // Cast to a NSURL object
                    
                    if (url.scheme == nil) // Handle a missing URL scheme
                    {
                        NSString *www = url.absoluteString; // Get URL string
                        
                        if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
                        {
                            NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];
                            
                            url = [NSURL URLWithString:http]; // Proper http-based URL
                        }
                    }
                    
                    if ([[UIApplication sharedApplication] openURL:url] == NO)
                    {
#ifdef DEBUG
                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
#endif
                    }
                }
                else // Not a URL, so check for another possible object type
                {
                    if ([target isKindOfClass:[NSNumber class]]) // Goto page
                    {
                        NSInteger number = [target integerValue]; // Number
                        
                        [self showDocumentPage:number]; // Show the page
                    }
                }
            }
            else // Nothing active tapped in the target content view
            {
                if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
                {
                    if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f) || (drawToolbar.alpha < 1.0f)) // Hidden
                    {
                        [mainToolbar showToolbar]; [mainPagebar showPagebar]; [drawToolbar showToolbar]; // Show
                        flattenPDFButton.hidden = NO;
                    }
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGRect viewRect = recognizer.view.bounds; // View bounds
        
        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
        
        CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
        
        if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
        {
            NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key
            
            LazyPDFContentView *targetView = [contentViews objectForKey:key]; // View
            
            switch (recognizer.numberOfTouchesRequired) // Touches count
            {
                case 1: // One finger double tap: zoom++
                {
                    [targetView zoomIncrement:recognizer]; break;
                }
                    
                case 2: // Two finger double tap: zoom--
                {
                    [targetView zoomDecrement:recognizer]; break;
                }
            }
            
            return;
        }
        
        CGRect nextPageRect = viewRect;
        nextPageRect.size.width = TAP_AREA_SIZE;
        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
        
        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
        {
            [self incrementPageNumber]; return;
        }
        
        CGRect prevPageRect = viewRect;
        prevPageRect.size.width = TAP_AREA_SIZE;
        
        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
        {
            [self decrementPageNumber]; return;
        }
    }
}

#pragma mark - LazyPDFContentViewDelegate methods

- (void)contentView:(LazyPDFContentView *)contentView touchesBegan:(NSSet *)touches
{
    if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f) || (drawToolbar.alpha > 0.0f))
    {
        if (touches.count == 1) // Single touches only
        {
            UITouch *touch = [touches anyObject]; // Touch info
            
            CGPoint point = [touch locationInView:self.view]; // Touch location
            
            CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
            if (CGRectContainsPoint(areaRect, point) == false) return;
        }
        
        [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; [drawToolbar hideToolbar]; // Hide
        flattenPDFButton.hidden = YES;
        
        lastHideTime = [NSDate date]; // Set last hide time
    }
}

#pragma mark - LazyPDFMainToolbarDelegate methods

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar doneButton:(UIButton *)button
{
    [self saveAnnotation];
#if (LazyPDF_STANDALONE == FALSE) // Option
    
    [self closeDocument]; // Close LazyPDFViewController
    
#endif // end of LazyPDF_STANDALONE Option
}

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#if (LazyPDF_ENABLE_THUMBS == TRUE) // Option
    
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithLazyPDFDocument:document];
    
    thumbsViewController.title = self.title; thumbsViewController.delegate = self; // ThumbsViewControllerDelegate
    
    thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:thumbsViewController animated:NO completion:NULL];
    
#endif // end of LazyPDF_ENABLE_THUMBS Option
}

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar exportButton:(UIButton *)button
{
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    NSURL *fileURL = document.fileURL; // Document file URL
    
    documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate
    
    [documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
}

- (void)flattenPDF
{
    NSURL *url = [document fileURL];
    CGPDFDocumentRef documentLocal = CGPDFDocumentCreateWithURL ((__bridge_retained CFURLRef) url);
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, self.drawingView.bounds, nil);
    
    //Pages
    for (int page=1; page<=[document.pageCount intValue]; page++) {
        //	Get the current page and page frame
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(documentLocal, page);
        
        const CGRect pageFrame = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        
        UIGraphicsBeginPDFPageWithInfo(pageFrame, nil);
        
        //	Draw the page (flipped)
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
        CGContextDrawPDFPage(ctx, pdfPage);
        CGContextRestoreGState(ctx);
        
        UIImage *image = [[LazyPDFDataManager sharedInstance] getAnnotationImage:[document filePath] withPage:[NSNumber numberWithInteger:page]];
        if (image!=nil) {
            [image drawInRect:pageFrame];
        }
    }
    
    UIGraphicsEndPDFContext();
    CGPDFDocumentRelease (documentLocal);
    
    //If fails to create the new file, returns
    if (![[NSFileManager defaultManager] createFileAtPath:[document filePath] contents:pdfData attributes:nil])
    {
        NSLog(@"File not saved");
    }else{
        [[LazyPDFDataManager sharedInstance] deleteFileByPath:[document filePath]];
        NSLog(@"File saved : %@",[document filePath]);
    }
}

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar printButton:(UIButton *)button
{
    if ([UIPrintInteractionController isPrintingAvailable] == YES)
    {
        NSURL *fileURL = document.fileURL; // Document file URL
        
        if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
        {
            printInteraction = [UIPrintInteractionController sharedPrintController];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = document.fileName;
            
            printInteraction.printInfo = printInfo;
            printInteraction.printingItem = fileURL;
            printInteraction.showsPageRange = YES;
            
            if (userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
            {
                [printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
            else // Handle printing on small device
            {
                [printInteraction presentAnimated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
        }
    }
}

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar emailButton:(UIButton *)button
{
    if ([MFMailComposeViewController canSendMail] == NO) return;
    
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
    
    if (fileSize < 15728640ull) // Check attachment size limit (15MB)
    {
        NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName;
        
        NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
        if (attachment != nil) // Ensure that we have valid document file attachment data available
        {
            MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
            [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
            
            [mailComposer setSubject:fileName]; // Use the document file name for the subject
            
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
            mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
            
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
    }
}

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar markButton:(UIButton *)button
{
#if (LazyPDF_BOOKMARKS == TRUE) // Option
    
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    if ([document.bookmarks containsIndex:currentPage]) // Remove bookmark
    {
        [document.bookmarks removeIndex:currentPage]; [mainToolbar setBookmarkState:NO];
    }
    else // Add the bookmarked page number to the bookmark index set
    {
        [document.bookmarks addIndex:currentPage]; [mainToolbar setBookmarkState:YES];
    }
    
#endif // end of LazyPDF_BOOKMARKS Option
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (LazyPDF_ENABLE_THUMBS == TRUE) // Option
    
    [self showDocumentPage:page];
    
#endif // end of LazyPDF_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (LazyPDF_ENABLE_THUMBS == TRUE) // Option
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
#endif // end of LazyPDF_ENABLE_THUMBS Option
}

#pragma mark - LazyPDFMainPagebarDelegate methods

- (void)pagebar:(LazyPDFMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
    [document archiveDocumentProperties]; // Save any LazyPDFDocument changes
    
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}

-(BOOL)isBlankImage:(UIImage *)myImage
{
    typedef struct
    {
        uint8_t red;
        uint8_t green;
        uint8_t blue;
        uint8_t alpha;
    } MyPixel_T;
    
    CGImageRef myCGImage = [myImage CGImage];
    
    //Get a bitmap context for the image
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, CGImageGetWidth(myCGImage), CGImageGetHeight(myCGImage),
                                                       CGImageGetBitsPerComponent(myCGImage), CGImageGetBytesPerRow(myCGImage),
                                                       CGImageGetColorSpace(myCGImage), CGImageGetBitmapInfo(myCGImage));
    
    //Draw the image into the context
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, CGImageGetWidth(myCGImage), CGImageGetHeight(myCGImage)), myCGImage);
    
    //Get pixel data for the image
    MyPixel_T *pixels = CGBitmapContextGetData(bitmapContext);
    size_t pixelCount = CGImageGetWidth(myCGImage) * CGImageGetHeight(myCGImage);
    for(size_t i = 0; i < pixelCount; i++)
    {
        MyPixel_T p = pixels[i];
        //Your definition of what's blank may differ from mine
        if(p.red > 0 || p.green > 0 || p.blue > 0 || p.alpha > 0)
            return NO;
    }
    
    return YES;
}
//- (IBAction)drawMode:(id)sender {
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar drawButton:(UIButton *)button
{
    if (button.tag==9) {
        [self openProperty:button];
    }else{
        [theScrollView setScrollEnabled:NO];
        LazyPDFContentView *theDrawView = (LazyPDFContentView *)[contentViews objectForKey:[NSNumber numberWithInteger:currentPage]];
        [theDrawView setScrollEnabled:NO];
        for (UIView *subview in theDrawView.subviews)
        {
            subview.userInteractionEnabled = YES;
            for (UIView *subview2 in subview.subviews)
            {
                if([subview2 isKindOfClass:[LazyPDFContentPage class]]){
                    subview2.userInteractionEnabled = YES;
                    LazyPDFContentPage *contentPage = (LazyPDFContentPage *)subview2;
                    [contentPage hideDrawingView];
                    if (self.drawingView==nil && button.tag<=8){
                        //only edit mode buttons till circle fill
                        self.drawingView = [[LazyPDFDrawingView alloc] initWithFrame:contentPage.frame];
                        UIImage *drawingImage = [contentPage getDrawingImage];
                        if(drawingImage!=nil){
                            [self.drawingView loadImage:drawingImage];
                        }
                    }else{
                        if ((button.tag==1 && self.drawingView.drawTool == LazyPDFDrawingToolTypePen) || (button.tag==2 && self.drawingView.drawTool == LazyPDFDrawingToolTypeText) || (button.tag==3 && self.drawingView.drawTool == LazyPDFDrawingToolTypeRectagleFill) || (button.tag==4 && self.drawingView.drawTool == LazyPDFDrawingToolTypeLine) || (button.tag==5 && self.drawingView.drawTool == LazyPDFDrawingToolTypeRectagleStroke) || (button.tag==6 && self.drawingView.drawTool == LazyPDFDrawingToolTypeEllipseStroke) || (button.tag==7 && self.drawingView.drawTool == LazyPDFDrawingToolTypeEllipseFill) || (button.tag==8 && self.drawingView.drawTool == LazyPDFDrawingToolTypeEraser)) {
                            [self saveAnnotation];
                        }
                    }
                    if (button.tag<=8)
                        [drawToolbar clearButtonSelection:8]; // clear upto eraser button
                    if (self.drawingView!=nil){
                        self.drawingView.delegate = self;
                        if (button.tag<=8) {
                            //only edit mode buttons till eraser
                            button.backgroundColor = [UIColor colorWithRed:0.49 green:0.78 blue:0.95 alpha:1.0];
                        }
                        self.lineWidth = [NSNumber numberWithFloat:2.0];
                        self.lineAlpha = [NSNumber numberWithFloat:1.0];
                        switch (button.tag) {
                            case 1:
                                //pen button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypePen;
                                break;
                            case 2:
                                //text button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeText;
                                self.lineWidth = [NSNumber numberWithFloat:10];
                                break;
                            case 3:
                                //highlight button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeRectagleFill;
                                self.lineAlpha = [NSNumber numberWithFloat:0.5];
                                break;
                            case 4:
                                //line button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeLine;
                                break;
                            case 5:
                                //square button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeRectagleStroke;
                                break;
                            case 6:
                                //circle button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeEllipseStroke;
                                break;
                            case 7:
                                //circle fill button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeEllipseFill;
                                break;
                            case 8:
                                //eraser button
                                self.drawingView.drawTool = LazyPDFDrawingToolTypeEraser;
                                break;
                            case 9:
                                //color button
                                //[self openProperty:button];
                                break;
                            case 10:
                                //undo button
                                [self.drawingView undoLatestStep];
                                [self updateButtonStatus];
                                break;
                            case 11:
                                //redo button
                                [self.drawingView redoLatestStep];
                                [self updateButtonStatus];
                                break;
                            case 12:
                                //clear button
                                [self.drawingView clear];
                                [self updateButtonStatus];
                                break;
                            default:
                                self.drawingView.drawTool = LazyPDFDrawingToolTypePen;
                                break;
                        }
                        [self updateDrawingView];
                        [contentPage addSubview:self.drawingView];
                    }
                    break;
                }
            }
            
        }
    }
    
}
- (void)saveAnnotation
{
    [drawToolbar clearButtonSelection:8];
    
    LazyPDFContentView *theDrawView = (LazyPDFContentView *)[contentViews objectForKey:[NSNumber numberWithInteger:currentPage]];
    [theDrawView setScrollEnabled:YES];
    for (UIView *subview in theDrawView.subviews)
    {
        subview.userInteractionEnabled = NO;
        for (UIView *subview2 in subview.subviews)
        {
            if([subview2 isKindOfClass:[LazyPDFContentPage class]]){
                subview2.userInteractionEnabled = NO;
                LazyPDFContentPage *contentPage = (LazyPDFContentPage *)subview2;
                if (self.drawingView!=nil) {
                    //Save Image Coding Starts
                    if (![self isBlankImage:self.drawingView.image] && self.drawingView.image!=nil) {
                        //[contentPage showDrawingView:self.drawingView.image];
                        //[contentPage addSubview:self.drawingView];
                        
                        NSMutableDictionary *annotDict = [NSMutableDictionary new];
                        NSData *image = UIImagePNGRepresentation(self.drawingView.image);
                        [annotDict setValue:image forKey:@"image"];
                        [annotDict setValue:[NSNumber numberWithInteger:currentPage] forKey:@"page"];
                        
                        [annotDict setValue:[document fileDate] forKey:@"fileDate"];
                        [annotDict setValue:[document fileSize] forKey:@"fileSize"];
                        [annotDict setValue:[document pageCount] forKey:@"pageCount"];
                        [annotDict setValue:[document filePath] forKey:@"filePath"];
                        
                        [[LazyPDFDataManager sharedInstance] addAnnotation:annotDict];
                        annotDict = nil;
                    }
                    [contentPage showDrawingView:self.drawingView.image];
                    [self.drawingView removeFromSuperview];
                }
                self.drawingView = nil;
                //Save Image Coding Ends
                break;
            }
        }
        
    }
    [theScrollView setScrollEnabled:YES];
}
-(void)updateDrawingView
{
    if (self.drawingView!=nil) {
        self.drawingView.lineWidth = [self.lineWidth floatValue];
        self.drawingView.lineColor = self.lineColor;
        self.drawingView.lineAlpha = [self.lineAlpha floatValue];
    }
}
-(void)openProperty:(UIButton *)button
{
    lazyPropertyController = nil;
    
    lazyPropertyController = [[LazyPDFPropertyController alloc] init];
    lazyPropertyController.lineColor = self.lineColor;
    lazyPropertyController.lineAlpha = self.lineAlpha;
    lazyPropertyController.lineWidth = self.lineWidth;
    lazyPropertyController.colorButton = drawToolbar.colorButton;
    
    navController = nil;
    navController = [[UINavigationController alloc] initWithRootViewController:lazyPropertyController];
    //navController.navigationBarHidden = YES;
    
    popover = nil;
    popover = [[LazyPDFPopoverController alloc] initWithViewController:navController];
    popover.arrowDirection = LazyPDFPopoverArrowDirectionUp;
    popover.contentSize = CGSizeMake(350, 250);
    popover.delegate = self;
    lazyPropertyController.popover = popover;
    [popover presentPopoverFromView:button];
}
#pragma mark - LazyPDFDrawing View Delegate
- (void)drawingView:(LazyPDFDrawingView *)view didEndDrawUsingTool:(id<LazyPDFDrawingTool>)tool;
{
    [self updateButtonStatus];
}
- (void)updateButtonStatus
{
    drawToolbar.undoButton.enabled = [self.drawingView canUndo];
    drawToolbar.redoButton.enabled = [self.drawingView canRedo];
}

- (void)popoverControllerDidDismissPopover:(LazyPDFPopoverController *)popoverController
{
    if (navController!=nil) {
        LazyPDFPropertyController *lazyPDFProperty = (LazyPDFPropertyController *)[navController.viewControllers objectAtIndex:0];
        self.lineColor = lazyPDFProperty.lineColor;
        self.lineAlpha = lazyPDFProperty.lineAlpha;
        self.lineWidth = lazyPDFProperty.lineWidth;
        [self updateDrawingView];
    }
}
@end
