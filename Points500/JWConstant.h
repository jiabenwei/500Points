//
//  JWConstant.h
//  Points500
//
//  Created by jiabenwei on 2017/10/23.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define Screen_Width  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define Screen_height MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define RatioPoint(value)  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)/375*value
#define DefaultLines  5

#define BestScore              @"bestScore"
#define UserId                 @"userId"
#define HasOpened              @"hasOpened"
