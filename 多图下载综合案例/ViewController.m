//
//  ViewController.m
//  多图下载综合案例
//
//  Created by Spencer on 2017/2/22.
//  Copyright © 2017年 Spencer. All rights reserved.
//

#import "ViewController.h"
#import "axyApp.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray *apps;
@property(nonatomic,strong) NSMutableDictionary *images;
@property(nonatomic ,strong) NSOperationQueue *queue;
@property(nonatomic ,strong) NSMutableDictionary *operations;

@end

@implementation ViewController


-(NSMutableDictionary *)operations
{
    if (_operations ==nil) {
        _operations=[NSMutableDictionary dictionary];
    }
    return  _operations;
}

-(NSOperationQueue *)queue
{
    if (_queue==nil) {
        _queue=[[NSOperationQueue alloc]init];
    }
    return _queue;
}

//懒加载字典

-(NSMutableDictionary *)images
{
    
    if (_images==nil) {
        _images=[NSMutableDictionary dictionary];
    }
    return _images;
}

//懒加载
-(NSArray *)apps
{
    if (_apps==nil) {
        //1.吧plist文件中的字典 加载到一个数组中（为字典数组）
        NSArray *arrDic=[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps" ofType:@"plist"]];
        
        //2字典数组转模型数组
            //2.1创建一个临时数组
        NSMutableArray *arrayMu=[NSMutableArray array];
            //2.2把字典从字典数组中遍历出来
        for (NSDictionary *dict in arrDic) {
            //2.3遍历出来的字典转成模型添加进临时数组
            [arrayMu addObject:[axyApp appWithDic:dict]];
        }
        //2.4把临时数组复制给 数组apps
        _apps=arrayMu;
        
    }
    return _apps;
   
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.apps.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置缓存池
    
    static NSString  *ID=@"app";
    //设置cell 去缓存池里取
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    //设置cell数据
       //拿到cell对应的数据
    axyApp *appM=self.apps[indexPath.row];
        //设置cell数据
       cell.textLabel.text=appM.name;
    cell.detailTextLabel.text=appM.download;
    
    
    //图片先从可变的字典里去取，如果存在直接用，否则去检查磁盘缓存
    //如果没有 1.没有下载过
    //2.重新打开程序，缓存被清空
    
    
    UIImage *image=[self.images objectForKey:appM.icon];
   
    if (image) {
        cell.imageView.image=image;
        NSLog(@"%zd-----------1",indexPath.row);
    }
    else
    {
        //获得Libray/caches 文件夹的地址
        NSString *caches=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        //获得图片的名称
        NSString *fileName=[appM.icon lastPathComponent];
        //拼接图片的全路径
        NSString *fullPath=[caches stringByAppendingPathComponent:fileName];
        //取得图片数据
        NSData *data=[NSData dataWithContentsOfFile:fullPath];
        if (data) {
            //直接用
            UIImage *image=[UIImage imageWithData:data];
            cell.imageView.image=image;
            [self.images setObject:image forKey:appM.icon];
             NSLog(@"%zd-----------",indexPath.row);
            
        }else{
            //先检查该图片是否正在下载，如果是那就什么都不做，否则在添加下载任务
            
            NSBlockOperation *download=[self.operations objectForKey:appM.icon];
            if (download) {
                
            }else
            {
                download=[NSBlockOperation blockOperationWithBlock:^{
                    NSURL *url=[NSURL URLWithString:appM.icon];
                    NSData *data=[NSData dataWithContentsOfURL:url];
                    UIImage *image=[UIImage imageWithData:data];
                    //                [NSThread sleepForTimeInterval:5.0];
                    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                        cell.imageView.image=image;
                        //刷新一行
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationLeft)];
                        NSLog(@"----------------------下载%@",[NSThread currentThread]);
                    }];
                    
                    //图片保存到字典
                    [self.images setObject:image forKey:appM.icon];
                    
                    //保存到沙河缓存
                    [data writeToFile:fullPath atomically:YES];
                    NSLog(@"----------------------%@",[NSThread currentThread]);
                }];
                
                [self.operations setObject:download forKey:appM.icon];
                
                [self.queue addOperation:download];
            }
        }
    }
    
    return cell;
}

//内存缓存————————》磁盘缓存

/*
 Documents:连接itunes时 会备份，不允许
 Libray：
    Preferen：偏好设置 保存账号
    caches：缓存文件
 Tmp：临时路径（随时会被删除）
 */

@end
