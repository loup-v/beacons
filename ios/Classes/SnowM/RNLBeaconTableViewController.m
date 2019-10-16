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

#import <UIKit/UIKit.h>
#import "RNLBeaconTableViewController.h"
#import "RNLBeaconScanner.h"
#import "RNLBeacon.h"
#import "RNLBeacon+Distance.h"

@interface RNLBeaconTableViewController()
@property (strong, nonatomic) RNLBeaconScanner *beaconScanner;
@property Boolean visible;
@property NSTimer *reloadTimer;
@property int beaconListSize;
@property NSDate *beaconListLastUpdated;
@property NSArray *sortedBeaconArray;
@end

@implementation RNLBeaconTableViewController 
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.beaconListSize = 0;
  self.beaconListLastUpdated = Nil;
  self.beaconScanner = [RNLBeaconScanner sharedBeaconScanner];
  [RNLBeacon secondsToAverage:20];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.visible = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.visible = YES;
  if (self.reloadTimer == Nil) {
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self
                                                      selector: @selector(refresh:) userInfo: nil repeats: YES];
  }
}

- (void) refresh: (NSTimer*) t  {
  dispatch_async(dispatch_get_main_queue(), ^{ [self.tableView reloadData]; });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self sortedBeacons].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return nil;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60.0;
}

- (NSArray *)sortedBeacons {
  Boolean resortNeeded = NO;
  NSArray *trackedBeacons = self.beaconScanner.trackedBeacons;
  
  if (trackedBeacons.count != self.beaconListSize) {
    resortNeeded = YES;
  }
  else {
    NSDate *latestDate = Nil;
    for (RNLBeacon *trackedBeacon in trackedBeacons) {
      if (latestDate == Nil || [latestDate compare:trackedBeacon.lastDetected] == NSOrderedAscending) {
        latestDate = trackedBeacon.lastDetected;
      }
    }
    if (self.beaconListLastUpdated == Nil || [self.beaconListLastUpdated compare:latestDate] == NSOrderedAscending) {
      resortNeeded = YES;
      self.beaconListLastUpdated = latestDate;
    }
  }
  if (resortNeeded) {
    self.beaconListSize = trackedBeacons.count;
    NSArray *sortedArray;
    sortedArray = [trackedBeacons sortedArrayUsingComparator:^NSComparisonResult(RNLBeacon *a, RNLBeacon *b) {
      NSString *p1 = [NSString stringWithFormat:@"%@_%@_%@", a.id1, a.id2, a.id3];
      NSString *p2 = [NSString stringWithFormat:@"%@_%@_%@", b.id1, b.id2, b.id3];
      NSLog(@"Comparing %@ to %@",p1, p2);
      return [p1 compare: p2];
    }];
    self.sortedBeaconArray = sortedArray;
  }
  return self.sortedBeaconArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  RNLBeacon *beacon = Nil;

  @try {
    beacon = [[self sortedBeacons] objectAtIndex:indexPath.row];
  }
  @catch (NSException *exception) {
    NSLog(@"%@", exception.reason);
  }
  
  UITableViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.textLabel.font  =  [UIFont fontWithName: @"Arial" size: 13.0 ];
  }
  cell.backgroundColor = [UIColor whiteColor];
  cell.accessoryView = nil; // can attach image here
  if (beacon != Nil) {
    if ([beacon.beaconTypeCode intValue] == 0x00) {
      cell.textLabel.text = [NSString stringWithFormat:@"%@ (Eddystone-UID)", beacon.id1];
      cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %@  Distance: %3.1f m\n%@", beacon.rssi, beacon.distance, beacon.id2];
      cell.detailTextLabel.numberOfLines = -1;
    }
    else {
      cell.textLabel.text = beacon.id1;
      cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.id2, beacon.id3];
      cell.detailTextLabel.numberOfLines = 1;
    }
  }
  else {
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.detailTextLabel.numberOfLines = 1;
  }
  return cell;
}

@end
