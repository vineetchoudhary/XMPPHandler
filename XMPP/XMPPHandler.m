//
//  XMPPHandler.h
//
//  Created by Vineet Choudhary (http://vineetchoudhary.github.io/)
//  Copyright © Vineet Choudhary. All rights reserved.
//


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

#import "XMPPHandler.h"

NSString * const XMPPStreamDidRegister = @"XMPPStreamDidRegister";
NSString * const XMPPStreamDidNotRegister = @"XMPPStreamDidNotRegister";
NSString * const XMPPStreamSocketDidConnect = @"XMPPStreamSocketDidConnect";
NSString * const XMPPStreamWillSecureWithSettings = @"XMPPStreamWillSecureWithSettings";
NSString * const XMPPStreamDidSecure = @"XMPPStreamDidSecure";
NSString * const XMPPStreamDidConnect = @"XMPPStreamDidConnect";
NSString * const XMPPStreamDidDisconnect = @"XMPPStreamDidDisconnect";
NSString * const XMPPStreamDidReceiveError = @"XMPPStreamDidReceiveError";
NSString * const XMPPStreamDidAuthenticate = @"XMPPStreamDidAuthenticate";
NSString * const XMPPStreamDidNotAuthenticate = @"XMPPStreamDidNotAuthenticate";
NSString * const XMPPStreamDidReceiveIQ = @"XMPPStreamDidReceiveIQ";
NSString * const XMPPStreamDidSendMessage = @"XMPPStreamDidSendMessage";
NSString * const XMPPStreamDidFailToSendMessage = @"XMPPStreamDidFailToSendMessage";
NSString * const XMPPStreamDidReceiveMessage = @"XMPPStreamDidReceiveMessage";
NSString * const XMPPStreamDidReceivePresence = @"XMPPStreamDidReceivePresence";
NSString * const XMPPRosterDidReceivePresenceSubscriptionRequest = @"XMPPRosterDidReceivePresenceSubscriptionRequest";
NSString * const XMPPRosterDidReceiveRosterItem = @"XMPPRosterDidReceiveRosterItem";
NSString * const XMPPRosterDidReceiveRosterPush = @"XMPPRosterDidReceiveRosterPush";
NSString * const XMPPReconnectShouldAttemptAutoReconnect = @"XMPPReconnectShouldAttemptAutoReconnect";

NSString * const XMPPLastSeanElementId = @"last1";
NSString * const XMPPActiveDuringOfflienMessageId = @"XMPPOfflienActiveMessageId";

@implementation XMPPHandler{
    
}

+ (XMPPHandler *)defaultXMPPHandler{
    static XMPPHandler *defaultXMPPHandler = nil;
    if (defaultXMPPHandler == nil) {
        defaultXMPPHandler = [[XMPPHandler alloc] init];
    }
    return defaultXMPPHandler;
}


#pragma mark - XMPP Stream Handler
- (void)setupXMPPStream{
    if (!xmppStream) {
        //initialize XMPPStream
        xmppStream = [[XMPPStream alloc] init];
        [xmppStream setEnableBackgroundingOnSocket:YES];
        [xmppStream setHostName:_hostName];
        [xmppStream setHostPort:_hostPort.intValue];
        
        //initialize XMPPReconnect
        xmppReconnect = [[XMPPReconnect alloc] init];
        
        //initialize XMPPRosterCoreDataStorage
        xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] init];
        
        //initialize XMPPRoster
        xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterCoreDataStorage];
        [xmppRoster setAutoFetchRoster:YES];
        [xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:YES];
        
        //initialize vCard Support
        xmppvCardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
        xmppvCardTemp = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardCoreDataStorage];
        
        //initialize Capabilities
        xmppCapabilitiesCoreDataStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
        xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesCoreDataStorage];
        [xmppCapabilities setAutoFetchHashedCapabilities:YES];
        [xmppCapabilities setAutoFetchNonHashedCapabilities:YES];
        
        //activate XMPP Modules
        [xmppReconnect activate:xmppStream];
        [xmppRoster activate:xmppStream];
        [xmppvCardTemp activate:xmppStream];
        [xmppvCardAvatar activate:xmppStream];
        [xmppCapabilities activate:xmppStream];
        
        //add delegate
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }else{
        DebugLog(@"XMPPSteam already setup.");
    }
}

