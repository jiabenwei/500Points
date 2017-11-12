//
//  JWRegisterViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/30.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRegisterViewController.h"

static const CGFloat ItemHeight = 38;

@interface JWRegisterViewController ()

@property (nonatomic , strong) UITextField *userNameTextField;
@property (nonatomic , strong) UITextField *passwordTextField;
@property (nonatomic , strong) UITextField *rePasswordTextField;

@property (nonatomic , strong) UIView *userNameBgView;
@property (nonatomic , strong) UIView *passwordBgView;
@property (nonatomic , strong) UIView *rePasswordBgView;

@property (nonatomic , strong) UIButton *registerBtn;
@property (nonatomic , strong) UILabel *tipLabel;


@end

@implementation JWRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Register";
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
    
    RACSignal *validRePassword = [self.rePasswordTextField.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        self.tipLabel.hidden = YES;
        return @([self isValidPassword:value]);
    }];
    
    RACSignal *registerActiveSignal = [RACSignal combineLatest:@[validUserName,validPassword,validRePassword] reduce:^id(NSNumber *userNameValid,NSNumber *passwordValid,NSNumber *rePasswordValid){
        return @([userNameValid boolValue] && [passwordValid boolValue] && [rePasswordValid boolValue]);
    }];
    [[registerActiveSignal map:^id(NSNumber *registerActive) {
        @strongify(self);
        self.registerBtn.enabled = [registerActive boolValue];
        return [registerActive boolValue] ? [UIColor colorWithRed:0.64f green:0.78f blue:0.22f alpha:1.00f] : [UIColor colorWithRed:0.64f green:0.64f blue:0.64f alpha:1.00f];
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        [self.registerBtn setBackgroundColor:color];
    }];
    
    [[[[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.registerBtn.enabled = NO;
        [self.view endEditing:YES];
        self.tipLabel.hidden = YES;
    }] flattenMap:^id(id value) {
        @strongify(self);
        return [self verifyUserNameAndPassword];
    }] subscribeNext:^(NSNumber *signedId) {
        @strongify(self);
        self.registerBtn.enabled = YES;
        if ([signedId isEqual:@0]) {
            //success
            [ProgressHUD showSuccess:@"login success"];
            [self createUserAndJumpBack];
        }else if([signedId isEqual:@1]){
            //findUser
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"invalid username";
            [ProgressHUD dismiss];
        }else{
            //the two passwords don't match
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"two passwords don't match";
            [ProgressHUD dismiss];
        }
    }];
    
}

- (void)createUserAndJumpBack {
    BmobObject *user = [BmobObject objectWithClassName:@"GameUser"];
    [user setObject:self.userNameTextField.text forKey:@"nickName"];
    [user setObject:self.passwordTextField.text forKey:@"password"];
    [user saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //back game
            [self getUserInfo:user];
            [self.backCommand execute:nil];
        }else{
            [ProgressHUD showError:@"register fails"];
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

- (RACSignal *)verifyUserNameAndPassword {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ProgressHUD show];
        if ([self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]) {
            BmobQuery   *bquery = [BmobQuery queryWithClassName:@"GameUser"];
            [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                BOOL isHaveUser = NO;
                for (BmobObject *obj in array) {
                    NSString *nickName = [obj objectForKey:@"nickName"];
                    if ([nickName isEqualToString:self.userNameTextField.text]) {
                        isHaveUser = YES;
                        break;
                    }
                }
                if (isHaveUser) {
                    //findUser
                    [subscriber sendNext:@(1)];
                    
                }else{
                    //nouser
                    [subscriber sendNext:@(0)];
                }
                 [subscriber sendCompleted];
                
            }];
        }else{
            //the two passwords don't match
            [subscriber sendNext:@(2)];
             [subscriber sendCompleted];
        }
        
        
        return nil;
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
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
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
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
    [superView addSubview:self.rePasswordBgView];
    [self.rePasswordBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordBgView.mas_bottom).offset(15);
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(40), ItemHeight));
    }];
    superView = self.rePasswordBgView;
    [superView addSubview:self.rePasswordTextField];
    [self.rePasswordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    
    superView = self.view;
    [superView addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rePasswordBgView.mas_bottom).offset(RatioPoint(80));
        make.size.equalTo(self.userNameBgView);
        make.centerX.equalTo(self.userNameBgView);
    }];
    
    [superView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rePasswordBgView.mas_bottom).offset(10);
        make.left.equalTo(superView).offset(RatioPoint(20));
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

- (UIView *)rePasswordBgView {
    if (!_rePasswordBgView) {
        _rePasswordBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _rePasswordBgView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _rePasswordBgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _rePasswordBgView.layer.borderWidth = 0.5;
        _rePasswordBgView.layer.cornerRadius = ItemHeight/2;
        _rePasswordBgView.clipsToBounds = YES;
    }
    return _rePasswordBgView;
    
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

- (UITextField *)rePasswordTextField {
    if (!_rePasswordTextField) {
        _rePasswordTextField= [[UITextField alloc] initWithFrame:CGRectZero];
        _rePasswordTextField.textColor = [UIColor blackColor];
        _rePasswordTextField.secureTextEntry = YES;
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:@"Please enter password again"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xBBBBBB) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _rePasswordTextField.attributedPlaceholder = attriStr;
    }
    return _rePasswordTextField;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"Register" forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _registerBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _registerBtn.layer.borderWidth = 0.5;
        _registerBtn.layer.cornerRadius = ItemHeight/2;
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


- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
