//
//  JWRankingTableViewCell.m
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRankingTableViewCell.h"
#import "JWRankingModel.h"

@interface JWRankingTableViewCell()

@property (nonatomic , strong) UILabel *userNameLabel;
@property (nonatomic , strong) UILabel *scoreLabel;
@property (nonatomic , strong) UILabel *rankLabel;
@property (nonatomic , strong) UIView *line;
@end


@implementation JWRankingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setupUI {
    UIView *superView = self.contentView;
    [superView addSubview:self.rankLabel];
    [self.rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superView).offset(15);
        make.centerY.equalTo(superView.mas_centerY);
    }];
    
    [superView addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView).offset(-15);
        make.centerY.equalTo(superView);
    }];
    
    [superView addSubview:self.userNameLabel];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.rankLabel.mas_right).offset(30);
        make.centerY.equalTo(superView);
        make.right.equalTo(self.scoreLabel.mas_left).offset(-10);
    }];
    
    [superView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(superView);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)updataViewWithObject:(id)object {
    if ([object isKindOfClass:[JWRankingModel class]]) {
        JWRankingModel *model = (JWRankingModel *)object;
        NSString *rank = [NSString stringWithFormat:@"%ld",self.indexPath.row];
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:UserId];
        if (userId && userId.length) {
            rank = [NSString stringWithFormat:@"%ld",self.indexPath.row+1];
        }
        
        switch ([rank integerValue]) {
            case 1:
                self.rankLabel.textColor = [UIColor colorWithRed:0.97f green:0.19f blue:0.00f alpha:1.00f];
                break;
            case 2:
                self.rankLabel.textColor = [UIColor colorWithRed:0.85f green:0.59f blue:0.04f alpha:1.00f];
                break;
            case 3:
                self.rankLabel.textColor = [UIColor colorWithRed:0.00f green:0.38f blue:0.11f alpha:1.00f];
                break;
            default:
                self.rankLabel.textColor = UIColorFromRGB(0x555555);
                break;
        }
        
        
        self.rankLabel.text = rank;
        self.scoreLabel.text = model.bestScore;
        self.userNameLabel.text = model.nickName;
       
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)rankLabel {
    if (!_rankLabel) {
        _rankLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rankLabel.font = [UIFont boldSystemFontOfSize:22];
        [_rankLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_rankLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _rankLabel;

}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.font = [UIFont systemFontOfSize:14];
        _userNameLabel.textColor = UIColorFromRGB(0x222222);
        [_userNameLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [_userNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _userNameLabel;
}

- (UILabel *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _scoreLabel.font = [UIFont boldSystemFontOfSize:14];
        _scoreLabel.textColor = UIColorFromRGB(0x222222);
        [_scoreLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_scoreLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _scoreLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = UIColorFromRGB(0xBBBBBB);
    }
    return _line;
}

@end
