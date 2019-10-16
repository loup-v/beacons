//
//  RNLURLBeaconCompressor.m
//  iBeaconLoc
//
//  Created by David Young on 1/28/16.
//  Copyright © 2016 RadiusNetworks. All rights reserved.
//

#import "RNLURLBeaconCompressor.h"
#import "RNLBeacon.h"
@implementation RNLURLBeaconCompressor

+ (NSString *)URLStringFromEddystoneURLIdentifier:(NSString *)identifier {
  NSData *data = [RNLBeacon dataFromIdentifier: identifier];

  return [RNLURLBeaconCompressor URLStringFromEddystoneURLData:data];
}


+ (NSString *)URLStringFromEddystoneURLData:(NSData *)URLData
{
  NSMutableString *URLString;
  for (int i = 0; i < URLData.length; i++)
  {
    NSArray *prefixes = @[@"http://www.", @"https://www.", @"http://", @"https://"];
    NSArray *expansions = @[@".com/", @".org/", @".edu/", @".net/", @".info/", @".biz/", @".gov/", @".com", @".org", @".edu", @".net", @".info", @".biz", @".gov"];
    
    Byte aByte;
    [URLData getBytes:&aByte range:NSMakeRange(i, 1)];
    NSInteger index = aByte;
    if (i == 0)
    {
      // this is the prefix byte
      if (index < prefixes.count)
      {
        URLString = [NSMutableString stringWithString:prefixes[index]];
      }
      else
      {
        return nil;
      }
    }
    else if ( index <= 13)
    {
      [URLString appendString:expansions[index]];
    }
    else if ((index >= 14) && (index <= 32))
    {
      // this is a reserved value
      return nil;
    }
    else if ((index >= 127) && (index <= 255))
    {
      // this is a reserved value
      return nil;
    }
    else
    {
      [URLString appendString:[[NSString alloc]initWithBytes:&aByte length:1 encoding:NSUTF8StringEncoding]];
    }
    
  }
  
  return URLString;
}

@end
