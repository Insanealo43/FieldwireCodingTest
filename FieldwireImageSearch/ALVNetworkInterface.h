//
//  ALVNetworkInterface.h
//  FieldwireImageSearch
//
//  Created by Andrew Lopez-Vass on 10/29/15.
//  Copyright © 2015 Andrew Lopez-Vass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALVNetworkInterface : NSObject

+ (ALVNetworkInterface *)sharedInstance;

@property (nonatomic) NSString *imgurClientId;

@end
