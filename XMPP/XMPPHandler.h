//
//  XMPPHandler.h
//
//  Created by Vineet Choudhary (http://vineetchoudhary.github.io/)
//  Copyright © Vineet Choudhary. All rights reserved.
//

/***
 DEPENDENCY
 ----------------------------------------------------------------------------------------------------
 1. XMPP Framework 3.6.6 (https://github.com/processone/XMPPFramework)
 2. DebugLog (https://github.com/vineetchoudhary/iOS-Common-Code/tree/master/DebugLog)
 ***/

/***
 LICENSE
 --------
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ***/

 /***
  Arrow helper
  ↖ ↑ ↗
  ← · →
  ↙ ↓ ↘
  ***/

#import <Foundation/Foundation.h>

//XMPP Core
#import <XMPP.h>
#import <XMPPRoster.h>
#import <XMPPReconnect.h>
#import <XMPPvCardTempModule.h>
#import <XMPPvCardAvatarModule.h>
#import <XMPPvCardCoreDataStorage.h>
#import <XMPPRosterCoreDataStorage.h>
#import <XMPPMessageDeliveryReceipts.h>
#import <XMPPCapabilitiesCoreDataStorage.h>
#import <XMPPvCardAvatarCoreDataStorageObject.h>

//XMPP Extension
#import <XMPPLastActivity.h>
#import <NSXMLElement+XMPP.h>
#import <XMPPIQ+LastActivity.h>
#import <XMPPMessage+XEP_0085.h>
#import <XMPPMessage+XEP_0184.h>

//Other Dependency
#import "DebugLog.h"

/***
        Available (Online) ←----------→ Unavailable (Offline)
    
 Available - Currently user connected to XMPP Server.
 Unavailable - Currently user not connected to XMPP Server.
 
 ***/
typedef enum : NSUInteger {
    MyStatusAvailable,
    MyStatusUnavailable
} MyStatus;

/***
                        Start
                          ↓
      .---------------→ Active ←---------------.
      |                   |                    |
      ↓                   ↓                    ↓
    Inactive ---------→ Gone ←-------------- Composing
      ↑                   ↑                    ↑
      |                   |                    |
      '---------------→ Paused ←---------------'
 
 Starting  - Someone started a conversation, but you haven’t joined in yet.
 Active    - You are actively involved in the conversation. You’re currently not composing any message, but you are paying close attention.
 Composing - You are actively composing a message.
 Paused    - You started composing a message, but stopped composing for some reason.
 Inactive  - You haven’t contributed to the conversation for some period of time.
 Gone      - Your involvement with the conversation has effectively ended (e.g., you have closed the chat window).
 
 ***/
typedef enum : NSUInteger {
    ChatStateActive,
    ChatStateComposing,
    ChatStatePaused,
    ChatStateInactive,
    ChatStateGone
} ChatState;


/***
 For Received Message - 
 
        Received
 
 Received - Message received.
 
 For Sent Message-
 
        Waiting --------→ Sent --------→ Delivered --------→ Read
           ↑
           |
           ↓
        Failed
 
 Waiting   - Currently message in local storage and waiting for XMPP Server connection.
 Sent      - Message received by server (if sender connected to XMPP Server).
 Delivered - Message delivered successfully.
 Read      - Message read by receiver.
 Failed    - Message failed. You can handle the failed message to make it again in wating state inorder to send it again.
 
 ***/
typedef enum : NSUInteger {
    MessageStateReceived = -1,
    MessageStateWaiting = 0,
    MessageStateSent,
    MessageStateDelivered,
    MessageStateRead,
    MessageStateFailed
} MessageState;

@interface XMPPHandler : NSObject <XMPPStreamDelegate, XMPPRosterDelegate, XMPPReconnectDelegate>{
    //XMPPSteam
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    
    //XMPPRoster
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;
    
    //XMPPvCard
    XMPPvCardCoreDataStorage *xmppvCardCoreDataStorage;
    XMPPvCardTempModule *xmppvCardTemp;
    XMPPvCardAvatarModule *xmppvCardAvatar;
    
    //Capabilities
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesCoreDataStorage;
}

//Notification Name
extern NSString * const XMPPStreamDidRegister;
extern NSString * const XMPPStreamDidNotRegister;
extern NSString * const XMPPStreamWillSecureWithSettings;
extern NSString * const XMPPStreamSocketDidConnect;
extern NSString * const XMPPStreamDidSecure;
extern NSString * const XMPPStreamDidConnect;
extern NSString * const XMPPStreamDidDisconnect;
extern NSString * const XMPPStreamDidReceiveError;
extern NSString * const XMPPStreamDidAuthenticate;
extern NSString * const XMPPStreamDidNotAuthenticate;
extern NSString * const XMPPStreamDidReceiveIQ;
extern NSString * const XMPPStreamDidSendMessage;
extern NSString * const XMPPStreamDidFailToSendMessage;
extern NSString * const XMPPStreamDidReceiveMessage;
extern NSString * const XMPPStreamDidReceivePresence;

extern NSString * const XMPPRosterDidReceivePresenceSubscriptionRequest;
extern NSString * const XMPPRosterDidReceiveRosterItem;
extern NSString * const XMPPRosterDidReceiveRosterPush;

extern NSString * const XMPPReconnectShouldAttemptAutoReconnect;

// Constant
extern NSString * const XMPPLastSeanElementId;
extern NSString * const XMPPActiveDuringOfflienMessageId;

//User details
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userPassword;

//XMPPHost details
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSNumber *hostPort;
@property (nonatomic, assign) BOOL allowSSLHostNameMismatch;
@property (nonatomic, assign) BOOL allowSelfSignedCertificates;

//XMPPHandler Configuration
@property (nonatomic, assign) BOOL showErrorAlertView;

//XMPP ReadOnly Details
@property (nonatomic, assign, readonly) BOOL isConnectedToXMPPServer;


+ (XMPPHandler *)defaultXMPPHandler;

- (void)setupXMPPStream;
- (void)clearXMPPStream;

- (BOOL)connectToXMPPServer;
- (void)disconnectFromXMPPServer;

- (void)registerUser;

- (void)setMyStatus:(MyStatus)myStatus;
- (void)setChatState:(ChatState)chatState forFriendWithFriendId:(NSString *)friendId;
- (void)sendMessage:(NSString *)message toFriendWithFriendId:(NSString *)friendId andMessageId:(NSString *)messageId;

- (void)removeFriendWithFriendId:(NSString *)friendId;
- (void)addFriendWithFriendId:(NSString *)friendId andFriendNickName:(NSString *)nickName;

- (void)blockFriendWithFriendId:(NSString *)friendId;
- (void)unblockFriendWithFriendId:(NSString *)friendId;

- (void)rejectPresenceSubscriptionForFriendWithFriendId:(NSString *)friendId;
- (void)acceptPresenceSubscriptionRequestForFriendWithFriendId:(NSString *)friendId andAddToRoster:(BOOL)addToRoster;

- (void)getLastActivityForFriendWithFriendId:(NSString *)friendId;

@end
