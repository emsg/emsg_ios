//
//  UploadFile.m
//  02.Post上传
//
//  Created by apple on 14-4-29.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UploadFile.h"
@implementation UploadFile
single_implementation(UploadFile)

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)uploadImage:(UIImage *)image
        resultBlock:(void (^)(NSDictionary *))block
         upProgress:(void (^)(float))progressBlock {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL
                                                    URLWithString:[NSString stringWithFormat:File_Host]]
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:15];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"multipart/form-data; boundary=hawk"
   forHTTPHeaderField:@"Content-Type"];
    if (image) {
        UIImage *myfile =
        [self imageCompressForSize:image targetSize:CGSizeMake(1280, 1280)];
        request.HTTPBody = [self dataImageWithParams:@{
                                                       @"file" : UIImageJPEGRepresentation(myfile, 0.3),
                                                       @"appid" : FILE_SERVER_APP_ID,
                                                       @"appkey" : FILE_SERVER_APP_KEY
                                                       }];
    }
    AFHTTPRequestOperation *requstOperation =
    [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requstOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [requstOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation
                                                     *operation,
                                                     id responseObject) {
        block(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
    }];
    
    [requstOperation
     setUploadProgressBlock:^(NSUInteger bytesWritten,
                              long long totalBytesWritten,
                              long long totalBytesExpectedToWrite) {
         //上传进度
         float progress =
         ((float)totalBytesWritten) / (totalBytesExpectedToWrite);
         progressBlock(progress);
         
     }];
    
    //  //下载进度回调
    //  [requstOperation
    //      setDownloadProgressBlock:^(NSUInteger bytesRead, long long
    //      totalBytesRead,
    //                                 long long totalBytesExpectedToRead) {
    //        //下载进度
    //        float progress = ((float)totalBytesRead) /
    //        (totalBytesExpectedToRead);
    //      }];
    [requstOperation start];
}
- (void)uploadAudio:(NSString *)dataStr block:(audioBlock)audio
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *voiceData = [fileManager contentsAtPath:dataStr];
    NSDictionary *parameters = @{@"appid":FILE_SERVER_APP_ID,@"appkey":FILE_SERVER_APP_KEY,@"file":voiceData,@"file_type":@"amr"};
    
    [manager POST:@"http://fileserver.qiuyouzone.com/fileserver/upload/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>formData) {
        NSURL *fileURL = [NSURL fileURLWithPath:dataStr];
        
        
        [formData appendPartWithFileURL:fileURL name:@"file" error:nil];
    } success:^(AFHTTPRequestOperation *  operation, id   responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        audio(result);
    } failure:^(AFHTTPRequestOperation *  operation, NSError *  error) {
        
    }];
    
}
#pragma mark 图片处理

- (UIImage *)imageCompressForSize:(UIImage *)sourceImage
                       targetSize:(CGSize)size {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width < 1280 && height < 1280) {
        return sourceImage;
    }
    CGFloat newSizeW;
    CGFloat newSizeH;
    if (width > height) {
        newSizeW = 1280;
        newSizeH = height * 1280 / width;
    } else {
        newSizeH = 1280;
        newSizeW = width * 1280 / height;
    }
    size = CGSizeMake(newSizeW, newSizeH);
    
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if (CGSizeEqualToSize(imageSize, size) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if (newImage == nil) {
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (NSData *)dataImageWithParams:(NSDictionary *)params {
    // 拼接请求体
    NSMutableData *data = [NSMutableData data];
    // 把参数添加到请求体里面面
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        //    id value = [dic allValues][0];
        //    NSString *key = [dic allKeys][0];
        if (![value isKindOfClass:[NSData class]]) {
            // 普通参数-username
            // 普通参数开始的一个标记
            [data appendData:[@"--hawk\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            // 参数描述
            NSString *keyString = [NSString
                                   stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n",
                                   key];
            [data appendData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
            // 参数值
            NSString *valueString = [NSString stringWithFormat:@"\r\n%@\r\n", value];
            [data appendData:[valueString dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            // 普通参数-username
            // 普通参数开始的一个标记
            [data appendData:[@"--hawk\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            // 参数描g述
            NSString *keyString = [NSString
                                   stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"; "
                                   @"filename=\"afile.png\"\r\n",
                                   key];
            [data appendData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[@"Content-Type:image/png\r\n"
                              dataUsingEncoding:NSUTF8StringEncoding]];
            
            // 参数值
            [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:value];
            [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    // 参数结束的标识
    [data appendData:[@"--hawk--" dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

@end
