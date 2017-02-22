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

@end

@implementation ViewController

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
    
    
    //图片先从可变的字典里去取
    
    UIImage *image=[self.images objectForKey:appM.icon];
   
    if (image) {
        cell.imageView.image=image;
        NSLog(@"%zd-----------1",indexPath.row);
    }
    else
    {
        NSURL *url=[NSURL URLWithString:appM.icon];
        NSData *data=[NSData dataWithContentsOfURL:url];
        UIImage *image=[UIImage imageWithData:data];
        cell.imageView.image=image;
        //图片保存到字典
        [self.images setObject:image forKey:appM.icon];
        NSLog(@"%zd-----------",indexPath.row);
    }
    
    
    
    
    
    
    
//    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
//    
//    NSBlockOperation *downLoad=[NSBlockOperation blockOperationWithBlock:^{
//        NSURL *url=[NSURL URLWithString:appM.icon];
//        NSData *data=[NSData dataWithContentsOfURL:url];
//        UIImage *image=[UIImage imageWithData:data];
//        NSLog(@"down---------%@",[NSThread currentThread]);
//        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
//            cell.imageView.image=image;
//            NSLog(@"添加主线程---------%@",[NSThread currentThread]);
//        }];
//    }];
//    
//    [queue addOperation:downLoad];
//    [cell reloadInputViews];
    
    //返回cell
    return cell;
}


@end
