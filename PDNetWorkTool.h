//
//  PDNetWorkTool.h
//  PDMediaPlayer
//
//  Created by 肖培德 on 16/2/16.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(id obj, NSURLResponse *response);
typedef void(^fauseBlock) (NSError *error);

@interface PDNetWorkTool : NSObject

+ (instancetype)shareNetWork;

- (void)loadWebDataWithUrlString:(NSString *)urlString success:(successBlock)success fause:(fauseBlock)fause;

// post上传多个文件 + 多个参数值
- (void)POSTFilesWithUrlString: (NSString *)urlString FileKey:(NSString *)fileKey fileDict:(NSDictionary *)fileDict parameterDict:(NSDictionary *)parameterDict success:(successBlock)success fause:(fauseBlock)fause;
// post上传单个文件
- (void)POSTFileWithUrlString:(NSString *)urlString FielPath:(NSString *)filePath fileKey:(NSString *)fileKey fileName:(NSString *)fileName success:(successBlock)success fause:(fauseBlock)fause;

// 动态获取本地文件的相应头信息
- (NSURLResponse *)getResponseWithFilePath:(NSString *)filePath;

// get请求(附带参数)
- (void)GETDataWithUrlString:(NSString *)urlString parametersDict:(NSDictionary *)parametersDict success:(successBlock)success fause:(fauseBlock)fause;

// POST 请求 (附带参数)
- (void)POSTDataWithUrlString:(NSString *)urlString parametersDict:(NSDictionary *)parametersDict success:(successBlock)success fause:(fauseBlock)fause;
@end
