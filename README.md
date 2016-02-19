## XMPPHandler
`XMPPHandler` is a wrapper of `XMPP Framework` which contains an easy-to-use and well-documented `Objective-C` class for communicating with an XMPP server with CoreData extension support. It supports basic Instant Messaging and Presence functionality as well as a variety of XMPP extensions.

## DEPENDENCY
1. XMPP Framework 3.6.6 (https://github.com/processone/XMPPFramework)
2. DebugLog (https://github.com/vineetchoudhary/iOS-Common-Code/tree/master/DebugLog)

## XMPPHandler Usage
`XMPPHandler` contains all method for communicating with XMPP Server in easy way. You don't need to modify this file.
#### XMPPHandler Examples
```Objective-C
XMPPHandler *xmppHandler = [XMPPHandler defaultXMPPHandler];
[xmppHandler setHostName:`YOUR_HOST_IP/URL`];
[xmppHandler setHostPort:[NSNumber numberWithInt:`YOUR_HOST_PORT`]];
[xmppHandler setUserId:`USER_ID`];
[xmppHandler setUserPassword:`USER_PASSWORD`];
[xmppHandler setShowErrorAlertView:YES];
[xmppHandler connectToXMPPServer]; //Connect to server
[xmppHandler registerUser]; //Register user (You can send register user request multiple time)
```    
#### Properties 
1. User details

    ```Objective-C
    @property (nonatomic, strong) NSString *userId;
    @property (nonatomic, strong) NSString *userPassword;
    ```

2. XMPPHost details

    ```Objective-C
    @property (nonatomic, strong) NSString *hostName;
    @property (nonatomic, strong) NSNumber *hostPort;
    @property (nonatomic, assign) BOOL allowSSLHostNameMismatch;
    @property (nonatomic, assign) BOOL allowSelfSignedCertificates;
    ```

3. XMPPHandler Configuration

    ```Objective-C
    @property (nonatomic, assign) BOOL showErrorAlertView;
    ```

4. XMPP ReadOnly Details

    ```Objective-C
    @property (nonatomic, assign, readonly) BOOL isConnectedToXMPPServer;
    ```        
        
#### Notification
##### XMPP Stream Notification
1. `XMPPStreamDidRegister` - XMPP Stream successfully register
2. `XMPPStreamDidNotRegister` - XMPP Stream failed to register
3. `XMPPStreamWillSecureWithSettings` - XMPP Stream will overide with your security settings
4. `XMPPStreamSocketDidConnect` - XMPP Stream socket successfully connected
5. `XMPPStreamDidSecure` - XMPP Stream successfully overide your security settings
6. `XMPPStreamDidConnect` - XMPP Stream successfully connected
7. `XMPPStreamDidDisconnect` - XMPP Stream failed to connect
8. `XMPPStreamDidReceiveError` - XMPP Stream received error
9. `XMPPStreamDidAuthenticate` - XMPP Stream successfully authenticate 
10. `XMPPStreamDidNotAuthenticate`- XMPP Stream failed to authenticate
11. `XMPPStreamDidReceiveIQ`- XMPP Stream received IQ (Info Query)
12. `XMPPStreamDidSendMessage` - XMPP Stream send message
13. `XMPPStreamDidFailToSendMessage` - XMPP Stream failed to send message
14. `XMPPStreamDidReceiveMessage` - XMPP Stream received message
15. `XMPPStreamDidReceivePresence` - XMPP Stream received Presence

##### XMPP Roster Notification
1. `XMPPRosterDidReceivePresenceSubscriptionRequest` - XMPP Roster received presence subscription request
2. `XMPPRosterDidReceiveRosterItem` - XMPP Roster received roster item
3. `XMPPRosterDidReceiveRosterPush` - XMPP Roster received roster push

##### XMPP Reconnect Notification
1. `XMPPReconnectShouldAttemptAutoReconnect` - XMPP trying to auto-reconnect with server

#### XMPP Constant Identifier 
1. `XMPPLastSeanElementId` - Friend last sean (IQ Identifier)
2. `XMPPActiveDuringOfflienMessageId` - Friend activity during offlien period (Message Identifier)

 
#### Methods
`XMPPHandle` handle most of the cases required to

1. Shared instance

    ```Objective-C
    + (XMPPHandler *)defaultXMPPHandler;
    ```
    
2. Setup and Clear XMPP Stream
 
    ```Objective-C
    -(void)setupXMPPStream;
    -(void)clearXMPPStream;
    ```
        
3. Connect and Disconnect with XMPP Server

    ```Objective-C
    - (BOOL)connectToXMPPServer;
    - (void)disconnectFromXMPPServer;
    ```
        
4. Register new user

    ```Objective-C
    - (void)registerUser; 
    ``` 
    
5. Set user status

    1. MyStatusAvailable
    2. MyStatusUnavailable 
    
    ```Objective-C    
    - (void)setMyStatus:(MyStatus)myStatus;
    ``` 
           
6. Set chat state for friend

    1. ChatStateActive
    2. ChatStateComposing
    3. ChatStatePaused
    4. ChatStateInactive
    5. ChatStateGone

    ```Objective-C    
    - (void)setChatState:(ChatState)chatState forFriendWithFriendId:(NSString *)friendId;
    ```
                
7. Send messages to friend

    ```Objective-C
    - (void)sendMessage:(NSString *)message toFriendWithFriendId:(NSString *)friendId andMessageId:(NSString *)messageId;
    ```
    
8. Add/Remove friend

    ```Objective-C
    - (void)removeFriendWithFriendId:(NSString *)friendId;
    - (void)addFriendWithFriendId:(NSString *)friendId andFriendNickName:(NSString *)nickName;
    ```
        
9. Block/Unblock friend

    ```Objective-C
    - (void)blockFriendWithFriendId:(NSString *)friendId;
    - (void)unblockFriendWithFriendId:(NSString *)friendId;
    ```
        
10. Accept/Reject Presence Subscription Request

    ```Objective-C
    - (void)rejectPresenceSubscriptionForFriendWithFriendId:(NSString *)friendId;
    - (void)acceptPresenceSubscriptionRequestForFriendWithFriendId:(NSString *)friendId andAddToRoster:(BOOL)addToRoster;
    ```
        
11. Get last active of friend (via I/Q)

    ```Objective-C
    - (void)getLastActivityForFriendWithFriendId:(NSString *)friendId;
    ```
        


## XMPPCoreDataHandler Usage
`XMPPCoreDataHandler` have observer for all notification and overide method for storing all XMPP activity in easy way. You can modify this file based on your requirent.
#### Methods

1. Shared instance

    ```Objective-C
    + (XMPPCoreDataHandler *)defaultXMPPCoreDataHandler;
    ```

#### Required Changes
You can modify this file based on your requirent. `XMPPCoreDataHandler.m` file contanis some `TODO` list. Please change based on your requirement or `CoreData` model.

#### XMPPCoreDataHandler Example

```Objective-C
XMPPCoreDataHandler *xmppCoreDataHandler = [XMPPCoreDataHandler defaultXMPPCoreDataHandler];
//Now call overide method of `XMPPHandler` class to process CoreData query before calling `XMPPHandler` (Super Class of `XMPPCoreDataHandler`) methods inside overide method 
[xmppCoreDataHandler setChatState:ChatStateActive forFriendWithFriendId:friendId];
```
 
## LICENSE
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
