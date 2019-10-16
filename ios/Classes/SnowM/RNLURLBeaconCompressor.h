//
//  RNLURLBeaconCompressor.h
//  iBeaconLoc
//
//  Created by David Young on 1/28/16.
//  Copyright © 2016 RadiusNetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNLURLBeaconCompressor : NSObject
+ (NSString *)URLStringFromEddystoneURLIdentifier:(NSString *)identifier;
@end
