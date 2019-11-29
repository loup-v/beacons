#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BeaconsPlugin.h"
#import "RNLBeacon+Distance.h"
#import "RNLBeacon.h"
#import "RNLBeaconParser.h"
#import "RNLBeaconScanner.h"
#import "RNLBeaconTableViewController.h"
#import "RNLBeaconTracker.h"
#import "RNLLocationTracker.h"
#import "RNLSignalMeasurement.h"
#import "RNLURLBeaconCompressor.h"

FOUNDATION_EXPORT double beaconsVersionNumber;
FOUNDATION_EXPORT const unsigned char beaconsVersionString[];

