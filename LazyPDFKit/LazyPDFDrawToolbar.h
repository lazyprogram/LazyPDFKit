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

- (void)tappedInToolbar:(LazyPDFDrawToolbar *)toolbar drawButton:(UIButton *)button;

@end

@interface LazyPDFDrawToolbar : UIXToolbarView

@property (nonatomic, weak, readwrite) id <LazyPDFDrawToolbarDelegate> delegate;
@property (nonatomic,strong) UIButton *penButton;
@property (nonatomic,strong) UIButton *textButton;
@property (nonatomic,strong) UIButton *highlightButton;
@property (nonatomic,strong) UIButton *lineButton;
@property (nonatomic,strong) UIButton *squareButton;
@property (nonatomic,strong) UIButton *circleButton;
@property (nonatomic,strong) UIButton *circleFillButton;
@property (nonatomic,strong) UIButton *eraserButton;
@property (nonatomic,strong) UIButton *colorButton;
@property (nonatomic,strong) UIButton *undoButton;
@property (nonatomic,strong) UIButton *redoButton;
@property (nonatomic,strong) UIButton *clearButton;

- (instancetype)initWithFrame:(CGRect)frame document:(LazyPDFDocument *)document;
- (void)hideToolbar;
- (void)showToolbar;
- (UIImage *)getColorButtonImage:(UIColor *)color withSize:(NSNumber *)size;
- (void)clearButtonSelection:(NSInteger)upto;
@end
