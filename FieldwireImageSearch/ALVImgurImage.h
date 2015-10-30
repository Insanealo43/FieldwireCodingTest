//
//  ALVImage.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ALVImgurImage : NSObject

@property (nonatomic, strong) UIImage *fetchedImage;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *link;

- (instancetype)initWithInfo:(NSDictionary *)imageInfo;

@end
