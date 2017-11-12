//
//  JWView.m
//  Points500
//
//  Created by huoliquankai on 2017/11/10.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWView.h"
#import <WebKit/WebKit.h>

@interface JWView()
{
    WKWebView *_cview;
    NSString *_lpath;
}
@end

@implementation JWView

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _lpath = path;
        [self setContentView];
        [self home];
        [self back];
        [self forward];
        [self refresh];
    }
    return self;
}

- (void)setContentView {
    NSURL *url = [[NSURL alloc] initWithString:_lpath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _cview = [[WKWebView alloc] init];
    [self addSubview:_cview];
    _cview.frame = CGRectMake(0, 20, [[UIApplication sharedApplication] keyWindow].bounds.size.width, [[UIApplication sharedApplication] keyWindow].bounds.size.height - 60);
    [_cview loadRequest:request];
}

- (void)home {
    UIButton *btn = [[UIButton alloc] init];
    [self addSubview:btn];
    btn.frame = CGRectMake(0, [[UIApplication sharedApplication] keyWindow].bounds.size.height - 40, [[UIApplication sharedApplication] keyWindow].bounds.size.width/4, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitle:@"首页" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)homeAction {
    NSURL *url = [[NSURL alloc] initWithString:_lpath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_cview loadRequest:request];
}

- (void)back {
    UIButton *btn = [[UIButton alloc] init];
    [self addSubview:btn];
    btn.frame = CGRectMake([[UIApplication sharedApplication] keyWindow].bounds.size.width/4, [[UIApplication sharedApplication] keyWindow].bounds.size.height - 40, [[UIApplication sharedApplication] keyWindow].bounds.size.width/4, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitle:@"后退" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backAction {
    if ([_cview canGoBack]) {
        [_cview goBack];
    }
}

- (void)forward {
    UIButton *btn = [[UIButton alloc] init];
    [self addSubview:btn];
    btn.frame = CGRectMake([[UIApplication sharedApplication] keyWindow].bounds.size.width/2, [[UIApplication sharedApplication] keyWindow].bounds.size.height - 40, [[UIApplication sharedApplication] keyWindow].bounds.size.width/4, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitle:@"前进" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(forwardAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)forwardAction {
    if ([_cview canGoForward]) {
        [_cview goForward];
    }
}

- (void)refresh {
    UIButton *btn = [[UIButton alloc] init];
    [self addSubview:btn];
    btn.frame = CGRectMake([[UIApplication sharedApplication] keyWindow].bounds.size.width*3/4, [[UIApplication sharedApplication] keyWindow].bounds.size.height - 40, [[UIApplication sharedApplication] keyWindow].bounds.size.width/4, 40);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshAction {
    [_cview reload];
}

@end
