//
//  JWRankingListViewModel.m
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRankingListViewModel.h"
#import "JWRankingModel.h"
#import "JWLoginTipModel.h"

@interface JWRankingListViewModel()

@end

@implementation JWRankingListViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        @weakify(self);
        self.loadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self loadRankingData];
            return [RACSignal empty];
        }];
    }
    return self;
}

- (void)loadRankingData {
    [ProgressHUD show];
    
    [self.dataArray removeAllObjects];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:UserId];
    if (!userId && userId.length==0) {
        JWLoginTipModel *model = [[JWLoginTipModel alloc] init];
        [self.dataArray addObject:model];
    }
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"GameUser"];
    [bquery orderByDescending:@"bestScore"];
    [bquery orderByAscending:@"updatedAt"];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        for (BmobObject *obj in array) {
            JWRankingModel *model = [[JWRankingModel alloc] init];
            model.nickName = [obj objectForKey:@"nickName"];
            model.bestScore = [NSString stringWithFormat:@"%@",[obj objectForKey:@"bestScore"]];
            [self.dataArray addObject:model];
        }
        
        [self checkError:array];
        
    }];

}

- (void)checkError:(NSArray *)array {
    if (array.count) {
        self.loadError = @(NO);
    }else{
        self.loadError = @(YES);
    }
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSArray *)cellNamesArray {
    if (!_cellNamesArray) {
        _cellNamesArray = @[@"JWRankingTableViewCell",
                            @"JWLoginTipTableViewCell"];
    }
    return _cellNamesArray;
}

- (NSInteger)numberOfRows {
    return self.dataArray.count;
}
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = [self cellClassAtIndexPath:indexPath];
    if ([NSStringFromClass(cls) isEqualToString:@"JWLoginTipTableViewCell"]) {
        return 45;
    }else if ([NSStringFromClass(cls) isEqualToString:@"JWRankingTableViewCell"]){
        return 50;
    }
    return 0;
}
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self objectAtIndexPath:indexPath];
    if ([model isKindOfClass:[JWLoginTipModel class]]) {
        return NSClassFromString(@"JWLoginTipTableViewCell");
    }else if ([model isKindOfClass:[JWRankingModel class]]) {
        return NSClassFromString(@"JWRankingTableViewCell");
    }
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataArray objectAtIndex:indexPath.row];
}

@end
