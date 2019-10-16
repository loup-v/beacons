#import "BeaconsPlugin.h"
#import <beacons/beacons-Swift.h>
#import "RNLBeaconScanner.h"

@implementation BeaconsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBeaconsPlugin registerWithRegistrar:registrar];
}
@end
