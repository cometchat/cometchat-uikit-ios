//
//  CometChatUIKitSwift.h
//  CometChatUIKitSwift
//
//  Created by Admin on 06/09/23.
//

#import <Foundation/Foundation.h>

//! Project version number for CometChatUIKitSwiCometChatUIKitSwiftCallsCallsRT double CometChatUIKitSwiftVersionNumber;

//! Project version string for CometChatUIKitSwift.
FOUNDATION_EXPORT const unsigned char CometChatUIKitSwiftVersionString[];

#if __has_include(<CometChatCallsSDK/CometChatCallsSDK.h>)
#define __HAS_SOME_MODULE_FRAMEWORK__
#import <CometChatCallsSDK/CometChatCallsSDK.h>
#endif

@interface CometChatUIKitSwiftCalls: NSObject


@end
