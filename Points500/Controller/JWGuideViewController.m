//
//  JWGuideViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/31.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWGuideViewController.h"
#import "JWMainViewController.h"

@interface JWGuideViewController ()

@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic , strong) NSArray *imageSArray;
@property (nonatomic , strong) UILabel *tipLabel;
@property (nonatomic , strong) UIButton *startBtn;

@end

@implementation JWGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:HasOpened];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Do any additional setup after loading the view.
}

- (void)setupUI {
    @weakify(self);
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(RatioPoint(340), RatioPoint(340)));
    }];
    
    
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.imageView.mas_top).offset(-20);
    }];
    
    [self.view addSubview:self.startBtn];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-60);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    
    
    self.imageView.animationImages = self.imageSArray;
    self.imageView.animationDuration = 8;
    self.imageView.animationRepeatCount = 0;
    [self.imageView startAnimating];
    
    [[[self.startBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.startBtn.enabled = NO;
    }] subscribeNext:^(id x) {
        @strongify(self);
        self.startBtn.enabled = YES;
        [self jumpToGame];
    }];;
}

- (void)jumpToGame {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    JWMainViewController *mainVC = [[JWMainViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [window setRootViewController:navigationController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)imageSArray {
    if (!_imageSArray) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *imageNames = @[@"001",@"002",@"003",@"004",@"005",@"006",@"007",@"008"];
        for (NSString *string in imageNames) {
            [array addObject:[UIImage imageNamed:string]];
        }
        _imageSArray = [NSArray arrayWithArray:array];
    }
    return _imageSArray;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}


- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = UIColorFromRGB(0x222222);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"Click from 1 to 6";
        [_tipLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_tipLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tipLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setTitle:@"start game" forState:UIControlStateNormal];
        [_startBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _startBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _startBtn.layer.borderColor = UIColorFromRGB(0x555555).CGColor;
        _startBtn.layer.borderWidth = 0.5;
        _startBtn.layer.cornerRadius = 4;
        _startBtn.clipsToBounds = YES;
        [_startBtn setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    }
    return _startBtn;
}

@end
