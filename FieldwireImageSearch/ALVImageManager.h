//
//  ALVImageManager.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALVImageManager : NSObject

+ (ALVImageManager *)sharedInstance;

+ (void)imagesForSearch:(NSString *)searchString completion:(void(^)(NSArray *imgurImages)) block;
+ (void)fetchImageWithId:(NSString *)identifier completion:(void(^)(UIImage *imgurImage)) block;
+ (void)fetchImageWithLink:(NSString *)link completion:(void (^)(UIImage *))block;

@end
