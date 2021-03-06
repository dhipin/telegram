//
//  ResendSecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 09.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ResendSecretSenderItem.h"

@interface ResendSecretSenderItem ()
@property (nonatomic,strong) NSNumber *start_seq;
@property (nonatomic,strong) NSNumber *end_seq;
@end


@implementation ResendSecretSenderItem

-(id)initWithConversation:(TL_conversation *)conversation start_seq:(int)start_seq end_seq:(int)end_seq  {
    if( self = [super initWithConversation:conversation] ) {
        
        _start_seq = @(start_seq);
        _end_seq = @(end_seq);
        
        self.action = [[TGSecretAction alloc] initWithActionId:[MessageSender getFutureMessageId] chat_id:conversation.peer.chat_id decryptedData:[self decryptedMessageLayer]  senderClass:[ResendSecretSenderItem class] layer:self.params.layer];
        
        [self.action save];
        
    }
    
    return self;
}

-(NSData *)decryptedMessageLayer17 {
    return [Secret17__Environment serializeObject:[Secret17_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(17) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret17_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret17_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:_start_seq end_seq_no:_end_seq]]]];
}

-(NSData *)decryptedMessageLayer20 {
    return [Secret20__Environment serializeObject:[Secret20_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(20) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret20_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret20_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:_start_seq end_seq_no:_end_seq]]]];
}

-(NSData *)decryptedMessageLayer23 {
    return [Secret23__Environment serializeObject:[Secret23_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(23) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret23_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret23_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:_start_seq end_seq_no:_end_seq]]]];
}

-(NSData *)decryptedMessageLayer45 {
    return [Secret45__Environment serializeObject:[Secret45_DecryptedMessageLayer decryptedMessageLayerWithRandom_bytes:self.random_bytes layer:@(45) in_seq_no:@(2*self.params.in_seq_no + [self.params in_x]) out_seq_no:@(2*(self.params.out_seq_no++) + [self.params out_x]) message:[Secret45_DecryptedMessage decryptedMessageServiceWithRandom_id:@(self.random_id) action:[Secret45_DecryptedMessageAction decryptedMessageActionResendWithStart_seq_no:_start_seq end_seq_no:_end_seq]]]];
}



- (void)performRequest {
    
    TLAPI_messages_sendEncryptedService *request = [TLAPI_messages_sendEncryptedService createWithPeer:[TL_inputEncryptedChat createWithChat_id:self.action.chat_id access_hash:self.action.params.access_hash] random_id:self.random_id data:[MessageSender getEncrypted:self.action.params messageData:self.action.decryptedData]];
    
    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
        self.state = MessageSendingStateSent;
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateSent;
    }];
    
    
}

@end
