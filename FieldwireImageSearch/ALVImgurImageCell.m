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

@interface ALVImgurImageCell ()

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation ALVImgurImageCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.spinner setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageData = nil;
}

- (void)setImageData:(ALVImgurImage *)imageData {
    _imageData = imageData;
    self.imageView.image = imageData.thumbnailImage;
    
    [self.spinner removeFromSuperview];
    if (!imageData.thumbnailImage) {
        [self.spinner startAnimating];
        [self.imageView addSubview:self.spinner];
    }
    
    
    /*[self.imageView setImage:nil];
    
    [self.spinner removeFromSuperview];
    if (!imageData.fetchedImage) {
        [self.contentView addSubview:self.spinner];
        
    } else {
        [self.imageView setImage:imageData.fetchedImage];
    }
    
    if ([imageData.link length] > 0) {
        /*[self.imageView sd_setImageWithURL:[NSURL URLWithString:imageData.link]
                           placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      if (image && !error) {
                                          // do something with image
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSLog(@"Fetched Image - %@", image);
                                              //[self.imageView setImage:image];
                                          });
                                      }
                                      
        }];*/
        
        /*[self.spinner startAnimating];
        [self.imageView addSubview:self.spinner];
        
        SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
        [downloader downloadImageWithURL:[NSURL URLWithString:imageData.link]
                                 options:0
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                    // progression tracking code
                                    
                                }
                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                   if (image && finished) {
                                       // do something with image
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSLog(@"Fetched Image Finished!");
                                           [self.imageView setImage:image];
                                       });
                                   }
                                   
                                   [self.spinner stopAnimating];
                                   [self.spinner removeFromSuperview];
                               }];
         
    }*/
}

@end
