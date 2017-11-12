//
//  JWDifficultyViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/11/12.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWDifficultyViewController.h"

@interface JWDifficultyViewController ()

@property (nonatomic , copy) chooseDifficulty chooseHandle;
@property (nonatomic , strong) UIButton *simpleBtn;
@property (nonatomic , strong) UIButton *hardBtn;

@end

@implementation JWDifficultyViewController

- (instancetype)initWithDifficulty:(chooseDifficulty)chooseDiff {
    if (self = [super init]) {
        self.chooseHandle = chooseDiff;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupUI {
    [self.view addSubview:self.simpleBtn];
    
    [self.simpleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(RatioPoint(200));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(100), 44));
    }];
    
    [self.view addSubview:self.hardBtn];
    
    [self.hardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.simpleBtn.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(100), 44));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)simpleBtn {
    if (!_simpleBtn) {
        _simpleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_simpleBtn setTitle:@"Simple" forState:UIControlStateNormal];
        _simpleBtn.backgroundColor = UIColorFromRGB(0xF8F8F8);
        _simpleBtn.layer.cornerRadius = 8;
         [_simpleBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _simpleBtn.layer.borderColor = UIColorFromRGB(0xBBBBBB).CGColor;
        _simpleBtn.layer.borderWidth = 0.5f;
        
        @weakify(self);
        [_simpleBtn bk_whenTapped:^{
            @strongify(self);
            if (self.chooseHandle) {
                self.chooseHandle(JWDifficultySimple);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    return _simpleBtn;
}

- (UIButton *)hardBtn {
    if (!_hardBtn) {
        _hardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hardBtn setTitle:@"Hard" forState:UIControlStateNormal];
        _hardBtn.backgroundColor = UIColorFromRGB(0xF8F8F8);
        [_hardBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _hardBtn.layer.cornerRadius = 8;
        _hardBtn.layer.borderColor = UIColorFromRGB(0xBBBBBB).CGColor;
        _hardBtn.layer.borderWidth = 0.5f;
        @weakify(self);
        [_hardBtn bk_whenTapped:^{
            @strongify(self);
            if (self.chooseHandle) {
                self.chooseHandle(JWDifficultyDifficult);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    return _hardBtn;
}


@end
