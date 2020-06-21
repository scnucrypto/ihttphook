//
//  HttpCurl.m
//  ihttphook
//
//  Created by 家敏黄 on 2020/6/20.
//  Copyright © 2020 家敏黄. All rights reserved.
//

#import "HttpCurl.h"
#import <curl/curl.h>

size_t write_callback(void *buffer, size_t size, size_t nmemb, void *userp){
    NSMutableData *res_data = (__bridge NSMutableData *)(userp);
    NSData *data = [[NSData alloc] initWithBytes:buffer length:nmemb * size];
    [res_data appendData:data];
    return size * nmemb;
}

size_t header_callback(char *buffer, size_t size,
                              size_t nitems, void *userdata){
    NSMutableDictionary *fields = (__bridge NSMutableDictionary *)(userdata);
    NSString *line = [[NSString alloc] initWithBytes:buffer length:nitems * size encoding:NSASCIIStringEncoding];
    if(![line hasPrefix:@"HTTP/"]){
        line = [line componentsSeparatedByString:@"\r\n"][0];
        if([line length] > 0){
            NSArray *items = [line componentsSeparatedByString:@": "];
            fields[items[0]] = items[1];
        }
    }
    return size * nitems;
}

size_t read_callback(void *ptr, size_t size, size_t nmemb, void *userdata){
    NSInputStream *stream = (__bridge NSInputStream *)(userdata);
    size_t len = 0;
    len += [stream read:(void *)ptr maxLength: size * nmemb];
    return len;
}

@implementation HttpCurl

+ (id)sharedInstance {
    static HttpCurl *sharedInstance;
    static dispatch_once_t curlOnce;
    dispatch_once(&curlOnce, ^{
        sharedInstance=[[HttpCurl alloc] init];
    });
    return sharedInstance;
}

- (void)doRequestWithprotocal:(NSURLProtocol *)protocol{
    CURL *_curl = curl_easy_init();
//    curl_easy_setopt(_curl, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2_0);
    curl_easy_setopt(_curl, CURLOPT_SSLVERSION, CURL_SSLVERSION_DEFAULT);
    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_easy_setopt(_curl, CURLOPT_SSL_VERIFYHOST, FALSE);
    /* enable TCP keep-alive for this transfer */
    curl_easy_setopt(_curl, CURLOPT_TCP_KEEPALIVE, 1L);
    /* keep-alive idle time to 120 seconds */
    curl_easy_setopt(_curl, CURLOPT_TCP_KEEPIDLE, 120L);
    /* interval time between keep-alive probes: 60 seconds */
    curl_easy_setopt(_curl, CURLOPT_TCP_KEEPINTVL, 60L);
    /* enable all supported built-in compressions */
    curl_easy_setopt(_curl, CURLOPT_ACCEPT_ENCODING, "gzip, deflate");
    NSMutableURLRequest *request = [[protocol request] mutableCopy];
    NSString *url_str = [[request URL] absoluteString];
    NSMutableDictionary *res_header = [[NSMutableDictionary alloc] init];
    NSMutableData *res_data = [[NSMutableData alloc] init];
    const char *str = [url_str cStringUsingEncoding:NSASCIIStringEncoding];
    curl_easy_setopt(_curl, CURLOPT_URL, str);
    curl_easy_setopt(_curl, CURLOPT_CUSTOMREQUEST, [[request HTTPMethod] cStringUsingEncoding:NSASCIIStringEncoding]);
    struct curl_slist *list = NULL;
    list = curl_slist_append(list, "Expect:");
    NSDictionary *headers = [request allHTTPHeaderFields];
    if (headers && headers.count > 0) {
        for(NSString *key in headers){
            NSString *value = [headers objectForKey:key];
            NSString *format_str = [NSString stringWithFormat:@"%@: %@", key, value];
            const char *format_chars = [format_str UTF8String];
            list = curl_slist_append(list, format_chars);
        }
        curl_easy_setopt(_curl, CURLOPT_HTTPHEADER, list);
    }
    NSInputStream *stream = request.HTTPBodyStream;
    if (stream) {
        curl_easy_setopt(_curl, CURLOPT_UPLOAD, 1L);
        curl_easy_setopt(_curl, CURLOPT_INFILESIZE_LARGE,
                         (curl_off_t)([[headers objectForKey:@"Content-Length"] intValue]));
        [stream open];
        curl_easy_setopt(_curl, CURLOPT_READFUNCTION, read_callback);
        curl_easy_setopt(_curl, CURLOPT_READDATA, (__bridge void *)stream);
    }
    
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, (__bridge void *)res_data);
    curl_easy_setopt(_curl, CURLOPT_HEADERFUNCTION, header_callback);
    curl_easy_setopt(_curl, CURLOPT_HEADERDATA, (__bridge void *)res_header);
    CURLcode result = curl_easy_perform(_curl);
    if (list){
        curl_slist_free_all(list);
    }
    if (stream) {
        [stream close];
    }
    if (result == CURLE_OK) {
        long http_code, http_ver;
        curl_easy_getinfo(_curl, CURLINFO_RESPONSE_CODE, &http_code);
        curl_easy_getinfo(_curl, CURLINFO_HTTP_VERSION, &http_ver); // HTTP protocol
        NSString *http_ver_s, *http_h=@"";
        if(http_ver == CURL_HTTP_VERSION_1_0) {
            http_ver_s = @"HTTP/1.0";
            http_h = @"HTTP/1.0";
        }
        if(http_ver == CURL_HTTP_VERSION_1_1) {
            http_ver_s = @"HTTP/1.1";
            http_h = @"HTTP/1.1";
        }
        if(http_ver == CURL_HTTP_VERSION_2_0) {
            http_ver_s = @"HTTP/2";
            http_h = @"HTTP/2";
        }
        NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:protocol.request.URL statusCode:http_code HTTPVersion:http_ver_s headerFields:res_header];
        [protocol.client URLProtocol:protocol
                  didReceiveResponse:res
                  cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [protocol.client URLProtocol:protocol didLoadData:res_data];
         ;
        [protocol.client URLProtocolDidFinishLoading:protocol];
    }
    else{
        NSLog(@"error code: %d", result);
    }
    curl_easy_cleanup(_curl);
}


@end
