//
//  JWMainCollectionViewCell.m
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWMainCollectionViewCell.h"
#import "JWMainCellModel.h"

@interface JWMainCollectionViewCell()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UILabel *titleLabel;
    
@end

@implementation JWMainCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.contentView.backgroundColor = [UIColor cyanColor];
        [self setupUI];
    }
    return self;
}
    
- (void)setupUI {
    UIView *superView =  self.contentView;
    [superView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    
    superView = self.bgView;
    [superView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
}
    
- (void)updataViewWithObject:(id)object {
    if ([object isKindOfClass:[JWMainCellModel class]]) {
        JWMainCellModel *cellModel = (JWMainCellModel *)object;
        self.titleLabel.text = cellModel.titleString;
        if (cellModel.titleString && cellModel.titleString.length) {
            self.bgView.userInteractionEnabled = YES;
            self.bgView.backgroundColor = [UIColor blackColor];
            if (cellModel.isOpen) {
                self.titleLabel.hidden = NO;
            }else{
                self.titleLabel.hidden = YES;
            }
            @weakify(self);
            [self.bgView bk_whenTapped:^{
                @strongify(self);
                [self.viewModel.tapCellCommand execute:self.indexPath];
            }];
        }else{
            self.bgView.backgroundColor = [UIColor whiteColor];
            self.bgView.userInteractionEnabled = NO;
        }
    }
}

    
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.layer.borderColor = [UIColor whiteColor].CGColor;
        _bgView.layer.borderWidth = 0.5f;
        _bgView.clipsToBounds = YES;
    }
    return _bgView;
}
    
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:25];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
