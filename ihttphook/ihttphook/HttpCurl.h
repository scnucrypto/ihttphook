//
//  HttpCurl.h
//  ihttphook
//
//  Created by 家敏黄 on 2020/6/20.
//  Copyright © 2020 家敏黄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <curl/curl.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpCurl : NSObject

+ (instancetype)sharedInstance;

- (void)doRequestWithprotocal:(NSURLProtocol *)protocol;

@end

NS_ASSUME_NONNULL_END
