//
//  JWMainViewModel.m
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWMainViewModel.h"
#import "JWMainCellModel.h"

static NSMutableDictionary *mainModelForCellClassDic;
Class JWMainModelForCellClassByModel(id model) {
    NSString *modelClassString = NSStringFromClass([model class]);
    Class cls = NSClassFromString(@"JWMainCollectionViewCell");
    @synchronized (mainModelForCellClassDic) {
        if (nil == mainModelForCellClassDic) {
            mainModelForCellClassDic = [NSMutableDictionary new];
            [mainModelForCellClassDic setObject:@"JWMainCollectionViewCell" forKey:@"JWMainCellModel"];
        }
    }
    NSString *classString = [mainModelForCellClassDic objectForKey:modelClassString];
    if (classString && classString.length) {
        cls = NSClassFromString(classString);
    }
    return cls;
}


@interface JWMainViewModel()<UIAlertViewDelegate>

@property (nonatomic , strong) NSMutableArray *numsArray;
@property (nonatomic , assign) NSInteger nextItemNum;
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) NSInteger secondCount;
@property (nonatomic , assign) BOOL isStageOne;

@end


@implementation JWMainViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.currentLevel = 1;
        self.difficulty = @1;
        @weakify(self);
        self.loadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self);
            [self getData];
            self.points = [NSString stringWithFormat:@"%ld",(self.currentLevel-1)*25];
            [self recordBestScore];
            self.points = self.points;
            return [RACSignal empty];
        }];
        
        self.tapCellCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath *indexPath) {
            @strongify(self);
            [self tapCellAtIndexPath:indexPath];
            return [RACSignal empty];
        }];
    }
    return self;
}

- (void)recordBestScore {
    NSString *score = [[NSUserDefaults standardUserDefaults] objectForKey:BestScore];
    if ([self.points integerValue] > [score integerValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.points forKey:BestScore];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)tapCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataArray.count) {
       JWMainCellModel *cellModel = self.dataArray[indexPath.row];
        NSInteger iconNum = [cellModel.titleString integerValue];
        
        if (!cellModel.isOpen) {
            if (self.nextItemNum == iconNum) {
                
                [self willChangeValueForKey:@"dataArray"];
                JWMainCellModel *cellModel = self.dataArray[indexPath.row];
                cellModel.isOpen = YES;
                [self didChangeValueForKey:@"dataArray"];
                
                if (self.nextItemNum == DefaultLines+self.currentLevel) {
                    if ((DefaultLines+self.currentLevel) == DefaultLines * DefaultLines) {
                        //gameover
                        if ([self.difficulty isEqual:@2]) {
                            [self.timer invalidate];
                            self.timer = nil;
                        }
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"congratulations" message:@"" delegate:self cancelButtonTitle:@"restart" otherButtonTitles:@"leaderboard", nil];
                        [alertView show];
                    }else{
                        self.currentLevel++;
                        [self.loadDataCommand execute:nil];
                    }
                }else{
                    self.nextItemNum++;
                }
                
            }else{
                if ([self.difficulty isEqual:@2]) {
                    [self.timer invalidate];
                    self.timer = nil;
                }
                
                [self willChangeValueForKey:@"dataArray"];
                for (JWMainCellModel *cellModel in  self.dataArray) {
                    cellModel.isOpen = YES;
                }
                [self didChangeValueForKey:@"dataArray"];
                
                [self recordBestScore];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"game over" message:@"" delegate:self cancelButtonTitle:@"restart" otherButtonTitles:@"leaderboard", nil];
                [alertView show];
                
            }
        }
        
    }
}
    
