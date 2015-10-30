//
//  ALVImgurImageCell.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVImgurImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ALVImgurImage.h"

const CGFloat kImageCellDefaultWidth = 64;
const CGFloat kImageCellDefaultHeight = 64;

static const CGFloat kImageInset = 1;

@interface ALVImgurImageCell ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIView *overlayView;

@end

@implementation ALVImgurImageCell

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor whiteColor]];
        
        _imageView = imageView;
    }
    return _imageView;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
        spinner.color = [UIColor grayColor];
        
        _spinner = spinner;
    }
    return _spinner;
}

- (UIView *)overlayView {
    if (!_overlayView) {
        UIView *overlayView = [[UIView alloc] init];
        [overlayView setBackgroundColor:[UIColor whiteColor]];
        
        _overlayView = overlayView;
    }
    return _overlayView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)configureCell {
    [self.contentView addSubview:self.imageView];
    [self.contentView setBackgroundColor:[UIColor blackColor]];
    
    [self.contentView setClipsToBounds:YES];
    [self.contentView.layer setCornerRadius:2.0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imageView.bounds = CGRectInset(self.frame, kImageInset, kImageInset);
    
    [self.spinner setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.overlayView setFrame:self.imageView.frame];
}

- (void)animteLoading:(BOOL)animate {
    [self.spinner removeFromSuperview];
    [self.spinner stopAnimating];
    
    if (animate) {
        [self.spinner startAnimating];
        [self.contentView addSubview:self.spinner];
    }
}

- (void)fadeImageIn {
    [self.overlayView setAlpha:1.0];
    [self.contentView addSubview:self.overlayView];
    [self.contentView bringSubviewToFront:self.overlayView];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.overlayView setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
    }];
}

- (void)fadeImageOut {
    [self.overlayView setAlpha:0.0];
    [self.contentView addSubview:self.overlayView];
    [self.contentView bringSubviewToFront:self.overlayView];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.overlayView setAlpha:1.0];
    }];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self.overlayView removeFromSuperview];
    
    if (highlighted) {
        [self.overlayView setAlpha:1.0];
        [self.contentView addSubview:self.overlayView];
        [self.contentView bringSubviewToFront:self.imageView];
    }
    
    [self.imageView setAlpha:highlighted ? 0.5 : 1.0];
}

@end
