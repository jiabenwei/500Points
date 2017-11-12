//
//  JWMainViewModel.h
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWMainViewModel : NSObject
@property (nonatomic , strong) NSArray<NSString *> *cellNamesArray;
@property (nonatomic , strong) NSMutableArray *dataArray;
    
@property (nonatomic , strong) RACCommand *loadDataCommand;
@property (nonatomic , strong) RACCommand *tapCellCommand;
@property (nonatomic , strong) RACCommand *routeToRankingList;

@property (nonatomic , strong) NSString *secondTime;
@property (nonatomic , strong) NSString *points;
@property (nonatomic , assign) NSInteger currentLevel;
@property (nonatomic , strong) NSNumber *difficulty;

- (void)invidTimer;
- (NSInteger)itemCount;
- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath;
- (id )modelForCellAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
    
@end
