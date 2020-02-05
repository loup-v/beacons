#import <Flutter/Flutter.h>
//typedef FlutterMessageHandler (^FlutterStreamsHandlerFactory)();
@interface FlutterStreamsChannel : NSObject
+ (nonnull instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
+ (nonnull instancetype)streamsChannelWithName:(NSString*)name
                     binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                               codec:(NSObject<FlutterMethodCodec>*)codec;
- (nonnull instancetype)initWithName:(NSString*)name
             binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger
                       codec:(NSObject<FlutterMethodCodec>*)codec;
- (void)setStreamHandlerFactory:(NSObject<FlutterStreamHandler>* (^)(id))factory;
@end
