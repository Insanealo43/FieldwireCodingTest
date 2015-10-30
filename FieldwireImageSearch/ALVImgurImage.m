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

NSString *const kFetchedThumbnailImageNotification = @"ALVImgurImage.fetchedThumbnailNotification";
NSString *const kFetchedImageNotification = @"ALVImgurImage.fetchedNotification";

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
    _fetchedImage = nil;
    
    // Start fetching Image from url
    if ([link length] > 0) {
        
        // Fetch the thumbnail of the image
        [ALVImageManager fetchImageWithLink:[self thumbnailLink] completion:^(UIImage *image) {
            if (image) {
                // Setter Method for KVO observers
                [self setThumbnailImage:image];
                
                // Notification for fetched image
                NSNotification *notification = [NSNotification notificationWithName:kFetchedThumbnailImageNotification object:self];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                NSLog(@"Posting Fetched Image THUMBNAIL Notification!");
            }
        }];
        
        // Fetch the full sized image
        [ALVImageManager fetchImageWithLink:link completion:^(UIImage *image) {
            if (image) {
                // Setter Method for KVO observers
                [self setFetchedImage:image];
                
                // Notification for fetched image
                NSNotification *notification = [NSNotification notificationWithName:kFetchedImageNotification object:self];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                NSLog(@"Posting Fetched Image Notification!");
            }
        }];
    }
}

- (NSString *)thumbnailLink {
    NSMutableArray *linkComponents = [[self.link componentsSeparatedByString:@"."] mutableCopy];
    if ([linkComponents count] > 1) {
        // Grab 2nd last component and append thumbnail extension
        NSUInteger extensionIndex = [linkComponents count] - 2;
        NSString *extension = [linkComponents objectAtIndex:extensionIndex];
        
        extension = [extension stringByAppendingString:@"s"];
        [linkComponents replaceObjectAtIndex:extensionIndex withObject:extension];
        
        NSString *thumbnailLink = [linkComponents componentsJoinedByString:@"."];
        return thumbnailLink;
    }
    
    return nil;
}

@end
