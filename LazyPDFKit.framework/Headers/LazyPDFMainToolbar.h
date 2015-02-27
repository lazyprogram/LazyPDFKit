//
//	LazyPDFMainToolbar.h
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

#import "UIXToolbarView.h"

@class LazyPDFMainToolbar;
@class LazyPDFDocument;

@protocol LazyPDFMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar thumbsButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar exportButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar printButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar emailButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFMainToolbar *)toolbar markButton:(UIButton *)button;

@end

@interface LazyPDFMainToolbar : UIXToolbarView

@property (nonatomic, weak, readwrite) id <LazyPDFMainToolbarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame document:(LazyPDFDocument *)document;

- (void)setBookmarkState:(BOOL)state;

- (void)hideToolbar;
- (void)showToolbar;

@end
