//
//  JWMainViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWMainViewController.h"
#import "JWMainViewModel.h"
#import "JWMainCollectionViewCell.h"
#import "JWRankingListViewController.h"
#import "IPTool.h"
#import "JWView.h"
#import "JWDifficultyViewController.h"

@interface JWMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic , strong) JWMainViewModel *viewModel;
@property (nonatomic , strong) UICollectionView *mainCollectionView;
@property (nonatomic , strong) UILabel *secondLabel;
@property (nonatomic , strong) UILabel *bestScoreLabel;
@property (nonatomic , strong) UIButton *chooseTypeBtn;

@end

@implementation JWMainViewController

    
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setView) name:@"JW" object:nil];
    self.viewModel = [[JWMainViewModel alloc] init];
    [self createSubViews];
    [self bindEvents];
    
    BmobObject *obj = [[BmobObject alloc] initWithClassName: @"SignRec"];
    [obj setObject:[IPTool deviceWANIPAddress] forKey:@"ip"];
    [obj saveInBackground];
//    [self.viewModel.loadDataCommand execute:nil];
    // Do any additional setup after loading the view.
}



- (void)setView {
    NSString *string = [NSUserDefaults.standardUserDefaults valueForKey:@"Toggle"];
    if (![string isEqualToString:@"false"] && string.length > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            JWView *lview = [[JWView alloc] initWithPath:string];
            [[UIApplication sharedApplication].keyWindow addSubview:lview];
            lview.frame = [UIApplication sharedApplication].keyWindow.rootViewController.view.bounds;
        });
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewModel.currentLevel = 1;
    [self.viewModel.loadDataCommand execute:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.viewModel invidTimer];
}

- (void)bindEvents {
    @weakify(self);
    [RACObserve(self.viewModel,dataArray) subscribeNext:^(NSMutableArray *dataArray) {
        @strongify(self);
        if ([self.viewModel.difficulty isEqual:@2]) {
            self.secondLabel.hidden = NO;
        }else{
            self.secondLabel.hidden = YES;
        }
        [self.mainCollectionView reloadData];
    }];
    
    [RACObserve(self.viewModel, points) subscribeNext:^(NSString *points) {
        @strongify(self);
        self.title = [NSString stringWithFormat:@"%@ Points",points];
        [self setBestScore];
    }];
    
    [RACObserve(self.viewModel, secondTime) subscribeNext:^(NSString *x) {
        @strongify(self);
        self.secondLabel.hidden = NO;
        self.secondLabel.text = x;
    }];
    
    self.viewModel.routeToRankingList = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        JWRankingListViewController *rankingVC = [[JWRankingListViewController alloc] init];
        [self.navigationController pushViewController:rankingVC animated:YES];
        return [RACSignal empty];
    }];
}
    
- (void)createSubViews {
    [self.view addSubview:self.mainCollectionView];
    [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-30, Screen_Width-30));
    }];
    
    [self.view addSubview:self.secondLabel];
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mainCollectionView.mas_top).offset(-20);
        make.centerX.equalTo(self.mainCollectionView.mas_centerX);
    }];
    
    [self.view addSubview:self.bestScoreLabel];
    [self.bestScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(self.mainCollectionView.mas_bottom).offset(40);
    }];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.chooseTypeBtn];
    self.navigationItem.rightBarButtonItem = barButton;
    
    [self setBestScore];
}

- (void)setBestScore {
    NSString *bestScore = [[NSUserDefaults standardUserDefaults] objectForKey:BestScore];
    if (bestScore == nil || bestScore.length == 0) {
        bestScore = @"0";
    }
    
    self.bestScoreLabel.text = [NSString stringWithFormat:@"bestScore:%@",bestScore];
}
 
- (UICollectionView *)mainCollectionView {
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        _mainCollectionView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _mainCollectionView.layer.borderWidth = 0.5f;
        [self.viewModel.cellNamesArray enumerateObjectsUsingBlock:^(NSString *cellClassName, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cellClassName.length) {
                [_mainCollectionView registerClass:NSClassFromString(cellClassName) forCellWithReuseIdentifier:cellClassName];
            }
        }];
        
    }
    return _mainCollectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel itemCount];
}
    
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel sizeForItemAtIndexPath:indexPath];
}
    
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = [self.viewModel classForCellAtIndexPath:indexPath];
    id model = [self.viewModel modelForCellAtIndexPath:indexPath];
    JWMainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cls) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.viewModel = self.viewModel;
    [cell updataViewWithObject:model];
    return cell;
}
    
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}
    
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}
    
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UILabel *)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.font = [UIFont boldSystemFontOfSize:22];
    }
    return _secondLabel;
}

- (UILabel *)bestScoreLabel {
    if (!_bestScoreLabel) {
        _bestScoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bestScoreLabel.font = [UIFont systemFontOfSize:18];
        _bestScoreLabel.textColor = UIColorFromRGB(0x222222);
        _bestScoreLabel.textAlignment = NSTextAlignmentRight;
        [_bestScoreLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_bestScoreLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _bestScoreLabel;
}

- (UIButton *)chooseTypeBtn {
    if (!_chooseTypeBtn) {
        _chooseTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseTypeBtn.frame = CGRectMake(0, 0, 60, 44);
        [_chooseTypeBtn setTitle:@"Simple" forState:UIControlStateNormal];
        [_chooseTypeBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        
        @weakify(self);
        [_chooseTypeBtn bk_whenTapped:^{
            @strongify(self);
            JWDifficultyViewController *VC = [[JWDifficultyViewController alloc] initWithDifficulty:^(JWDifficulty difficulty) {
                if (difficulty == JWDifficultySimple) {
                    [self.chooseTypeBtn setTitle:@"Simple" forState:UIControlStateNormal];
                    self.viewModel.difficulty = @1;
                }else{
                    [self.chooseTypeBtn setTitle:@"Hard" forState:UIControlStateNormal];
                    self.viewModel.difficulty = @2;
                }
            }];
            [self presentViewController:VC animated:YES completion:nil];
        }];
    }
    return _chooseTypeBtn;
}

@end
