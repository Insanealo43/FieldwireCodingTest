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
    _thumbnailImage = nil;
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
