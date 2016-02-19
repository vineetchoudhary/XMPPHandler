//
//  XMPPHandler.h
//
//  Created by Vineet Choudhary
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

#import "XMPPCoreDataHandler.h"

@implementation XMPPCoreDataHandler{
    
}

+ (XMPPCoreDataHandler *)defaultXMPPCoreDataHandler{
    static XMPPCoreDataHandler *defaultXMPPCoreDataHandler = nil;
    if (defaultXMPPCoreDataHandler == nil) {
        defaultXMPPCoreDataHandler = [[XMPPCoreDataHandler alloc] init];
        
        //Register Notification for Received Messages
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(receivedMessage:) name:XMPPStreamDidReceiveMessage object:nil];
        
        //Register Notification for Successfully Send Message
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(messageSendSuccessfully:) name:XMPPStreamDidSendMessage object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(failedToSendMessage:) name:XMPPStreamDidFailToSendMessage object:nil];
        
        //Register Notification for Received Presence
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(receivedPresence:) name:XMPPStreamDidReceivePresence object:nil];
        
        //Register Notification for Authentication Success
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(userDidAuthenticated:) name:XMPPStreamDidAuthenticate object:nil];
        
        //Register Notification for Received IQ
        [[NSNotificationCenter defaultCenter] addObserver:defaultXMPPCoreDataHandler selector:@selector(receivedIQ:) name:XMPPStreamDidReceiveIQ object:nil];
    }
    return defaultXMPPCoreDataHandler;
}

#pragma mark - Notification Handler
-(void)messageSendSuccessfully:(NSNotification *)notification{
    XMPPMessage *message = notification.object;
    if (message.isChatMessageWithBody) {
        NSString *messageId = [message elementID];
        //TODO : Update send message state here in database
    }
}

-(void)failedToSendMessage:(NSNotification *)notification{
    XMPPMessage *message = notification.object;
    NSString *messageId = [message elementID];
    NSString *friendId = [[message valueForKey:@"to"] user];
    //TODO : Update failed message state here in database
}

-(void)receivedMessage:(NSNotification *)notification{
    XMPPMessage *message = notification.object;
    NSString *friendId = [[message valueForKey:@"from"] user];
    
    //TODO: 1. Check friend store in database or not. If not exist then first add friend than move forward
    
    //TODO: 2. Mark all messages as read, because friend read all my message when I was offlien
    
    if (message.isChatMessageWithBody){
        NSString *messageContent = [[message elementForName:@"body"] stringValue];
        NSString *messageId = [message elementID];
        
        //TODO: 3. Save received message in database
        
        //TODO: 4. You can show a local toast message (Optional)
    }
    
    //TODO: If message contains chat state then update friend chat message state
    else if (message.isChatMessage) {
        if (message.hasActiveChatState) {
            
        }else if (message.hasComposingChatState){
            
        }else if (message.hasPausedChatState){
            
        }else if (message.hasInactiveChatState){
            
        }else if (message.hasGoneChatState){
            
        }
    }
    
    //TODO: If message contains receipt response then save sent message receipt in database
    else if (message.hasReceiptResponse){
        
    }
}

-(void)receivedPresence:(NSNotification *)notification{
    XMPPPresence *presence = notification.object;
    NSString *friendId = presence.from.user;
  
    
    if ([presence isErrorPresence]) {

    }else if ([presence.from.user isEqualToString:[XMPPHandler defaultXMPPHandler].userId]){
        
    }else if ([presence.type isEqualToString:@"subscribe"]){
        
    }else if ([presence.type isEqualToString:@"subscribed"]){
        //TODO: Update FriendActiveStatus to FriendStatusActive
    }else if ([presence.type isEqualToString:@"unsubscribe"]){
        
    }else if ([presence.type isEqualToString:@"unsubscribed"]){
        //TODO:  Update FriendActiveStatus to FriendStatusFriendBlockedMe
    }else if ([presence.type isEqualToString:@"available"]){
        //TODO: Update friend availability
    }else if ([presence.type isEqualToString:@"unavailable"]){
        //TODO: 1. Update friend last seen with current time
        
        //TODO: 2. Update friend ChatState to ChatStateGone
        
        //TODO: 3. Update friend availablity to Unavailable
    }
}

-(void)receivedIQ:(NSNotification *)notification{
    XMPPIQ *iq = [notification object];
    //Check for lastSeenTime
    if ([iq.elementID isEqualToString:XMPPLastSeanElementId]) {
        NSString *friendId = iq.from.user;
        NSNumber *lastSeenTime = [NSNumber numberWithInteger:[[iq elementForName:@"query"] attributeIntegerValueForName:@"seconds"]];
        DebugLog(@"Last Seen Time %@",lastSeenTime);
        if (lastSeenTime.integerValue == 0) {
            //TODO: Update friend availablity to Available
        }else{
            //TODO: 1. Update friend last seen with current time
        	   NSDate *lastSeen = [NSDate dateWithTimeIntervalSince1970:([NSDate date].timeIntervalSince1970 - lastSeenTime.floatValue)];
                
            //TODO: 2. Update friend ChatState to ChatStateGone
        
            //TODO: 3. Update friend availablity to Unavailable
        }
    }
}

-(void)userDidAuthenticated:(NSNotification *)notification{
    //TODO: Send offline messages
}

#pragma mark - XMPPHandler Method Override
- (void)setChatState:(ChatState)chatState forFriendWithFriendId:(NSString *)friendId{
    //TODO: Save chat state in database
    
    //Set chat state with XMPPHandler for friendId
    [[XMPPHandler defaultXMPPHandler] setChatState:chatState forFriendWithFriendId:friendId];
}

- (void)sendMessage:(NSString *)message toFriendWithFriendId:(NSString *)friendId andMessageId:(NSString *)messageId{
    //Generate UUID if developer not set any custom message id
    messageId = (messageId.length > 0)?messageId:[XMPPStream generateUUID];
    
    //TODO: Save send message with MessageStateWaiting
    
    //Send message with XMPPHandler
    [[XMPPHandler defaultXMPPHandler] sendMessage:message toFriendWithFriendId:friendId andMessageId:messageId];
}

- (void)blockFriendWithFriendId:(NSString *)friendId{
    //TODO: Save FriendStatusFriendBlockedMe in database

    //Send block request with XMPPHandler
    [[XMPPHandler defaultXMPPHandler] blockFriendWithFriendId:friendId];
}

- (void)unblockFriendWithFriendId:(NSString *)friendId{
    //TODO: Save FriendStatusActive in database
    
    //Send unblock request with XMPPHandler
    [[XMPPHandler defaultXMPPHandler] unblockFriendWithFriendId:friendId];
}


@end
