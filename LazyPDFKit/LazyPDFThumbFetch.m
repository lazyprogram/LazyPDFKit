//
//	LazyPDFThumbFetch.m
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


#import "LazyPDFThumbFetch.h"
#import "LazyPDFThumbRender.h"
#import "LazyPDFThumbCache.h"
#import "LazyPDFThumbView.h"

#import <ImageIO/ImageIO.h>

@implementation LazyPDFThumbFetch
{
	LazyPDFThumbRequest *request;
}

#pragma mark - LazyPDFThumbFetch instance methods

- (instancetype)initWithRequest:(LazyPDFThumbRequest *)options
{
	if ((self = [super initWithGUID:options.guid]))
	{
		request = options;
	}

	return self;
}

- (void)cancel
{
	[super cancel]; // Cancel the operation

	request.thumbView.operation = nil; // Break retain loop

	request.thumbView = nil; // Release target thumb view on cancel

	[[LazyPDFThumbCache sharedInstance] removeNullForKey:request.cacheKey];
}

- (NSURL *)thumbFileURL
{
	NSString *cachePath = [LazyPDFThumbCache thumbCachePathForGUID:request.guid]; // Thumb cache path

	NSString *fileName = [[NSString alloc] initWithFormat:@"%@.png", request.thumbName]; // Thumb file name

	return [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:fileName]]; // File URL
}

- (void)main
{
	CGImageRef imageRef = NULL; NSURL *thumbURL = [self thumbFileURL];

	CGImageSourceRef loadRef = CGImageSourceCreateWithURL((__bridge CFURLRef)thumbURL, NULL);

	if (loadRef != NULL) // Load the existing thumb image
	{
		imageRef = CGImageSourceCreateImageAtIndex(loadRef, 0, NULL); // Load it

		CFRelease(loadRef); // Release CGImageSource reference
	}
	else // Existing thumb image not found - so create and queue up a thumb render operation on the work queue
	{
		LazyPDFThumbRender *thumbRender = [[LazyPDFThumbRender alloc] initWithRequest:request]; // Create a thumb render operation

		[thumbRender setQueuePriority:self.queuePriority]; [thumbRender setThreadPriority:(self.threadPriority - 0.1)]; // Priority

		if (self.isCancelled == NO) // We're not cancelled - so update things and add the render operation to the work queue
		{
			request.thumbView.operation = thumbRender; // Update the thumb view operation property to the new operation

			[[LazyPDFThumbQueue sharedInstance] addWorkOperation:thumbRender]; return; // Queue the operation
		}
	}

	if (imageRef != NULL) // Create a UIImage from a CGImage and show it
	{
		UIImage *image = [UIImage imageWithCGImage:imageRef scale:request.scale orientation:UIImageOrientationUp];

		CGImageRelease(imageRef); // Release the CGImage reference from the above thumb load code

		UIGraphicsBeginImageContextWithOptions(image.size, YES, request.scale); // Graphics context

		[image drawAtPoint:CGPointZero]; // Decode and draw the image on this background thread

		UIImage *decoded = UIGraphicsGetImageFromCurrentImageContext(); // Newly decoded image

		UIGraphicsEndImageContext(); // Cleanup after the bitmap-based graphics drawing context

		[[LazyPDFThumbCache sharedInstance] setObject:decoded forKey:request.cacheKey]; // Cache it

		if (self.isCancelled == NO) // Show the image in the target thumb view on the main thread
		{
			LazyPDFThumbView *thumbView = request.thumbView; // Target thumb view for image show

			NSUInteger targetTag = request.targetTag; // Target reference tag for image show

			dispatch_async(dispatch_get_main_queue(), // Queue image show on main thread
			^{
				if (thumbView.targetTag == targetTag) [thumbView showImage:decoded];
			});
		}
	}

	request.thumbView.operation = nil; // Break retain loop
}

@end
