#import "BeaconsPlugin.h"
#import <beacons/beacons-Swift.h>

@implementation BeaconsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBeaconsPlugin registerWithRegistrar:registrar];
}
@end
