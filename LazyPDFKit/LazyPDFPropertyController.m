//
//  LazyPDFPropertyController.m
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

//

#import "LazyPDFPropertyController.h"
#import "LazyPDFColorPickerController.h"

@interface LazyPDFPropertyController ()<LazyPDFColorPickerControllerDelegate>
{
    UIImageView *imageView;
}

@end

@implementation LazyPDFPropertyController

@synthesize lineAlpha,lineColor,lineWidth,colorButton,popover;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageView = [[UIImageView alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Properties";
    popover.arrowDirection = LazyPDFPopoverArrowDirectionUp;
    popover.contentSize = CGSizeMake(350, 250);
    popover.contentView.frame = CGRectMake(popover.contentView.frame.origin.x, popover.contentView.frame.origin.y, popover.contentView.frame.size.width, 250);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}
- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    NSString *str1;
    if(indexPath.row==0){
        str1 = @"Color";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setImageView:lineColor];
        [cell.contentView addSubview:imageView];
    }else if(indexPath.row==1){
        str1 = @"Thickness";
        UISlider *sliderThick = [[UISlider alloc] initWithFrame:CGRectMake(110, 13, 170, 20)];
        sliderThick.minimumValue = 1;
        sliderThick.maximumValue = 20;
        sliderThick.value = [lineWidth floatValue];
        [sliderThick addTarget:self action:@selector(sliderThickAction:) forControlEvents:UIControlEventValueChanged];
        
        [cell.contentView addSubview:sliderThick];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if(indexPath.row==2){
        str1 = @"Opacity";
        UISlider *sliderOpa = [[UISlider alloc] initWithFrame:CGRectMake(110, 13, 170, 20)];
        sliderOpa.minimumValue = 0.1;
        sliderOpa.maximumValue = 1;
        sliderOpa.value = [lineAlpha floatValue];
        [sliderOpa addTarget:self action:@selector(sliderAlphaAction:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:sliderOpa];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = str1;
    
    return cell;
}
//------------------------------------------------------------------------------
#pragma mark - LazyPDFColorPickerControllerDelegate
//------------------------------------------------------------------------------

- (void) colorPickerControllerDidChangeColor: (LazyPDFColorPickerController*) controller
{
    self.lineColor = controller.resultColor;
    [self setImageView:lineColor];
}

//------------------------------------------------------------------------------
#pragma mark - Table view delegate
//------------------------------------------------------------------------------

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (indexPath.row==0) {
        LazyPDFColorPickerController* picker = [ LazyPDFColorPickerController colorPickerViewController ];
        picker.sourceColor = lineColor;
        picker.delegate = self;
        [self.navigationController pushViewController:picker animated:YES];
        //[ picker presentModallyOverViewController: self ];
        popover.arrowDirection = LazyPDFPopoverArrowDirectionUp;
        popover.contentSize = CGSizeMake(popover.contentView.frame.size.width, [LazyPDFColorPickerController idealSizeForViewInPopover].height);
        popover.contentView.frame = CGRectMake(popover.contentView.frame.origin.x, popover.contentView.frame.origin.y, popover.contentView.frame.size.width, [LazyPDFColorPickerController idealSizeForViewInPopover].height+50);
    }
}
- (void)sliderThickAction:(UISlider *)sender
{
    lineWidth = [NSNumber numberWithFloat:sender.value];
}
- (void)sliderAlphaAction:(UISlider *)sender
{
    lineAlpha = [NSNumber numberWithFloat:sender.value];
}

-(void)setImageView:(UIColor *)color{
    CGRect myFrame = CGRectMake(240, 12, 20, 20);
    UIImage *colorCircle;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 20.f), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGRect rect = CGRectMake(0, 0, 20, 20);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    // set stroking color and draw circle
    //CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGRect circleRect = CGRectMake(0, 0, 20, 20);
    circleRect = CGRectInset(circleRect, 3, 3);
    CGContextStrokeEllipseInRect(ctx, circleRect);
    
    CGContextRestoreGState(ctx);
    colorCircle = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView setImage:colorCircle];
    [imageView setFrame:myFrame];
    
    [self.colorButton setImage:colorCircle forState:UIControlStateNormal];
}
@end
