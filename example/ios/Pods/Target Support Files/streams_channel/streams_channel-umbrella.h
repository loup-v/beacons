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

#import "FlutterStreamsChannel.h"
#import "StreamsChannelPlugin.h"

FOUNDATION_EXPORT double streams_channelVersionNumber;
FOUNDATION_EXPORT const unsigned char streams_channelVersionString[];

