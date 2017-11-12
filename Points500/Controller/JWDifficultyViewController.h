//
//  JWDifficultyViewController.h
//  Points500
//
//  Created by jiabenwei on 2017/11/12.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "JWRootViewController.h"

typedef NS_ENUM(NSUInteger,JWDifficulty){
    JWDifficultySimple,
    JWDifficultyDifficult,
};

typedef void(^chooseDifficulty)(JWDifficulty difficulty);

@interface JWDifficultyViewController : JWRootViewController


- (instancetype)initWithDifficulty:(chooseDifficulty)chooseDiff;

@end
