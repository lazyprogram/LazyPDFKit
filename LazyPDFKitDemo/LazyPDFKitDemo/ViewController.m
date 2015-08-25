//
//  ViewController.m
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 26/3/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import "ViewController.h"
#import <LazyPDFKit/LazyPDFKit.h>

@interface ViewController ()<LazyPDFViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)open:(id)sender {
    [self openLazyPDF];
}
- (void)openLazyPDF
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
    NSString *filePath = [pdfs firstObject]; assert(filePath != nil); // Path to first PDF file
    
    LazyPDFDocument *document = [LazyPDFDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid LazyPDFDocument object in order to proceed with things
    {
        LazyPDFViewController *lazyPDFViewController = [[LazyPDFViewController alloc] initWithLazyPDFDocument:document];
        
        lazyPDFViewController.delegate = self; // Set the LazyPDFViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        [self.navigationController pushViewController:lazyPDFViewController animated:YES];
        
#else // present in a modal view controller
        
        lazyPDFViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        lazyPDFViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:lazyPDFViewController animated:YES completion:NULL];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"%s [LazyPDFDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

#pragma mark - LazyPDFViewControllerDelegate methods

- (void)dismissLazyPDFViewController:(LazyPDFViewController *)viewController
{
    // dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
