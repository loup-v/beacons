/*
 * Radius Networks, Inc.
 * http://www.radiusnetworks.com
 *
 * @author David G. Young
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */


#import "RNLBeacon.h"
#import <CoreLocation/CoreLocation.h>

@implementation RNLBeacon
-(NSString *) id1 {
  NSString *id = Nil;
  if (self.identifiers.count > 0) {
    id = [self.identifiers objectAtIndex:0];
  }
  return id;
}
-(NSString *) id2 {
  NSString *id = Nil;
  if (self.identifiers.count > 1) {
    id = [self.identifiers objectAtIndex:1];
  }
  return id;
}
-(NSString *) id3 {
  NSString *id = Nil;
  if (self.identifiers.count > 2) {
    id = [self.identifiers objectAtIndex:2];
  }
  return id;
}

-(double) coreLocationAccuracy {
  if (self.beaconObject != Nil && [self.beaconObject isKindOfClass:[CLBeacon class]]) {
    return ((CLBeacon *)self.beaconObject).accuracy;
  }
  return -1.0;
}
+ (NSArray *) wrapCLBeacons:(NSArray *) clBeacons {
  NSMutableArray *beacons = [[NSMutableArray alloc] init];
  for (CLBeacon * clBeacon in clBeacons) {
    [beacons addObject: [RNLBeacon wrapCLBeacon: clBeacon]];
  }
  return beacons;
}

+ (RNLBeacon *) wrapCLBeacon:(CLBeacon *)clBeacon {
  RNLBeacon *beacon = [[RNLBeacon alloc] init];
  beacon.beaconObject = clBeacon;
  beacon.rssi = [NSNumber numberWithInteger:clBeacon.rssi];
  beacon.identifiers = @[[clBeacon.proximityUUID UUIDString],[clBeacon.major stringValue],[clBeacon.minor stringValue]];
  beacon.measuredPower = nil; // cannot read from a CLBeacon
  beacon.manufacturer = @0x004c;
  beacon.beaconTypeCode = @0x0215;
  beacon.dataFields = @[];
  return beacon;
}

- (BOOL) isEqualToBeacon: (RNLBeacon *)other {
  BOOL equal = true;
  // must have same number of identifiers
  if (self.identifiers.count != other.identifiers.count) {
    equal = false;
  }
  else {
    // All identifiers must match
    for (int i = 0; i < self.identifiers.count; i++) {
      if (![[self.identifiers objectAtIndex:i] isEqualToString:[other.identifiers objectAtIndex:i]]) {
        equal = false;
        break;
      }
    }
  }
  if (self.bluetoothIdentifier != nil && other.bluetoothIdentifier != nil) {
    if (![self.bluetoothIdentifier isEqualToString:other.bluetoothIdentifier]) {
      equal = false;
    }
  }
  else {
    if (self.bluetoothIdentifier != nil || other.bluetoothIdentifier != nil) {
      // if one is nil but not the other, then they are not the same
      equal = false;
    }
  }
  return equal;
  
}

+ (NSData *) dataFromIdentifier: (NSString*) identifier {
  NSMutableData* data = [NSMutableData data];
  if ([identifier containsString:@"-"]) {
    // convert uuid to regular hex string
    identifier = [identifier stringByReplacingOccurrencesOfString:@"-"                                   withString:@""];
    identifier = [NSString stringWithFormat:@"0x%@", identifier];
  }
  
  if ([identifier hasPrefix:@"0x"]) {
    int bytes = (int) (identifier.length-2)/2;
    // convert hex number
    for (int i = 0; i < bytes; i++) {
      NSString *hexByte = [identifier substringWithRange: NSMakeRange(i*2+2,2)];
      NSScanner* scanner = [NSScanner scannerWithString:hexByte];
      unsigned int intValue;
      [scanner scanHexInt:&intValue];
      [data appendBytes:&intValue length:1];
    }
  }
  else {
    // convert int 0-65535
    int intIdentifier = [identifier intValue];
    int highByte = intIdentifier >> 8;
    int lowByte = intIdentifier & 0xff;
    [data appendBytes:&highByte length: 1];
    [data appendBytes:&lowByte length: 1];
  }
  return data;
}

+ (NSArray *) matchBeacons: (NSArray * ) beacons bluetoothIdentifier:(NSString *)bluetoothIdentifier id1: (NSString *) id1 id2: (NSString *) id2 id3: (NSString *) id3 {
  NSMutableArray * matchingBeacons = [[NSMutableArray alloc] init];
  for (RNLBeacon *beacon in beacons) {
    BOOL match = YES;
    if (bluetoothIdentifier != nil) {
      if (beacon.bluetoothIdentifier != nil) {
        if (![bluetoothIdentifier isEqualToString:beacon.bluetoothIdentifier]) {
          match = NO;
        }
      }
    }
    if (id1 != nil) {
      if (beacon.id1 != nil) {
        if (![id1 isEqualToString:beacon.id1]) {
          match = NO;
        }
      }
    }
    if (id2 != nil) {
      if (beacon.id2 != nil) {
        if (![id2 isEqualToString:beacon.id2]) {
          match = NO;
        }
      }
    }
    if (id3 != nil) {
      if (beacon.id3 != nil) {
        if (![id3 isEqualToString:beacon.id3]) {
          match = NO;
        }
      }
    }
    if (match) {
      [matchingBeacons addObject: beacon];
    }
  }
  return matchingBeacons;
}

- (id)copyWithZone:(NSZone *)zone {
  RNLBeacon *copy = [[RNLBeacon alloc] init];
  
  if (self.beaconObject != nil) {
    copy.beaconObject = [self.beaconObject copyWithZone: nil];
  }
  copy.identifiers = [self.identifiers copyWithZone:nil];
  copy.dataFields = [self.identifiers copyWithZone:nil];
  if (self.bluetoothIdentifier != nil) {
    copy.bluetoothIdentifier = [self.bluetoothIdentifier copyWithZone:nil];
  }
  copy.manufacturer = self.manufacturer;
  copy.rssi = self.rssi;
  copy.beaconTypeCode = self.beaconTypeCode;
  copy.serviceUuid = self.serviceUuid;
  return copy;
}

@end
