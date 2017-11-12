//
//  JWMainCollectionViewCell.h
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWMainViewModel.h"

@interface JWMainCollectionViewCell : UICollectionViewCell

@property (nonatomic , strong) NSIndexPath *indexPath;
@property (nonatomic , weak) JWMainViewModel *viewModel;

- (void)updataViewWithObject:(id)object;
    
@end
