//
//  ALVImageManager.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVImageManager.h"
#import "NSDictionary+ALVAdditions.h"
#import "ALVNetworkInterface.h"
#import "ALVImgurImage.h"

static NSString *const kDataKey = @"data";

@implementation ALVImageManager

+ (ALVImageManager *)sharedInstance {
    static ALVImageManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ALVImageManager alloc] init];
    });
    
    return _sharedClient;
}

+ (void)imagesForSearch:(NSString *)searchString completion:(void(^)(NSArray *imgurImages)) block {
    
    __block NSMutableArray *fetchedImages = [NSMutableArray new];
    if ([searchString length] > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // https://api.imgur.com/3/gallery/search/2?q=%@
            NSString *imageSearchEndpoint = [NSString stringWithFormat:@"https://api.imgur.com/3/gallery/search/2?q=%@", searchString];
            NSMutableURLRequest *request = [[self sharedInstance] getUrlRequestWithString:imageSearchEndpoint];
            
            NSLog(@"About to fire request...");
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       NSLog(@"Request FINISHED!");
                                       
                                       // Parse the response
                                       if (data) {
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                  options:0
                                                                                    error:nil];
                                           
                                           NSLog(@"%@ Images Found: %@", searchString, json);
                                           fetchedImages = [[self sharedInstance] parseImgurImages:json];
                                       }
                                       
                                       if (block) block (fetchedImages);
            }];
            NSLog(@"Request FIRED!");
        });
        
    } else {
        if (block) block (fetchedImages);
    }
}

+ (void)fetchImageWithId:(NSString *)identifier completion:(void(^)(UIImage *imgurImage)) block {
    if ([identifier length] > 0) {
        // https://api.imgur.com/3/image/{id}
        NSString *imageFetchEndpoint = [NSString stringWithFormat:@"https://api.imgur.com/3/image/%@", identifier];
        NSMutableURLRequest *request = [[self sharedInstance] getUrlRequestWithString:imageFetchEndpoint];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   NSLog(@"Request FINISHED!");
                                   
                                   // Parse the response
                                   if (data) {
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                                       NSLog(@"FETCHED IMAGE: %@", json);
                                       
                                   }
                                   
                                   if (block) block (nil);
                               }];
        
    } else {
        if (block) block (nil);
    }
}

- (NSMutableURLRequest *)getUrlRequestWithString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10
                                    ];
    
    NSString *clientIdString = [NSString stringWithFormat:@"Client-ID %@", [[ALVNetworkInterface sharedInstance] imgurClientId]];
    [request setValue:clientIdString forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod: @"GET"];
    
    return request;
}

- (NSMutableArray *)parseImgurImages:(NSDictionary *)imagesData {
    NSMutableArray *images = [NSMutableArray new];
    
    NSArray *imagesInfo = [imagesData objectForKeyNotNull:kDataKey];
    for (NSDictionary *data in imagesInfo) {
        ALVImgurImage *imgurImage = [[ALVImgurImage alloc] initWithInfo:data];
        [images addObject:imgurImage];
    }
    
    return images;
}

@end
