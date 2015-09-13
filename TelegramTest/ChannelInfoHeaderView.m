//
//  ChannelInfoHeaderView.m
//  Telegram
//
//  Created by keepcoder on 21.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ChannelInfoHeaderView.h"
#import "UserInfoParamsView.h"

@interface ChannelInfoHeaderView ()
@property (nonatomic,strong) UserInfoParamsView *linkView;
@property (nonatomic,strong) UserInfoParamsView *aboutView;

@property (nonatomic,strong) UserInfoShortButtonView *linkEditButton;


@property (nonatomic,strong) UserInfoShortButtonView *openOrJoinChannelButton;



@property (nonatomic,strong) TMTextField *aboutTextView;
@property (nonatomic,strong) TMTextField *aboutDescription;


@property (nonatomic,strong) TMView *editAboutContainer;

@end

@implementation ChannelInfoHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _editAboutContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect) - 200, 62)];
        
        self.aboutTextView = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 24, NSWidth(_editAboutContainer.frame) , 23)];
        
        
        [self.aboutTextView setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
        
        [self.aboutTextView setEditable:YES];
        [self.aboutTextView setBordered:NO];
        [self.aboutTextView setFocusRingType:NSFocusRingTypeNone];
        [self.aboutTextView setTextOffset:NSMakeSize(0, 5)];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"Compose.ChannelAboutPlaceholder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:str.range];
        
        [self.aboutTextView.cell setPlaceholderAttributedString:str];
        [self.aboutTextView setPlaceholderPoint:NSMakePoint(2, 0)];
        
        
        [_editAboutContainer addSubview:self.aboutTextView];
        
        
        TMView *separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 15, NSWidth(_editAboutContainer.frame), 1)];
        
        separator.backgroundColor = DIALOG_BORDER_COLOR;
        
        
        [_editAboutContainer addSubview:separator];
        
        
        
        
        _aboutDescription = [TMTextField defaultTextField];
        [_aboutDescription setFont:TGSystemFont(13)];
        [_aboutDescription setTextColor:GRAY_TEXT_COLOR];
        
        
        [_aboutDescription setStringValue:NSLocalizedString(@"Compose.ChannelAboutDescription", nil)];
        
        
        
        [_aboutDescription setFrameOrigin:NSMakePoint(0, 0)];
        
        [_editAboutContainer addSubview:_aboutDescription];
        
        
        [self addSubview:_editAboutContainer];
        
        self.linkView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.linkView setHeader:NSLocalizedString(@"Profile.ShareLink", nil)];
        [self addSubview:self.linkView];
        
        
        self.aboutView = [[UserInfoParamsView alloc] initWithFrame:NSMakeRect(100, 50, 200, 61)];
        [self.aboutView setHeader:NSLocalizedString(@"Profile.About", nil)];
        [self addSubview:self.aboutView];
        
        
        self.linkEditButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.EditLink", nil) tapBlock:^{
            
            [self.controller setType:ChatInfoViewControllerNormal];
            
            [[Telegram rightViewController] showUserNameControllerWithChannel:(TL_channel *)self.controller.chat completionHandler:^{
                [self reload];
                [self.controller.navigationViewController goBackWithAnimation:YES];
            }];
            
        }];
        
        
       
        
        
        [self.setGroupPhotoButton.textButton setStringValue:NSLocalizedString(@"Profile.SetChannelPhoto", nil)];
        
        [self.setGroupPhotoButton sizeToFit];
        
        [self addSubview:self.linkEditButton];
        
        self.linkEditButton.textButton.textColor = TEXT_COLOR;
        self.setGroupPhotoButton.textButton.textColor = TEXT_COLOR;
        self.addMembersButton.textButton.textColor = TEXT_COLOR;
        
        self.openOrJoinChannelButton = [UserInfoShortButtonView buttonWithText:NSLocalizedString(@"Profile.OpenChannel", nil) tapBlock:^{
            
            [[Telegram rightViewController] showByDialog:self.controller.chat.dialog sender:self];
            
        }];
        
        
        [self addSubview:self.openOrJoinChannelButton];
        
    }
    
    return self;
}

- (void)reload {
    
    
    TLChat *chat = self.controller.chat;
    
    [[FullChatManager sharedManager]  performLoad:chat.n_id isChannel:[chat isKindOfClass:[TL_channel class]] callback:^(TLChatFull *fullChat) {
        
        self.controller.fullChat = fullChat;
        
        
        [self.aboutTextView setStringValue:self.controller.fullChat.about];
        
        [self.statusTextField setChat:chat];
        [self.statusTextField sizeToFit];
        
        if(!self.controller.fullChat) {
            MTLog(@"full chat is not loading");
            return;
        }
        
        [self.avatarImageView setChat:chat];
        [self.avatarImageView rebuild];
        
        [self.nameTextField setChat:chat];
        
        
        int h = [self.linkView setString:self.controller.chat.usernameLink];
        
        [self.linkView setFrameSize:NSMakeSize(NSWidth(self.linkView.frame), h+50)];
        
        h = [self.aboutView setString:self.controller.fullChat.about];
        
        [self.aboutView setFrameSize:NSMakeSize(NSWidth(self.linkView.frame), h+50)];
        
        
        [self TMNameTextFieldDidChanged:self.nameTextField];
        
        
        
        [self rebuildOrigins];

    }];

}

