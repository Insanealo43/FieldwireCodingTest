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
}

/*- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self animteLoading:NO];
    self.imageData = nil;
}*/

/*- (void)setImageData:(ALVImgurImage *)imageData {
    _imageData = imageData;
    self.imageView.image = imageData.thumbnailImage;
    
    [self.spinner removeFromSuperview];
    if (!imageData.thumbnailImage) {
        [self.spinner startAnimating];
        [self.contentView addSubview:self.spinner];
    }
}*/

- (void)animteLoading:(BOOL)animate {
    [self.spinner removeFromSuperview];
    [self.spinner stopAnimating];
    
    if (animate) {
        [self.spinner startAnimating];
        [self.contentView addSubview:self.spinner];
    }
}

@end
