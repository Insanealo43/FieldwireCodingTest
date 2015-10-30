//
//  ALVImage.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVImgurImage.h"
#import "NSDictionary+ALVAdditions.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ALVImageManager.h"

static NSString *const kLinkKey = @"link";
static NSString *const kIdKey = @"id";

@implementation ALVImgurImage

- (instancetype)initWithInfo:(NSDictionary *)imageInfo {
    self.link = [imageInfo objectForKeyNotNull:kLinkKey];
    self.identifier = [imageInfo objectForKeyNotNull:kIdKey];
    
    return self;
}

- (void)setLink:(NSString *)link {
    _link = link;
    
    // Start fetching Image from url
    if ([link length] > 0) {
        [ALVImageManager fetchImageWithId:link completion:^(UIImage *image) {
            // Notify app that image was fetched and use KVO to listen on image change properties
            _fetchedImage = image;
        }];
    }
}

@end