-(void)rebuildOrigins {
    
    [self.exportChatInvite setHidden:YES];
    [self.sharedMediaButton setHidden:YES];
    [self.filesMediaButton setHidden:YES];
    [self.sharedLinksButton setHidden:YES];
    
    
    [self.linkView setHidden:self.type == ChatInfoViewControllerEdit || self.linkView.string.length == 0];
    [self.aboutView setHidden:self.type == ChatInfoViewControllerEdit || self.aboutView.string.length == 0];
    
    
    
    [self.editAboutContainer setHidden:self.type != ChatInfoViewControllerEdit];
    
    [self.linkEditButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.setGroupPhotoButton setHidden:self.type != ChatInfoViewControllerEdit];
    [self.openOrJoinChannelButton setHidden:self.type == ChatInfoViewControllerEdit];
    
    [self.addMembersButton setHidden:self.type != ChatInfoViewControllerEdit];
    
    int yOffset = 0;
    
    [self.notificationView setFrame:NSMakeRect(100,  yOffset, NSWidth(self.frame) - 200, 42)];
    
    
    yOffset+=42;
    
    if(!self.addMembersButton.isHidden) {
        yOffset+=NSHeight(self.notificationView.frame);
        
        [self.addMembersButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
    }
    
    
    
    if(self.type == ChatInfoViewControllerNormal) {
        
        if(!self.openOrJoinChannelButton.isHidden) {
            yOffset+=42;
        }
        
        if(!self.openOrJoinChannelButton.isHidden) {
            [self.openOrJoinChannelButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame)-200, 42)];
            
            yOffset+=NSHeight(self.openOrJoinChannelButton.frame);
        }
        
        if(!self.linkView.isHidden || !self.aboutView.isHidden || !self.openOrJoinChannelButton.isHidden) {
            yOffset+=42;
        }
        
        
        if(!self.aboutView.isHidden) {
            [self.aboutView setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, NSHeight(self.aboutView.frame))];
            
            yOffset+=NSHeight(self.aboutView.frame);
        }
        
        if(!self.linkView.isHidden) {
            [self.linkView setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, NSHeight(self.linkView.frame))];
            
            yOffset+=NSHeight(self.linkView.frame);
        }
        
    } else {
        
        yOffset+=42;
        
        
        [self.linkEditButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.linkEditButton.frame);
        
        [self.setGroupPhotoButton setFrame:NSMakeRect(100, yOffset, NSWidth(self.frame) - 200, 42)];
        
        yOffset+=NSHeight(self.setGroupPhotoButton.frame) + 42;
        
        
        [_editAboutContainer setFrameSize:NSMakeSize(NSWidth(self.frame) - 200, NSHeight(_editAboutContainer.frame))];
        
        [self.editAboutContainer setFrameOrigin:NSMakePoint(100, yOffset)];
        
        yOffset+=NSHeight(self.editAboutContainer.frame);
        
    }
    
    [self.nameTextField setFrameOrigin:NSMakePoint(180, yOffset + (NSHeight(self.avatarImageView.frame)/2) + roundf(NSHeight(self.statusTextField.frame)/2 + NSHeight(self.nameTextField.frame)/2)) ];
    
    [self.statusTextField setFrameOrigin:NSMakePoint(178, yOffset + (NSHeight(self.avatarImageView.frame)/2)  )];

    
    [self.nameLiveView setFrameOrigin:NSMakePoint(182, NSMinY(self.nameTextField.frame) - 5)];
    
    
    [self.nameLiveView setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameLiveView.frame) - 100, NSHeight(self.nameLiveView.frame))];
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameTextField.frame) - 100, NSHeight(self.nameTextField.frame))];
    
    
    yOffset+=20;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(100, yOffset)];
    
    
    yOffset+=100;
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), yOffset)];
    
    [self.controller buildFirstItem];
    

}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_editAboutContainer setFrameSize:NSMakeSize(newSize.width - 200, NSHeight(_editAboutContainer.frame))];
    
    
    [_aboutTextView setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), NSHeight(_aboutTextView.frame))];
    [_aboutDescription setFrameSize:NSMakeSize(NSWidth(_editAboutContainer.frame), 18)];
    
    [self.nameLiveView setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameLiveView.frame) - 100, NSHeight(self.nameLiveView.frame))];
    [self.nameTextField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMinX(self.nameTextField.frame) - 100, NSHeight(self.nameTextField.frame))];
    
}

-(void)save {
    dispatch_block_t block = ^{
        self.controller.type = ChatInfoViewControllerNormal;
        [self reload];
        
        [TMViewController hideModalProgress];
    };
    
    
    dispatch_block_t next = ^{
      
        if(![self.controller.fullChat.about isEqualToString:self.aboutTextView.stringValue]) {
            
            [RPCRequest sendRequest:[TLAPI_messages_editChatAbout createWithChat_id:self.controller.chat.inputPeer about:self.aboutTextView.stringValue] successHandler:^(RPCRequest *request, id response) {
                
                if(self.controller.fullChat != nil) {
                    self.controller.fullChat.about = [request.object about];
                    
                    [[Storage manager] insertFullChat:self.controller.fullChat completeHandler:nil];
                } else {
                    [[FullChatManager sharedManager] loadIfNeed:self.controller.chat.n_id force:YES isChannel:YES];
                }
                
                
                block();
            } errorHandler:^(id request, RpcError *error) {
                block();
            }];
            
        } else {
            block();
        }
        
    };
    
    [TMViewController showModalProgress];
    
    if(![self.nameTextField.stringValue isEqualToString:self.controller.chat.title] && self.nameTextField.stringValue.length > 0) {
        
        [RPCRequest sendRequest:[TLAPI_messages_editChatTitle createWithChat_id:self.controller.chat.inputPeer title:self.nameTextField.stringValue] successHandler:^(RPCRequest *request, id response) {
            next();
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            next();
        }];
    } else
        next();
}


-(void)setType:(ChatInfoViewControllerType)type {
    [super setType:type];
    
    [self rebuildOrigins];
}


@end
