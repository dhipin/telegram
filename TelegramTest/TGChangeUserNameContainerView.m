//
//  TGChangeUserNameContainerView.m
//  Telegram
//
//  Created by keepcoder on 13.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChangeUserNameContainerView.h"
#import "UserInfoShortTextEditView.h"
#import "TGTimer.h"


@implementation TGChangeUserObserver

-(id)initWithDescription:(NSString *)desc placeholder:(NSString *)placeholder defaultUserName:(NSString *)defaultUserName {
    if(self = [super init]) {
        _desc = desc;
        _placeholder = placeholder;
        _defaultUserName = defaultUserName;
    }
    
    return self;
}

@end


@interface TGChangeUserNameContainerView ()<NSTextFieldDelegate>
@property (nonatomic,strong) UserInfoShortTextEditView *textView;
@property (nonatomic,strong) TMTextButton *button;
@property (nonatomic,strong) NSTextView *descriptionView;

@property (nonatomic,strong) NSProgressIndicator *progressView;
@property (nonatomic,strong) NSImageView *successView;
@property (nonatomic,strong) TGTimer *timer;
@property (nonatomic,assign) BOOL isSuccessChecked;
@property (nonatomic,assign) BOOL isRemoteChecked;
@property (nonatomic,strong) NSString *lastUserName;
@property (nonatomic,strong) NSString *checkedUserName;
@property (nonatomic,strong) RPCRequest *request;

@property (nonatomic,strong) TMTextField *statusTextField;
@end

#define GC NSColorFromRGB(0x61ad5e)

@implementation TGChangeUserNameContainerView

-(id)initWithFrame:(NSRect)frameRect observer:(TGChangeUserObserver *)observer {
    if(self = [super initWithFrame:frameRect]) {
        
        
        self.isFlipped = YES;
        
        _oberser = observer;
        
        self.successView = imageViewWithImage(image_UsernameCheck());
        
        self.progressView = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
        
        [self.progressView setStyle:NSProgressIndicatorSpinningStyle];
        
        
        self.textView = [[UserInfoShortTextEditView alloc] initWithFrame:NSMakeRect(30, 50, NSWidth(self.frame) - 60, 23)];
        
        [self.successView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.successView.frame), 8)];
        
        [self.progressView setFrameOrigin:NSMakePoint(NSWidth(self.textView.frame) - NSWidth(self.progressView.frame), 5)];
        
        self.successView.autoresizingMask = self.progressView.autoresizingMask = NSViewMinXMargin;
        
        [self.progressView setHidden:YES];
        
        [self.successView setHidden:YES];
        
        
        [self.textView addSubview:self.successView];
        
        [self.textView addSubview:self.progressView];
        
        
        self.statusTextField = [TMTextField defaultTextField];
        
        [self.statusTextField setTextColor:[NSColor redColor]];
        
        [self.statusTextField setStringValue:@"error cant set user name"];
        
        [self.statusTextField sizeToFit];
        
        [self.statusTextField setFrameOrigin:NSMakePoint(30, NSMinY(self.textView.frame) + 30)];
        
        [self addSubview:self.statusTextField];
        
        
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
        
        [str appendString:NSLocalizedString(@"UserName.placeHolder", nil) withColor:DARK_GRAY];
        [str setAlignment:NSLeftTextAlignment range:str.range];
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:str.range];
        
        [[self.textView textView].cell setPlaceholderAttributedString:str];
        [[self.textView textView] setPlaceholderPoint:NSMakePoint(0, 0)];
        
        self.textView.textView.delegate = self;
        
        [self addSubview:self.textView];
        
        [self.textView.textView setAction:@selector(performEnter)];
        [self.textView.textView setTarget:self];
        [self.textView.textView setNextKeyView:self];
        [self.textView.textView setFrameOrigin:NSMakePoint(0, NSMinY(self.textView.textView.frame))];
        
        
        self.descriptionView = [[NSTextView alloc] initWithFrame:NSMakeRect(26, 92, NSWidth(self.frame) - 60, 100)];
        
        [self.descriptionView setString:NSLocalizedString(@"UserName.description", nil)];
        
        [self.descriptionView setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        
        [self.descriptionView sizeToFit];
        [self.descriptionView setSelectable:NO];
        
        [self.descriptionView setTextContainerInset:NSMakeSize(0, 0)];
        
        
        [self addSubview:self.descriptionView];
        
        
    }
    
    return self;
}

-(void)setOberser:(TGChangeUserObserver *)oberser {
    _oberser = oberser;
    
    [_descriptionView setString:oberser.desc];
    [_descriptionView sizeToFit];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    
    [str appendString:oberser.placeholder withColor:DARK_GRAY];
    [str setAlignment:NSLeftTextAlignment range:str.range];
    [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:str.range];
    
    [[self.textView textView].cell setPlaceholderAttributedString:str];

    
    [self.textView.textView setStringValue:@""];
    
    [self updateChecker];
    
    [self setFrameSize:self.frame.size];
    
    // update interface
}

-(void)dispatchSaveBlock {
    [self performEnter];
}


