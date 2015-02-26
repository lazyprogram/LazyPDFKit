//
//  LazyPDFDrawToolbar.h
//  LazyPDFKitDemo
//
//  Created by Palanisamy Easwaramoorthy on 26/2/15.
//  Copyright (c) 2015 Lazyprogram. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"

@class LazyPDFDrawToolbar;
@class LazyPDFDocument;

@protocol LazyPDFDrawToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar thumbsButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar exportButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar printButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar emailButton:(UIButton *)button;
- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar markButton:(UIButton *)button;

@end

@interface LazyPDFDrawToolbar : UIXToolbarView

@property (nonatomic, weak, readwrite) id <LazyPDFDrawToolbarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame document:(LazyPDFDocument *)document;

- (void)setBookmarkState:(BOOL)state;

- (void)hideToolbar;
- (void)showToolbar;

@end