- (void)getData {
    
    [self willChangeValueForKey:@"dataArray"];
    self.nextItemNum = 1;
    [self.dataArray removeAllObjects];
    [self.numsArray removeAllObjects];
    NSInteger totalNums = DefaultLines+self.currentLevel;
    
    for (NSInteger i = 0; i < DefaultLines*DefaultLines; i++) {
        JWMainCellModel *cellModel = [JWMainCellModel new];
        cellModel.isOpen = NO;
        [self.dataArray addObject:cellModel];
    }
    
    do {
        NSInteger num = arc4random()%(DefaultLines*DefaultLines);
        NSNumber *rowNum = [NSNumber numberWithInteger:num];
        
        
        
        if (self.numsArray.count == 0) {
            [self.numsArray addObject:rowNum];
        }else{
            BOOL isHave = NO;
            for (NSNumber *number in self.numsArray) {
                if ([number isEqual:rowNum]) {
                    isHave = YES;
                    break;
                }
            }
            if (!isHave) {
                [self.numsArray addObject:rowNum];
            }
        }
    } while (self.numsArray.count < totalNums);
    
    for (NSInteger j = 0; j < self.numsArray.count; j ++) {
        NSNumber *indexNum = self.numsArray[j];
        JWMainCellModel *cellModel = self.dataArray[[indexNum integerValue]];
        cellModel.titleString = [NSString stringWithFormat:@"%ld",j+1];
        cellModel.isOpen = YES;
        
    }
    [self didChangeValueForKey:@"dataArray"];
    
    self.isStageOne = YES;
    [self startTimer];
}

- (void)startTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.secondCount = self.numsArray.count-1;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)countDown {
    if (self.secondCount == 0) {
        if (self.isStageOne) {
            [self.timer invalidate];
            self.timer = nil;
            [self closeAllItems];
            self.secondTime = @"GO!";
            
            if ([self.difficulty isEqual:@2]) {
                self.isStageOne = NO;
                [self performSelector:@selector(startTimer) withObject:nil afterDelay:1];
            }
            
        }else{
            [self.timer invalidate];
            self.timer = nil;
            
            [self willChangeValueForKey:@"dataArray"];
            for (JWMainCellModel *cellModel in  self.dataArray) {
                cellModel.isOpen = YES;
            }
            [self didChangeValueForKey:@"dataArray"];
            
            [self recordBestScore];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"time out" message:@"" delegate:self cancelButtonTitle:@"restart" otherButtonTitles:@"leaderboard", nil];
            [alertView show];
        }
        
    }else{
        self.secondTime = [NSString stringWithFormat:@"%ld",self.secondCount];
        self.secondCount -- ;
    }
}

- (void)invidTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)closeAllItems {
    [self willChangeValueForKey:@"dataArray"];
    for (JWMainCellModel *cellModel in self.dataArray) {
        cellModel.isOpen = NO;
    }
    [self didChangeValueForKey:@"dataArray"];
}


- (NSMutableArray *)numsArray {
    if (!_numsArray) {
        _numsArray = [NSMutableArray array];
    }
    return _numsArray;
}
    
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
    
- (NSArray<NSString *> *)cellNamesArray {
    return @[@"JWMainCollectionViewCell"];
}
    
- (NSInteger)itemCount {
    return self.dataArray.count;
}
- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.row) {
        id model = [self modelForCellAtIndexPath:indexPath];
        if (nil != model) {
            return JWMainModelForCellClassByModel(model);
        }
    }
    return NSClassFromString(@"JWMainCollectionViewCell");
}
- (id )modelForCellAtIndexPath:(NSIndexPath *)indexPath {
    id model = nil;
    if (self.dataArray.count > indexPath.row) {
        model = [self.dataArray objectAtIndex:indexPath.row];
    }
    return model;

}
    
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = [self classForCellAtIndexPath:indexPath];
    NSString *classNameString = NSStringFromClass(cls);
    if ([classNameString isEqualToString:@"JWMainCollectionViewCell"]) {
        return CGSizeMake((Screen_Width-30)/DefaultLines,(Screen_Width-30)/DefaultLines);
    }
    return CGSizeZero;
}
    
    
    
#pragma mark - 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //reStart
        self.currentLevel = 1;
        [self.loadDataCommand execute:nil];
    }else{
        //
        [self.routeToRankingList execute:nil];
    }
}
@end