- (void)performEnter {
    if((self.isRemoteChecked && ![[self defaultUsername] isEqualToString:self.checkedUserName]) || ([self defaultUsername] == nil && self.checkedUserName.length == 0)) {
        [self.textView.textView resignFirstResponder];
        if(self.oberser.willNeedSaveUserName != nil) {
            self.oberser.willNeedSaveUserName(self.textView.textView.stringValue);
        }
    }
}

-(void)updateSaveButton {
    
    
    if(self.oberser.didChangedUserName != nil) {
        self.oberser.didChangedUserName(self.textView.textView.stringValue,(![[self defaultUsername] isEqualToString:self.textView.textView.stringValue] && !((self.textView.textView.stringValue.length < 5) || (!self.isRemoteChecked || !self.isSuccessChecked))) || self.textView.textView.stringValue.length == 0);
    }
    
}

- (void)controlTextDidChange:(NSNotification *)obj {
    
    
    [self updateSaveButton];
    
    
    if((self.textView.textView.stringValue.length >= 5 && [self isNumberValid]) || self.textView.textView.stringValue.length == 0) {
        [self updateChecker];
    } else {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:YES];
        
        
        if(![self isNumberValid]) {
            [self setState:NSLocalizedString(@"USERNAME_CANT_FIRST_NUMBER", nil) color:[NSColor redColor]];
        } else {
            [self setState:NSLocalizedString(@"USERNAME_MIN_SYMBOLS_ERROR", nil) color:[NSColor redColor]];
        }
        
    }
    
    
}

-(BOOL)isNumberValid {
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self.textView.textView.stringValue rangeOfCharacterFromSet: nonNumbers];
    
    return r.location == 0;
}

-(NSString *)defaultUsername {
    return self.oberser.defaultUserName;
}


-(void)updateChecker {
    
    if([self.textView.textView.stringValue isEqualToString:[self defaultUsername]]) {
        [self.progressView setHidden:YES];
        [self.progressView stopAnimation:self];
        [self.successView setHidden:NO];
        
        [self setState:nil color:nil];
        
    } else if(![self.lastUserName isEqualToString:self.textView.textView.stringValue] && self.textView.textView.stringValue.length != 0) {
        
        if(!self.timer) {
            
            self.isSuccessChecked = NO;
            self.isRemoteChecked = [self.textView.textView.stringValue isEqualToString:[self defaultUsername]];
            [self updateSaveButton];
            
            self.timer = [[TGTimer alloc] initWithTimeout:0.2 repeat:NO completion:^{
                
                
                
                [self.successView setHidden:YES];
                [self.progressView setHidden:NO];
                [self.progressView startAnimation:self];
                
                if(self.request)
                    [self.request cancelRequest];
                
                NSString *userNameToCheck = self.textView.textView.stringValue;
                
                
                
                self.request = [RPCRequest sendRequest:self.oberser.needApiObjectWithUserName(userNameToCheck) successHandler:^(RPCRequest *request, id response) {
                    
                    self.isSuccessChecked = [response isKindOfClass:[TL_boolTrue class]];
                    self.isRemoteChecked = YES;
                    self.checkedUserName = userNameToCheck;
                    
                    
                    if(self.isSuccessChecked) {
                        [self setState:self.checkedUserName.length > 0 ? [NSString stringWithFormat:NSLocalizedString(@"UserName.avaiable", nil),self.checkedUserName] : nil color:GC];
                    } else {
                        [self setState:[NSString stringWithFormat:NSLocalizedString(@"USERNAME_IS_ALREADY_TAKEN", nil)] color:[NSColor redColor]];
                    }
                    
                    
                    
                    [self updateSaveButton];
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:!self.isSuccessChecked];
                    
                } errorHandler:^(RPCRequest *request, RpcError *error) {
                    
                    [self.progressView setHidden:YES];
                    [self.progressView stopAnimation:self];
                    
                    [self.successView setHidden:YES];
                    
                    [self setState:NSLocalizedString(error.error_msg, nil) color:[NSColor redColor]];
                    
                }];
                
                
            } queue:dispatch_get_current_queue()];
            
            [self.timer start];
            
        } else {
            [self.timer invalidate];
            self.timer = nil;
            [self updateChecker];
        }
        
        
    } else {
        [self setState:nil color:nil];
        [self updateSaveButton];
    }
    
    self.lastUserName = self.textView.textView.stringValue;
    
}

-(void)setState:(NSString *)state color:(NSColor *)color {
    [self.statusTextField setHidden:state.length == 0 || color == nil];
    self.statusTextField.stringValue = state;
    [self.statusTextField sizeToFit];
    self.statusTextField.textColor = color;
    
    [self.descriptionView setFrameOrigin:NSMakePoint(26, !self.statusTextField.isHidden ? 100 : 80)];
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    NSSize size = [self.descriptionView.attributedString sizeForTextFieldForWidth:newSize.width - 60];
    
    [self.descriptionView setFrameSize:NSMakeSize(newSize.width - 60, size.height)];
}

@end

