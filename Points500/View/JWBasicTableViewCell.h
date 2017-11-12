//
//  JWBasicTableViewCell.h
//  Points500
//
//  Created by jiabenwei on 2017/10/26.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWRankingListViewModel.h"

@interface JWBasicTableViewCell : UITableViewCell

@property (nonatomic , strong) NSIndexPath *indexPath;
@property (nonatomic , weak) JWRankingListViewModel *viewModel;

- (void)updataViewWithObject:(id)object;

@end
