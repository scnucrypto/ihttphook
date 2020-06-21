//
//  URLProtocol.m
//  ihttphook
//
//  Created by 家敏黄 on 2020/6/20.
//  Copyright © 2020 家敏黄. All rights reserved.
//

#import "URLProtocol.h"
#import "HttpCurl.h"

@implementation URLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    return request;
}

- (void)startLoading{
    [[HttpCurl sharedInstance] doRequestWithprotocal:self];
}

- (void)stopLoading{
    
}

@end

