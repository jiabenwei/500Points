//
//  JWLoginTipTableViewCell.m
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWLoginTipTableViewCell.h"

@interface JWLoginTipTableViewCell()

@property (nonatomic , strong) UILabel *tipLabel;
@property (nonatomic , strong) UIView *lineView;
@property (nonatomic , strong) UIButton *loginBtn;

@end

@implementation JWLoginTipTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupUI {
    UIView *superView = self.contentView;
    [superView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView).offset(15);
        make.centerY.equalTo(superView);
    }];
    
    [superView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(60, 30));
        make.centerY.equalTo(superView);
    }];
    
    [superView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(superView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)updataViewWithObject:(id)object {
    [self.loginBtn bk_whenTapped:^{
        [self.viewModel.loginCommand execute:nil];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont boldSystemFontOfSize:14];
        _tipLabel.textColor = UIColorFromRGB(0x222222);
        _tipLabel.text = @"Login and then make the list";
        [_tipLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _tipLabel;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:UIColorFromRGB(0x555555) forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _loginBtn.layer.cornerRadius = 15;
        _loginBtn.layer.borderColor = UIColorFromRGB(0x555555).CGColor;
        _loginBtn.layer.borderWidth = 0.5f;
        _loginBtn.backgroundColor = UIColorFromRGB(0xffffff);
    }
    return _loginBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = UIColorFromRGB(0xBBBBBB);
    }
    return _lineView;
}

@end
