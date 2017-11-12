//
//  JWRankingListViewController.m
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRankingListViewController.h"
#import "JWRankingListViewModel.h"
#import "JWBasicTableViewCell.h"
#import "JWNormalLoginViewController.h"

@interface JWRankingListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) JWRankingListViewModel *viewModel;
@property (nonatomic , strong) UITableView *tableView;
@end

@implementation JWRankingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Leaderboard";
    self.viewModel = [[JWRankingListViewModel alloc] init];
    
    self.viewModel.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self routeToLoginVC];
        return [RACSignal empty];
    }];
    
    [self setupUI];
    [self bindingEvent];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:UserId];
    if (userId && userId.length) {
        [self pushBestScoreToService];
    }
    
    [self.viewModel.loadDataCommand execute:nil];
}

- (void)routeToLoginVC {
    JWNormalLoginViewController *loginViewController = [[JWNormalLoginViewController alloc] init];
    UINavigationController *navigationConroller = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:navigationConroller animated:YES completion:nil];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(64, 0, 0, 0));
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 44);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)bindingEvent {
    
    @weakify(self);
    [RACObserve(self.viewModel, loadError) subscribeNext:^(NSNumber *error) {
        @strongify(self);
        if ([error boolValue]) {
            [ProgressHUD showError:@"No rank" Interaction:YES];
        }else{
            [ProgressHUD dismiss];
        }
        [self.tableView reloadData];
    }];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        for (NSString *classString in self.viewModel.cellNamesArray) {
            [_tableView registerClass:NSClassFromString(classString) forCellReuseIdentifier:classString];
        }
    }
    return _tableView;
}

- (void)pushBestScoreToService {
    //search table GameScore
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"GameUser"];
    [bquery getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults] objectForKey:UserId] block:^(BmobObject *object,NSError *error){
        if (!error) {
            if (object) {
                NSString *best = [[NSUserDefaults standardUserDefaults] objectForKey:BestScore];
                [object setObject:[NSNumber numberWithInteger:[best integerValue]] forKey:BestScore];
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        [self.viewModel.loadDataCommand execute:nil];
                    } else {
                        
                    }
                }];
            }
        }else{
            
        }
    }];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = [self.viewModel cellClassAtIndexPath:indexPath];
    JWBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cls) forIndexPath:indexPath];
    if (!cell) {
        cell = [[cls alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(cls)];
    }
    
    cell.indexPath = indexPath;
    cell.viewModel = self.viewModel;
    
    [cell updataViewWithObject:[self.viewModel objectAtIndexPath:indexPath]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
}

@end
