//
//  HTTPRequest.m
//  WikiSearch
//
//  Created by Sandhya on 18/08/18.
//  Copyright © 2017 Sandhya. All rights reserved.
//

#import "HTTPRequest.h"

@implementation HTTPRequest
{
    NSMutableData * responseData;
    NSString *reqType;
}

-(void)initRequestWithRequestData:(NSString *)urlString withEntityType:(NSString *)entityType
{
    reqType = entityType;
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    NSURL * url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3*60];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session = [self backgroundSession];
    
    NSCachedURLResponse* cachedMenuResponse = [session.configuration.URLCache cachedResponseForRequest:urlRequest];
    if (cachedMenuResponse)
    {
        responseData = [NSMutableData dataWithData:[cachedMenuResponse data]];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        if (response)
        {
//            NSLog(@"response = %@", response);
            [_delegate responseData:response withReqType:reqType];
        }
    }
    else
    {
        NSURLSessionTask *task = [session dataTaskWithRequest:urlRequest];
        [task resume];
    }
    

}

- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration  backgroundSessionConfigurationWithIdentifier:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
        configuration.URLCache = [NSURLCache sharedURLCache];
        configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}


#pragma mark - NSURLSession Delegate Methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSLog(@"%s",__func__);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    
    responseData=nil;
    responseData=[[NSMutableData alloc] init];
    [responseData setLength:0];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@ failed: %@", task.originalRequest.URL, error);
    }

    if (responseData) {
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        if (response)
        {
            NSLog(@"response = %@", response);
            [_delegate responseData:response withReqType:reqType];
            
        }
        else
        {
            NSLog(@"responseData = %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        }
        
    } else {
        NSLog(@"responseData is nil");
    }
}
@end
