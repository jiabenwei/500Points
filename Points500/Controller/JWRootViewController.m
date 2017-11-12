//
//  JWRootViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/24.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRootViewController.h"

@interface JWRootViewController ()

@property (nonatomic , strong) UIView *bigCircleView;
@property (nonatomic , strong) UIView *smallCircleView;


@end

@implementation JWRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    [self.view addSubview:self.bigCircleView];
    [self.view addSubview:self.smallCircleView];
    
    
}

- (UIView *)bigCircleView {
    if (!_bigCircleView) {
        _bigCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*Screen_Width-80, 2*Screen_Width-80)];
        _bigCircleView.center = CGPointMake(0, 0);
        _bigCircleView.backgroundColor = UIColorFromRGB(0xBBBBBB);
        _bigCircleView.clipsToBounds = YES;
        _bigCircleView.alpha = 0.3;
        _bigCircleView.layer.cornerRadius = (2*Screen_Width-80)/2;
        
    }
    return _bigCircleView;
}

- (UIView *)smallCircleView {
    if (!_smallCircleView) {
        _smallCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Width)];
        _smallCircleView.center = CGPointMake(Screen_Width-80, RatioPoint(200));
        _smallCircleView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        _smallCircleView.clipsToBounds = YES;
        _smallCircleView.alpha = 0.5;
        _smallCircleView.layer.cornerRadius = Screen_Width/2;
        
    }
    return _smallCircleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
