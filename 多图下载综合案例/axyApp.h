//
//  axyApp.h
//  多图下载综合案例
//
//  Created by Spencer on 2017/2/22.
//  Copyright © 2017年 Spencer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface axyApp : NSObject

@property (nonatomic,strong)NSString *name;

@property (nonatomic,strong)NSString *icon;

@property (nonatomic,strong)NSString *download;


+(instancetype)appWithDic:(NSDictionary*)dict;

@end
