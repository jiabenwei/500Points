//
//  JWRankingListViewModel.h
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWRankingListViewModel : NSObject

@property (nonatomic , strong) NSArray *cellNamesArray;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) RACCommand *loadDataCommand;
@property (nonatomic , strong) RACCommand *loginCommand;

@property (nonatomic , strong) NSNumber *loadError;

- (NSInteger)numberOfRows;
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