- (void)clearXMPPStream{
    //remove delegate
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    //deactivate
    [xmppReconnect deactivate];
    [xmppRoster deactivate];
    [xmppvCardTemp deactivate];
    [xmppvCardAvatar deactivate];
    [xmppCapabilities deactivate];
    
    //disconnect XMPPStream
    [xmppStream disconnect];
    
    //clear objects
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterCoreDataStorage = nil;
    xmppvCardCoreDataStorage = nil;
    xmppvCardTemp = nil;
    xmppvCardAvatar = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesCoreDataStorage = nil;
}


#pragma mark - Connect/Disconnect to XMPP Server
- (BOOL)connectToXMPPServer{
    if (!xmppStream) {
        [self setupXMPPStream];
    }
    if (_userId && _userPassword) {
        if (xmppStream.isDisconnected) {
            [xmppStream setMyJID:[XMPPJID jidWithString:[self getCurrentUserFullId]]];
            
            //initialize XMPPMessageDeliveryReceipts
            XMPPMessageDeliveryReceipts *xmppMessageDeliveryReceipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
            [xmppMessageDeliveryReceipts setAutoSendMessageDeliveryReceipts:YES];
            [xmppMessageDeliveryReceipts setAutoSendMessageDeliveryRequests:YES];
            [xmppMessageDeliveryReceipts activate:xmppStream];
            
            //Client to Server Connection
            NSError *error;
            if ([xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
                return YES;
            }
            [self showErrorWithNSError:error];
            return NO;
        }
        return YES;
    }
    [self showErrorWithMessage:@"Please provide userId and userPassword"];
    return NO;
}

- (void)disconnectFromXMPPServer{
    [self setMyStatus:MyStatusUnavailable];
    [xmppStream disconnectAfterSending];
}

#pragma mark - Chat State Notification
- (void)setChatState:(ChatState)chatState forFriendWithFriendId:(NSString *)friendId{
    XMPPMessage *xmppMessage = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]]];
    
    //add chat state message
    switch (chatState) {
        case ChatStateActive:{
            [xmppMessage addActiveChatState];
        }break;
            
        case ChatStateComposing:{
            [xmppMessage addComposingChatState];
        }break;
            
        case ChatStateInactive:{
            [xmppMessage addInactiveChatState];
        }break;
            
        case ChatStatePaused:{
            [xmppMessage addPausedChatState];
        }break;
            
        case ChatStateGone:{
            [xmppMessage addGoneChatState];
        }break;
    }
    
    //send message
    [xmppStream sendElement:xmppMessage];
    DebugLog(@"XMPPStream - Sending Chat State : %@",xmppMessage.XMLString);
}

#pragma mark - Send Message
- (void)sendMessage:(NSString *)message toFriendWithFriendId:(NSString *)friendId andMessageId:(NSString *)messageId{
    /*
     Example : A content message with receipt requeste look like this
     
     <message xmlns="jabber:client" from="10@54.201.32.5/12612015031454577183303023" to="20@54.201.32.5" type="chat" id="EF96885B-EA00-48CC-810C-8C78045D6B96">
        <body>Awesome</body>
        <request xmlns="urn:xmpp:receipts"/>
     </message>
     */
    
    //message node
    NSXMLElement *messageNode = [NSXMLElement elementWithName:@"message"];
    [messageNode addAttributeWithName:@"type" stringValue:@"chat"];
    [messageNode addAttributeWithName:@"to" stringValue:[self getFullIdForFriendId:friendId]];
    [messageNode addAttributeWithName:@"id" stringValue:messageId];
    
    //body node
    NSXMLElement *bodyNode = [NSXMLElement elementWithName:@"body"];
    [bodyNode setStringValue:message];
    
    //request node for receipt
    NSXMLElement *receiptsRequestNode = [NSXMLElement elementWithName:@"request"];
    [receiptsRequestNode addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [receiptsRequestNode addAttributeWithName:@"id" stringValue:messageId];
    
    //add body and request node into message node
    [messageNode addChild:bodyNode];
    [messageNode addChild:receiptsRequestNode];
    
    //send message
    [xmppStream sendElement:messageNode];
    DebugLog(@"XMPPStream - Sending Message : %@",messageNode.XMLString);
}

#pragma mark - My Status
- (void)setMyStatus:(MyStatus)myStatus{
    XMPPPresence *xmppPresence;
    
    //set status
    switch (myStatus) {
        case MyStatusAvailable:{
            xmppPresence = [XMPPPresence presence];
        }break;
            
        case MyStatusUnavailable:{
            xmppPresence = [XMPPPresence presenceWithType:@"unavailable"];
        }break;
    }
    
    //broadcast status
    [xmppStream sendElement:xmppPresence];
    DebugLog(@"XMPPStream - Sending My Status : %@",xmppPresence.XMLString);
}

#pragma mark - Add/Remove Friend
- (void)addFriendWithFriendId:(NSString *)friendId andFriendNickName:(NSString *)nickName{
    [xmppRoster addUser:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]] withNickname:nickName];
    DebugLog(@"XMPPRoster - Adding Friend : %@ - %@",friendId,nickName);
}

