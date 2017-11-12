//
//  JWLoginViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/24.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWLoginViewController.h"



static const CGFloat ItemHeight = 38;
static int second = 60;

@interface JWLoginViewController ()

@property (nonatomic , strong) UITextField *phoneNum;
@property (nonatomic , strong) UITextField *checkingNum;
@property (nonatomic , strong) UIButton *getCheckingNumBtn;
@property (nonatomic , strong) UIView *phoneNumBGView;
@property (nonatomic , strong) UIView *checkingNumBGView;
@property (nonatomic , strong) UIButton *loginBtn;

@property (nonatomic , strong) UIColor *smsTitleColor_Y;
@property (nonatomic , strong) UIColor *smsTitleColor_N;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JWLoginViewController

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    self.smsTitleColor_Y = [UIColor blueColor];
    self.smsTitleColor_N = UIColorFromRGB(0xBBBBBB);
    
    [self setupUI];
    [self bindingEvents];
}

- (void)bindingEvents {
    @weakify(self);
    
    RACSignal *validPhoneNumSignal = [self.phoneNum.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        return @([self isValidPhoneNum:value]);
    }];
    
    [[validPhoneNumSignal map:^id(NSNumber *validPhoneNum) {
        if (!self.timer) {
            self.getCheckingNumBtn.enabled = [validPhoneNum boolValue];
        }
        return [validPhoneNum boolValue] ?  self.smsTitleColor_Y : self.smsTitleColor_N;
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        if (!self.timer) {
            [self.getCheckingNumBtn setTitleColor:color forState:UIControlStateNormal];
        }
    }];
    
    RACSignal *validCheckingNumSignal = [self.checkingNum.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        return @([self isValidCheckingNum:value]);
    }];
    
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validPhoneNumSignal,validCheckingNumSignal] reduce:^id(NSNumber *phoneNumValid,NSNumber *checkingNumValid){
        return @([phoneNumValid boolValue] && [checkingNumValid boolValue]);
    }];
    
    [[signUpActiveSignal map:^id(NSNumber *signupActive) {
        self.loginBtn.enabled = [signupActive boolValue];
        return [signupActive boolValue] ? [UIColor greenColor] : [UIColor redColor];
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        [self.loginBtn setBackgroundColor:color];
    }];
    
    
    [[[[self.getCheckingNumBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        [self updateGetCheckingNumBtnStatus:NO];
    }] flattenMap:^id (id value) {
        @strongify(self);
        return [self getCheckingNum];
    }] subscribeNext:^(NSNumber *success) {
        @strongify(self);
        BOOL isSuccess = [success boolValue];
        if (isSuccess) {
            [ProgressHUD showSuccess:@"Verification code has been sent"];
            self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
            [self.timer setFireDate:[NSDate distantPast]];
        }else{
            [ProgressHUD showError:@"Verification code failed"];
            [self updateGetCheckingNumBtnStatus:YES];
            [self.getCheckingNumBtn setTitle:@"regain" forState:UIControlStateNormal];
        }
    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.loginBtn.enabled = NO;
    }] flattenMap:^id (id value) {
        @strongify(self);
        return [self verifySMSCode];
    }] subscribeNext:^(NSNumber *signedIn) {
        @strongify(self);
        self.loginBtn.enabled = YES;
        BOOL success = [signedIn boolValue];
        if (success) {
            //login success
            [self createUser];
        }else{
            [ProgressHUD showError:@"Validation fails"];
        }
    }];
    
    
}

- (void)createUser {
    BmobObject *user = [BmobObject objectWithClassName:@"GameUser"];
    [user setObject:self.phoneNum.text forKey:@"phoneNum"];
    [user setObject:[self getNickNameByPhoneNum:self.phoneNum.text] forKey:@"nickName"];
    [user saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //back game
            [self getUserInfo:user];
            [ProgressHUD showSuccess];
        }else{
            [ProgressHUD showError:@"Login fails"];
        }
    }];
}

