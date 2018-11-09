//
//  PDNetWorkTool.m
//  PDMediaPlayer
//
//  Created by 肖培德 on 16/2/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "PDNetWorkTool.h"
#define kBoundary @"boundary"

@implementation PDNetWorkTool

#pragma 上传多个文件 +多个参数
- (void)POSTFilesWithUrlString: (NSString *)urlString FileKey:(NSString *)fileKey fileDict:(NSDictionary *)fileDict parametersDict:(NSDictionary *)parametersDict success:(successBlock)success fause:(fauseBlock)fause {
    
    
    // 创建请求
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    // 告诉服务器,本次请求有上传文件信息
    NSString *type = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",kBoundary];
    
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    
    request.HTTPBody = [self setHTTPBodyWithFileKey:fileKey fileDict:fileDict parametersDict:parametersDict];
    
    // 发送请求
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        // 如果数据类型是 JSON 格式,将 JSOn 格式转化为 OC 数据,自动帮用户解析 JSON
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:NULL];
        // 如果是其他形式的二进制数据,则直接返回二进制数据;
        if (!obj) {
            obj = data;
        }
        // 成功回调
        if (data && !error) {
            success (obj,response);
        }else {
            fause (error);
            // 失败回调
        }

   }] resume];
    
    

    
    
}


- (NSData *)setHTTPBodyWithFileKey:(NSString *)fileKey fileDict:(NSDictionary *)fileDict parametersDict:(NSDictionary *)parametersDict {
    
    NSMutableData *data = [NSMutableData data];
    
    
    
    // 遍历文件字典
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *fileName = key;
        NSString *filePath = obj;
        
        // 上边界
        NSMutableString *headerStrM1 = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
        
        [headerStrM1 appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",@"userfile[]",fileName]];
        
        [headerStrM1 appendString:@"Content-Type: application/octet-stream\r\n\r\n"];
        
        [data appendData:[headerStrM1 dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 文件的数据内容
        NSData *Data = [NSData dataWithContentsOfFile:filePath];
        
        [data appendData:Data];
        
        
    }];
    
    
    
    //    -----------------------------259629344198513971958648984
    //    Content-Disposition: form-data; name="username"
    //
    //    Peter
    //    -----------------------------259629344198513971958648984
    //    Content-Disposition: form-data; name="password"
    //
    //    0427
    
    [parametersDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *parametersKey = key;
        
        NSString *parametersName = obj;
        
        NSMutableString *str = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
        [str appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",parametersKey];
        
        [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *str1 = parametersName;
        
        NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
        [data appendData:data1];
        
        
        
    }];
    
    // 普通参数
    //    -----------------------------6378085301557081533633602789
    //    Content-Disposition: form-data; name="username"
    //
    //    Peter
    
    
    
    
    // 下边界
    NSMutableString *footerStr = [NSMutableString stringWithFormat:@"\r\n--%@--",kBoundary];
    [data appendData:[footerStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    
    return data;
    
    
}

#pragma 上传单个文件

- (void)POSTFileWithUrlString:(NSString *)urlString FielPath:(NSString *)filePath fileKey:(NSString *)fileKey fileName:(NSString *)fileName success:(successBlock)success fause:(fauseBlock)fause {
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    NSString *type =[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary];
    
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self getHTTPBodyWithFilePath:filePath fileKey:fileKey fileName:fileName];

    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 如果数据类型是 JSON 格式,将 JSOn 格式转化为 OC 数据,自动帮用户解析 JSON
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:NULL];
        // 如果是其他形式的二进制数据,则直接返回二进制数据;
        if (!obj) {
            obj = data;
        }
        // 成功回调
        if (data && !error) {
            success (obj,response);
        }else {
            fause (error);
            // 失败回调
        }

        
    }] resume];
    


    
}


