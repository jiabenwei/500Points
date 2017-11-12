//
//  IPTool.h
//  SSC
//
//  Created by huoliquankai on 2017/10/31.
//  Copyright © 2017年 wanli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPTool : NSObject
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (BOOL)isValidatIP:(NSString *)ipAddress;
+ (NSDictionary *)getIPAddresses;
+(NSString *)deviceWANIPAddress;
@end