- (void)removeFriendWithFriendId:(NSString *)friendId{
    [xmppRoster removeUser:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]]];
    DebugLog(@"XMPPRoster - Removing Friend : %@",friendId);
}

#pragma mark - Block/Unblocked Friend
- (void)blockFriendWithFriendId:(NSString *)friendId{
    [xmppRoster revokePresencePermissionFromUser:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]]];
    DebugLog(@"XMPPRoster - Block Friend : %@",friendId);
}

- (void)unblockFriendWithFriendId:(NSString *)friendId{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]]];
    DebugLog(@"XMPPRoster - UnBlock Friend : %@",friendId);
}

#pragma mark - Accept/Reject Presence Subscription
- (void)acceptPresenceSubscriptionRequestForFriendWithFriendId:(NSString *)friendId andAddToRoster:(BOOL)addToRoster{
    [xmppRoster acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]] andAddToRoster:addToRoster];
    DebugLog(@"XMPPRoster - Accept Presence Subscription Request From Friend : %@",friendId);
}

- (void)rejectPresenceSubscriptionForFriendWithFriendId:(NSString *)friendId{
    [xmppRoster rejectPresenceSubscriptionRequestFrom:[XMPPJID jidWithString:[self getFullIdForFriendId:friendId]]];
    DebugLog(@"XMPPRoster - Reject Presence Subscription From Friend : %@",friendId);
}

#pragma mark - Info/Query (or IQ)
- (void)getLastActivityForFriendWithFriendId:(NSString *)friendId{
    /*
     Example : A content last IQ requeste look like this
     
     <iq from="10@54.201.32.5" 
        to="19@54.201.32.5"
        id="last1"
        type="get">
        <query xmlns="jabber:iq:last"/>
     </iq>
     */
    
    NSXMLElement *iqNode = [NSXMLElement elementWithName:@"iq"];
    [iqNode addAttributeWithName:@"from" stringValue:[self getCurrentUserFullId]];
    [iqNode addAttributeWithName:@"to" stringValue:[self getFullIdForFriendId:friendId]];
    [iqNode addAttributeWithName:@"id" stringValue:XMPPLastSeanElementId];
    [iqNode addAttributeWithName:@"type" stringValue:@"get"];
    NSXMLElement *queryNode = [[NSXMLElement alloc] initWithName:@"query" xmlns:XMPPLastActivityNamespace];
    [iqNode addChild:queryNode];
    [xmppStream sendElement:iqNode];
}