- (NSData *)getHTTPBodyWithFilePath:(NSString *)filePath fileKey:(NSString *)fileKey fileName:(NSString *)fileName {
    
    NSMutableData *data = [NSMutableData data];
    // 动态获取文件的类型
    NSURLResponse *response = [self getResponseWithFilePath:filePath];
    // 文件的上边界
    NSMutableString *headerStr = [NSMutableString stringWithFormat:@"\r\n--%@",kBoundary];
    [headerStr appendFormat:@"\r\nContent-Disposition: form-data; name=%@; filename=%@",fileKey,fileName];
    [headerStr appendFormat:@"\r\nContent-Type: %@\r\n\r\n",response.MIMEType];
    [data appendData:[headerStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 文件内容
    [data appendData:[NSData dataWithContentsOfFile:filePath]];
    
    
    // 文件的下边界
    
    NSString *footerStr = [NSString stringWithFormat:@"\r\n--%@--",kBoundary];
    [data appendData:[footerStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
    
}

#pragma 获取本地文件的相应头信息
// 获得本地文件的相应头信息,使用同步方法请求
- (NSURLResponse *)getResponseWithFilePath:(NSString *)filePath {
    //获得文件的本地路径 根据文件路径 生成 url,本地协议名称为 file://
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",filePath]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 为甚么要同步?
    
    NSURLResponse *response = nil;
    //NSURLSession 没有同步请求方法
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    
    return response;
}



#pragma
- (void)loadWebDataWithUrlString:(NSString *)urlString success:(successBlock)success fause:(fauseBlock)fause {
    
    // 百分号转译
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 如果数据类型是 JSON 格式,将 JSOn 格式转化为 OC 数据,自动帮用户解析 JSON
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:NULL];
        // 如果是其他形式的二进制数据,则直接返回二进制数据;
        if (!obj) {
           obj = data;
        }
       // 成功回调
        if (data && !error) {
            success (obj,response);
        }else {
            fause (error);
        // 失败回调
       }
    }] resume];
    
}

// GET 请求(附带参数)
- (void)GETDataWithUrlString:(NSString *)urlString parametersDict:(NSDictionary *)parametersDict success:(successBlock)success fause:(fauseBlock)fause {
    
    
    NSString *str = @"";
    
    if (parametersDict) {
        
        NSMutableString *String = [NSMutableString stringWithFormat:@"%@?",urlString];
        
        [parametersDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *parameterName = key;
            NSString *parameter = obj;
            
            [String appendFormat:@"%@=%@&",parameterName,parameter];
            
        }];
        
        // 去除最后一个 &
        str = [String substringToIndex:String.length - 1];
        
    }else{
        str = urlString;
    }
   
    
    NSURL *url = [NSURL URLWithString:str];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
//        NSLog(@"@@@@@$$$%@",[NSThread currentThread]);
        
        // 如果数据类型是 JSON 格式,将 JSOn 格式转化为 OC 数据,自动帮用户解析 JSON
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:NULL];
        // 如果是其他形式的二进制数据,则直接返回二进制数据;
        if (!obj) {
            obj = data;
        }
        // 成功回调
        if (data && !error) {
            success (obj,response);
        }else {
            fause (error);
            // 失败回调
        }
        
        
    }] resume];
    
}


- (id)getUserToken {
    
    
    NSString* devId = [[NSUserDefaults standardUserDefaults] objectForKey:@"cn.applock.colorv"];
    if(devId == nil)
    {
        devId = [SSKeychain passwordForService:@"cn.applock" account:@"colorv"];
        if(devId == nil)
        {
            devId = [[[NSString stringWithFormat:@"%@",[[NSUUID UUID] UUIDString]] stringByReplacingOccurrencesOfString:@"-" withString:@""] md5];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:devId forKey:@"cn.applock.colorv"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [SSKeychain setPassword:devId forService:@"cn.applock" account:@"colorv" error:nil];
    
    NSDictionary *dic = @{@"udid":devId};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *useToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    useToken = [useToken stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    
    
    return useToken;
}
// POST 请求 (附带参数)
- (void)POSTDataWithUrlString:(NSString *)urlString parametersDict:(NSDictionary *)parametersDict success:(successBlock)success fause:(fauseBlock)fause {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
//    [request setValue:[self getUserToken] forKey:@"utk"];
    [request setValue:[self getUserToken] forHTTPHeaderField:@"utk"];
    
    NSMutableString *string = [NSMutableString stringWithFormat:@"%@",@""];
    
    [parametersDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *parameterName = key;
        NSString *parameter = obj;
        
        [string appendFormat:@"&%@=%@",parameterName,parameter];
     
        
    }];
    
    // 去处第一个&
    
    NSString *str = [string substringFromIndex:1];
    NSData *bodyData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody =bodyData;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 如果数据类型是 JSON 格式,将 JSOn 格式转化为 OC 数据,自动帮用户解析 JSON
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0 error:NULL];
        // 如果是其他形式的二进制数据,则直接返回二进制数据;
        if (!obj) {
            obj = data;
        }
        // 成功回调
        if (data && !error) {
            success (obj,response);
        }else {
            fause (error);
            // 失败回调
        }
        
    
        
    }] resume];
    
    
    
    
}




#pragma 创建单例对象
+ (instancetype)shareNetWork{
    
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc]init];
        
        
    });
    
    return _instance;
}
@end
