//
//  axyApp.m
//  多图下载综合案例
//
//  Created by Spencer on 2017/2/22.
//  Copyright © 2017年 Spencer. All rights reserved.
//

#import "axyApp.h"

@implementation axyApp

+(instancetype)appWithDic:(NSDictionary*)dict;
{
    axyApp *appM=[[axyApp alloc]init];
//    appM.name=dict[@"name"];
//    appM.icon=dict[@"icon"];
//    appM.download=dict[@"download"];
    
    //KVC
    [appM setValuesForKeysWithDictionary:dict];
    
    return appM;
}


@end