#pragma mark - Register New User
- (void)registerUser{
    [xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",_userId,_hostName]]];
    NSError *error;
    BOOL registered = (xmppStream.isConnected)? [xmppStream registerWithPassword:_userPassword error:&error]:[self connectToXMPPServer];
    if (registered) {
        DebugLog(@"Register Success");
    }
    if (error) {
        [self showErrorWithNSError:error];
    }

}

#pragma mark - XMPPStream Delegate
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    DebugLog(@"XMPPStreamDelegate : User registered.");
    
    //post XMPPStreamDidRegister notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidRegister object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    DebugLog(@"XMPPStreamDelegate : User not registered.");
    [self showErrorWithMessage:error.XMLString];
    
    //post XMPPStreamDidNotRegister notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidNotRegister object:error];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    DebugLog(@"XMPPStreamDelegate : Socket Connected - %@",socket);
    
    //post XMPPStreamSocketDidConnect notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamSocketDidConnect object:socket];
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
    DebugLog(@"XMPPStreamDelegate : Initial Security Settings - %@",settings);
    if (_allowSelfSignedCertificates) {
        [settings setObject:[NSNumber numberWithBool:_allowSelfSignedCertificates] forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
    }
    if (_allowSSLHostNameMismatch) {
        [settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
    }else{
        NSString *serverDomain = xmppStream.hostName;
        NSString *virtualDomain = [xmppStream.myJID domain];
        NSString *expectedCertName = (serverDomain == nil)?virtualDomain:serverDomain;
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    DebugLog(@"XMPPStreamDelegate : Final Security Settings - %@",settings);
    
    //post XMPPStreamWillSecureWithSettings notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamWillSecureWithSettings object:settings];
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender{
    DebugLog(@"XMPPStreamDelegate : Secured.");
    
    //post XMPPStreamDidSecure notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidSecure object:nil];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    DebugLog(@"XMPPStreamDelegate : Connected.");
    
    //post XMPPStreamDidConnect notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidConnect object:nil];
    
    //set isConnectedToXMPPServer property
    _isConnectedToXMPPServer = YES;
    
    //Try to authenticate user
    NSError *error;
    if ([xmppStream authenticateWithPassword:_userPassword error:&error]) {
        DebugLog(@"XMPPStream : Authenticated");
    }
    if (error) {
        [self showErrorWithNSError:error];
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    DebugLog(@"XMPPStreamDelegate : Disconnected.");
    if (error) {
        [self showErrorWithNSError:error];
    }
    
    //post XMPPStreamDidDisconnect notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidDisconnect object:error];
    
    //set isConnectedToXMPPServer property
    _isConnectedToXMPPServer = NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    DebugLog(@"XMPPStreamDelegate : Received Error");
    [self showErrorWithMessage:error.XMLString];
    
    //post XMPPStreamDidReceiveError notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidReceiveError object:error];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    DebugLog(@"XMPPStreamDelegate : Authenticated");
    
    //post XMPPStreamDidNotAuthenticate notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidAuthenticate object:nil];
    
    //set mystatus is available
    [self setMyStatus:MyStatusAvailable];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    DebugLog(@"XMPPStreamDelegate : Authentication Failed.");
    [self showErrorWithMessage:error.stringValue];
    
    //post XMPPStreamDidAuthenticate notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidNotAuthenticate object:error];
    
    //If application in active state than connected to XMPP Server again
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self connectToXMPPServer];
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    DebugLog(@"XMPPStreamDelegate : Received IQ - %@",iq.XMLString);
    
    //post XMPPStreamDidReceiveIQ notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidReceiveIQ object:iq];
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    DebugLog(@"XMPPStreamDelegate : Send Message - %@",message.XMLString);
    
    //post XMPPDidSendMessage notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidSendMessage object:message];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    DebugLog(@"XMPPStreamDelegate : Failed to send message - %@",message.XMLString);
    [self showErrorWithNSError:error];
    
    //post XMPPDidFailToSendMessage Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidFailToSendMessage object:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    DebugLog(@"XMPPStreamDelegate : Receive Message - %@",message.XMLString);
    
    //post XMPPStreamDidReceiveMessage notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidReceiveMessage object:message];
    
    //Filter message based on it's type
    //Received error message
    if (message.isErrorMessage) {
        DebugLog(@"XMPPStreamDelegate : Receive Error Message.");
        return;
    }
    //Received message to notified your active on your windows when you offline
    else if ([message.elementID isEqualToString:XMPPActiveDuringOfflienMessageId] && message.isChatMessageWithBody){
        DebugLog(@"XMPPStreamDelegate : Friend %@ active on your windows when you offlien", message.from.user);
    }
    //Received message with body
    else if (message.isChatMessageWithBody){
        DebugLog(@"XMPPStreamDelegate : Message Content - %@",[[message elementForName:@"body"] stringValue]);
    }
    //Received chat state message
    else if (message.hasChatState){
        if (message.hasActiveChatState) {
            DebugLog(@"XMPPStreamDelegate : Active Chat State.");
        }else if (message.hasComposingChatState){
            DebugLog(@"XMPPStreamDelegate : Composing Chat State.");
        }else if (message.hasPausedChatState){
            DebugLog(@"XMPPStreamDelegate : Paused Chat State.");
        }else if (message.hasInactiveChatState){
            DebugLog(@"XMPPStreamDelegate : Inactive Chat State.");
        }else if (message.hasGoneChatState){
            DebugLog(@"XMPPStreamDelegate : Gone Chat State.");
        }
    }
    //Receipt Response
    else if(message.hasReceiptResponse){
        DebugLog(@"XMPPStreamDelegate : Message Receipt Response for Message - %@",message.receiptResponseID);
    }
    else{
        DebugLog(@"XMPPStreamDelegate : Uncategorised Message With Id - %@", [[message elementsForName:@"received"] firstObject]);
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    DebugLog(@"XMPPStreamDelegate : Receive Presence - %@ From User - %@",presence.XMLString,presence.from.user);
    
    //post XMPPStreamDidReceivePresence notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPStreamDidReceivePresence object:presence];
    
    //filter presence type
    if ([presence isErrorPresence]) {
        DebugLog(@"XMPPStreamDelegate : Receive Error Presence.");
    }else if ([presence.from.bare isEqualToString:xmppStream.myJID.bare]){
        DebugLog(@"XMPPStreamDelegate : Receive Self Presence.");
    }else if ([presence.type isEqualToString:@"subscribe"]){
        DebugLog(@"XMPPStreamDelegate : Receive Subscribe Presence.");
    }else if ([presence.type isEqualToString:@"subscribed"]){
        DebugLog(@"XMPPStreamDelegate : Receive Subscribed Presence.");
    }else if ([presence.type isEqualToString:@"unsubscribe"]){
        DebugLog(@"XMPPStreamDelegate : Receive Unsubscribe Presence.");
    }else if ([presence.type isEqualToString:@"unsubscribed"]){
        DebugLog(@"XMPPStreamDelegate : Receive Unsubscribed Presence.");
    }else if ([presence.type isEqualToString:@"available"]){
        DebugLog(@"XMPPStreamDelegate : Receive Available Presence.");
    }else if ([presence.type isEqualToString:@"unavailable"]){
        DebugLog(@"XMPPStreamDelegate : Receive Unavailable Presence.");
    }
}

#pragma mark - XMPPReconnect
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"XMPPReconnect : Attempting Auto Reconnect.");
    
    //post XMPPReconnectShouldAttemptAutoReconnect notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReconnectShouldAttemptAutoReconnect object:nil];
    
    return YES;
}

#pragma mark - XMPPRoster Delegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    DebugLog(@"XMPPRosterDelegate : ReceivePresenceSubscriptionRequest - %@",presence.XMLString);
    
    //post XMPPRosterDidReceivePresenceSubscriptionRequest notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRosterDidReceivePresenceSubscriptionRequest object:nil];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    DebugLog(@"XMPPRosterDelegate : ReceiveRosterItem - %@",item.XMLString);
    
    //post XMPPRosterDidReceiveRosterItem notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRosterDidReceiveRosterItem object:nil];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    DebugLog(@"XMPPRosterDelegate : ReceiveRosterPush - %@",iq.XMLString);
    
    //post XMPPRosterDidReceiveRosterPush notification
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPRosterDidReceiveRosterPush object:nil];
}

#pragma mark - Common Parser
- (NSString *)getCurrentUserFullId{
    return [self getFullIdForFriendId:_userId];
}

- (NSString *)getFullIdForFriendId:(NSString *)userId{
    return [NSString stringWithFormat:@"%@@%@",userId,_hostName];
}

#pragma mark - Properties Getter/Setter
- (NSString *)hostName{
    if (_hostName) {
        return _hostName;
    }
    [self showErrorWithMessage:@"Please set _hostName of the XMPPHandler before calling setupXMPPStream method."];
    return nil;
}

- (NSNumber *)hostPort{
    if (_hostPort) {
        return _hostPort;
    }
    [self showErrorWithMessage:@"Please set _hostPort of the XMPPHandler before calling setupXMPPStream method."];
    return nil;
}

- (NSString *)userId{
    if (_userId) {
        return _userId;
    }
    [self showErrorWithMessage:@"Please set _userId of the XMPPHandler before calling connectToXMPPServer method."];
    return nil;
}

-(NSString *)userPassword{
    if (_userPassword) {
        return _userPassword;
    }
    [self showErrorWithMessage:@"Please set _userPassword of the XMPPHandler before calling connectToXMPPServer method."];
    return nil;
}


#pragma mark - Error Visibilty Handler
- (void)showErrorWithNSError:(NSError *)error{
    DebugLog(@"NSError : %@",error);
    [self showErrorWithMessage:error.localizedDescription];
}

- (void)showErrorWithMessage:(NSString *)message{
    DebugLog(@"ERROR Description : %@",message);
    if (_showErrorAlertView) {
        [[[UIAlertView alloc] initWithTitle:@"ERROR" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

@end
