//
//  JWNormalLoginViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/30.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWNormalLoginViewController.h"
#import "JWRegisterViewController.h"

static const CGFloat ItemHeight = 38;

@interface JWNormalLoginViewController ()

@property (nonatomic , strong) UITextField *userNameTextField;
@property (nonatomic , strong) UITextField *passwordTextField;

@property (nonatomic , strong) UIView *userNameBgView;
@property (nonatomic , strong) UIView *passwordBgView;

@property (nonatomic , strong) UIButton *loginBtn;
@property (nonatomic , strong) UILabel *tipLabel;

@property (nonatomic , strong) UIView *lineView;
@property (nonatomic , strong) UILabel *centerLabel;
@property (nonatomic , strong) UIButton *registerBtn;

@end

@implementation JWNormalLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    [self setupUI];
    [self bindEvent];
    // Do any additional setup after loading the view.
}

- (void)bindEvent {
    @weakify(self);
    RACSignal *validUserName = [self.userNameTextField.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        self.tipLabel.hidden = YES;
        return @([self isValidUserName:value]);
    }];
    RACSignal *validPassword = [self.passwordTextField.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        self.tipLabel.hidden = YES;
        return @([self isValidPassword:value]);
    }];
    
    RACSignal *loginActiveSignal = [RACSignal combineLatest:@[validUserName,validPassword] reduce:^id(NSNumber *userNameValid,NSNumber *passwordValid){
        return @([userNameValid boolValue] && [passwordValid boolValue]);
    }];
    [[loginActiveSignal map:^id(NSNumber *loginActive) {
        @strongify(self);
        self.loginBtn.enabled = [loginActive boolValue];
        return [loginActive boolValue] ? [UIColor colorWithRed:0.64f green:0.78f blue:0.22f alpha:1.00f] : [UIColor colorWithRed:0.64f green:0.64f blue:0.64f alpha:1.00f];
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        [self.loginBtn setBackgroundColor:color];
    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.loginBtn.enabled = NO;
        [self.view endEditing:YES];
        self.tipLabel.hidden = YES;
    }] flattenMap:^id(id value) {
        @strongify(self);
        return [self verifyUserNameAndPassword];
    }] subscribeNext:^(NSNumber *signedId) {
        @strongify(self);
        self.loginBtn.enabled = YES;
        if ([signedId isEqual:@0]) {
            //success
            [ProgressHUD showSuccess:@"login success"];
            [self jumpToGameCenter];
        }else if([signedId isEqual:@1]){
            //wrongpassword
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"invalid password";
            [ProgressHUD dismiss];
        }else{
            //no user
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"invalid userName";
            [ProgressHUD dismiss];
        }
    }];
    
    [[[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.registerBtn.enabled = NO;
        [self.view endEditing:YES];
        
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self pushToRegister];
        self.registerBtn.enabled = YES;
    }];
}

- (void)pushToRegister {
    JWRegisterViewController *controller = [[JWRegisterViewController alloc] init];
    controller.backCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)jumpToGameCenter {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (RACSignal *)verifyUserNameAndPassword {

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ProgressHUD show];
        BmobQuery   *bquery = [BmobQuery queryWithClassName:@"GameUser"];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            BOOL isHaveUser = NO;
            NSString *password = nil;
            BmobObject *object = nil;
            for (BmobObject *obj in array) {
                NSString *nickName = [obj objectForKey:@"nickName"];
                if ([nickName isEqualToString:self.userNameTextField.text]) {
                    isHaveUser = YES;
                    object = obj;
                    password = [obj objectForKey:@"password"];
                    break;
                }
            }
            if (isHaveUser) {
                //findUser
                if ([password isEqualToString:self.passwordTextField.text]) {
                    //success
                    [self getUserInfo:object];
                    [subscriber sendNext:@(0)];
                }else{
                    //wrongpassword
                    [subscriber sendNext:@(1)];
                }
            }else{
                //nouser
                [subscriber sendNext:@(2)];
                
            }
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
    
}


- (BOOL)isValidPassword:(NSString *)password {
    return password.length;
}

- (BOOL)isValidUserName:(NSString *)userName {
    return userName.length;
}

- (void)setupUI {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIView *superView = self.view;
    [superView addSubview:self.userNameBgView];
    
    [self.userNameBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView).offset(RatioPoint(120));
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40), ItemHeight));
        
    }];
    
    superView = self.userNameBgView;
    [superView addSubview:self.userNameTextField];
    
    [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.passwordBgView];
    [self.passwordBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameBgView.mas_bottom).offset(15);
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40), ItemHeight));
    }];
    
    superView = self.passwordBgView;
    [superView addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordBgView.mas_bottom).offset(RatioPoint(80));
        make.size.equalTo(self.userNameBgView);
        make.centerX.equalTo(self.userNameBgView);
    }];

    [superView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordBgView.mas_bottom).offset(10);
        make.left.equalTo(superView).offset(RatioPoint(20));
    }];
    
    [superView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBtn.mas_bottom).offset(50);
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40), 0.5));
    }];
    
    [superView addSubview:self.centerLabel];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 40));
        make.center.equalTo(self.lineView);
    }];
    
    [superView addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 35));
        make.top.equalTo(self.lineView.mas_bottom).offset(60);
        make.centerX.equalTo(self.lineView.mas_centerX);
    }];
}

- (UIView *)userNameBgView {
    if (!_userNameBgView) {
        _userNameBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _userNameBgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _userNameBgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _userNameBgView.layer.borderWidth = 0.5;
        _userNameBgView.layer.cornerRadius = ItemHeight/2;
        _userNameBgView.clipsToBounds = YES;
    }
    return _userNameBgView;
}

- (UIView *)passwordBgView {
    if (!_passwordBgView) {
        _passwordBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _passwordBgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _passwordBgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _passwordBgView.layer.borderWidth = 0.5;
        _passwordBgView.layer.cornerRadius = ItemHeight/2;
        _passwordBgView.clipsToBounds = YES;
    }
    return _passwordBgView;
    
}


- (UITextField *)userNameTextField {
    if (!_userNameTextField) {
        _userNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNameTextField.textColor = [UIColor blackColor];
        NSMutableAttributedString *attriStr= [[NSMutableAttributedString alloc]initWithString:@"Please enter userName"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xBBBBBB) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _userNameTextField.attributedPlaceholder = attriStr;
    }
    return _userNameTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField= [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.textColor = [UIColor blackColor];
        _passwordTextField.secureTextEntry = YES;
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:@"Please enter password"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xBBBBBB) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _passwordTextField.attributedPlaceholder = attriStr;
    }
    return _passwordTextField;
}
- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _loginBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _loginBtn.layer.borderWidth = 0.5;
        _loginBtn.clipsToBounds = YES;
        _loginBtn.layer.cornerRadius = ItemHeight/2;
    }
    return _loginBtn;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"Register" forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_registerBtn setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
        [_registerBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _registerBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _registerBtn.layer.borderWidth = 0.5;
        _registerBtn.layer.cornerRadius = 4;
        _registerBtn.clipsToBounds = YES;
    }
    return _registerBtn;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.numberOfLines = 0;
        
    }
    return _tipLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = UIColorFromRGB(0xBBBBBB);
    }
    return _lineView;
}

- (UILabel *)centerLabel {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _centerLabel.textColor = UIColorFromRGB(0xBBBBBB);
        _centerLabel.backgroundColor = UIColorFromRGB(0xF8F8F8);
        _centerLabel.font = [UIFont systemFontOfSize:14];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.text = @"You can also";
    }
    return _centerLabel;
}

- (void)backButtonClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
}

@end