- (void)getUserInfo:(BmobObject *)user {
    if (user) {
        NSString *userId = [user objectForKey:@"objectId"];
        if (userId && userId.length) {
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:UserId];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSNumber *bestScore = [user objectForKey:@"bestScore"];
        NSString *score = [[NSUserDefaults standardUserDefaults] objectForKey:BestScore];
        if ([bestScore integerValue] > [score integerValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",bestScore] forKey:BestScore];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (NSString *)getNickNameByPhoneNum:(NSString *)phoneNum {
    NSString *numberString = @"Unknown user";
    if (phoneNum.length == 11) {
        numberString = [phoneNum stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    return numberString;
}

- (void)countDown {
    if (second < 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.getCheckingNumBtn setTitle:@"regain" forState:UIControlStateNormal];
        if (self.phoneNum.text.length == 11) {
            [self updateGetCheckingNumBtnStatus:YES];
        }else {
            [self updateGetCheckingNumBtnStatus:NO];
        }
        second = 60;
    }else{
        [self.getCheckingNumBtn setTitle:[NSString stringWithFormat:@"%ds resend",second] forState:UIControlStateNormal];
        [self updateGetCheckingNumBtnStatus:NO];
        second--;
    }
}


- (void)updateGetCheckingNumBtnStatus:(BOOL)enable {
    self.getCheckingNumBtn.enabled = enable;
    if (enable) {
        [self.getCheckingNumBtn setTitleColor:self.smsTitleColor_Y forState:UIControlStateNormal];
    }else{
        [self.getCheckingNumBtn setTitleColor:self.smsTitleColor_N forState:UIControlStateNormal];
    }
}


- (RACSignal *)verifySMSCode {
    /*
    test code
     */
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
        return nil;
    }];
    
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:self.phoneNum.text andSMSCode:self.checkingNum.text resultBlock:^(BOOL isSuccessful, NSError *error) {
//            [subscriber sendNext:@(isSuccessful)];
//            [subscriber sendCompleted];
//        }];
//        return nil;
//    }];
    
}

- (RACSignal *)getCheckingNum {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
        return nil;
    }];
    
//    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:self.phoneNum.text andTemplate:@"500Points" resultBlock:^(int number, NSError *error) {
//            
//            if (error) {
//                [subscriber sendNext:@(NO)];
//            }else{
//                [subscriber sendNext:@(YES)];
//            }
//            [subscriber sendCompleted];
//            
//        }];
//        return nil;
//    }];
}

- (BOOL)isValidPhoneNum:(NSString *)phoneNum {
    if (phoneNum.length==11 && [phoneNum hasPrefix:@"1"]) {
        return YES;
    }
    if (phoneNum.length > 11) {
        self.phoneNum.text = [self.phoneNum.text substringWithRange:NSMakeRange(0, [self.phoneNum.text length]-1)];
        return YES;
        
    }
    return NO;
}

- (BOOL)isValidCheckingNum:(NSString *)checkingNum {
    if (checkingNum.length) {
        return  YES;
    }
    return NO;
}

- (void)setupUI {
    UIView *superView = self.view;
    [superView addSubview:self.phoneNumBGView];
    
    [self.phoneNumBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView).offset(RatioPoint(120));
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40), ItemHeight));

    }];
    
    superView = self.phoneNumBGView;
    [superView addSubview:self.phoneNum];
    
    [self.phoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.checkingNumBGView];
    [self.checkingNumBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.phoneNumBGView.mas_left);
        make.top.equalTo(self.phoneNumBGView.mas_bottom).offset(15);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40)-100-RatioPoint(15), ItemHeight));
    }];
    
    superView = self.checkingNumBGView;
    [superView addSubview:self.checkingNum];
    [self.checkingNum mas_makeConstraints:^(MASConstraintMaker *make) {
         make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.getCheckingNumBtn];
    [self.getCheckingNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.checkingNumBGView.mas_top);
        make.left.equalTo(self.checkingNumBGView.mas_right).offset(RatioPoint(15));
        make.size.mas_equalTo(CGSizeMake(100, ItemHeight));
    }];
    
    [superView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.checkingNumBGView.mas_bottom).offset(RatioPoint(80));
        make.size.equalTo(self.phoneNumBGView);
        make.centerX.equalTo(self.phoneNumBGView);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (UIView *)phoneNumBGView {
    if (!_phoneNumBGView) {
        _phoneNumBGView = [[UIView alloc] initWithFrame:CGRectZero];
        _phoneNumBGView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _phoneNumBGView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _phoneNumBGView.layer.borderWidth = 0.5;
        _phoneNumBGView.layer.cornerRadius = ItemHeight/2;
        _phoneNumBGView.clipsToBounds = YES;
    }
    return _phoneNumBGView;
}

- (UIView *)checkingNumBGView {
    if (!_checkingNumBGView) {
        _checkingNumBGView = [[UIView alloc] initWithFrame:CGRectZero];
        _checkingNumBGView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _checkingNumBGView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _checkingNumBGView.layer.borderWidth = 0.5;
        _checkingNumBGView.layer.cornerRadius = ItemHeight/2;
        _checkingNumBGView.clipsToBounds = YES;
    }
    return _checkingNumBGView;

}


- (UITextField *)phoneNum {
    if (!_phoneNum) {
        _phoneNum = [[UITextField alloc] initWithFrame:CGRectZero];
        _phoneNum.textColor = [UIColor blackColor];
        _phoneNum.keyboardType = UIKeyboardTypeNumberPad;
        NSMutableAttributedString *attriStr=[[NSMutableAttributedString alloc]initWithString:@"Please enter mobile phone"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xBBBBBB) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _phoneNum.attributedPlaceholder = attriStr;
    }
    return _phoneNum;
}

- (UITextField *)checkingNum {
    if (!_checkingNum) {
        _checkingNum= [[UITextField alloc] initWithFrame:CGRectZero];
        _checkingNum.textColor = [UIColor blackColor];
        _checkingNum.keyboardType = UIKeyboardTypeNumberPad;
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:@"please enter verification code"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xBBBBBB) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _checkingNum.attributedPlaceholder = attriStr;
    }
    return _checkingNum;
}

- (UIButton *)getCheckingNumBtn {
    if (!_getCheckingNumBtn) {
        _getCheckingNumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_getCheckingNumBtn setTitle:@"Verification code" forState:UIControlStateNormal];
        _getCheckingNumBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _getCheckingNumBtn;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _loginBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _loginBtn.layer.borderWidth = 0.5;
        _loginBtn.layer.cornerRadius = ItemHeight/2;
    }
    return _loginBtn;
}

@end
