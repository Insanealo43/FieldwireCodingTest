//
//  ALVNetworkInterface.m
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import "ALVNetworkInterface.h"

static NSString *kEnvironmentsPlistFilename = @"Environments";
static NSString *kImgurClientIdKey = @"ImgurClientId";

@interface ALVNetworkInterface ()

@property (nonatomic, strong) NSDictionary *interfaceHash;

@end

@implementation ALVNetworkInterface

static ALVNetworkInterface *sharedInstance = nil;

+ (ALVNetworkInterface *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            [sharedInstance loadInterface];
        }
        return sharedInstance;
    }
}

- (void)loadInterface {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:kEnvironmentsPlistFilename ofType:@"plist"];
    self.interfaceHash = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

- (NSString *)imgurClientId {
    return [self.interfaceHash objectForKey:kImgurClientIdKey];
}

@end
