//
//  ViewController.m
//  test
//
//  Created by 家敏黄 on 2020/6/20.
//  Copyright © 2020 家敏黄. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipInputTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *protocolControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *methodControl;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UITextField *repeatInputField;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tap1.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap1];
}

- (IBAction)startTest:(id)sender {
    NSString *getUri = @"/get/1";
    NSString *postUri = @"/post";
    NSDictionary *postData = @{
        @"test": @"2"
    };
    NSString *server = [self.ipInputTextField text];
    NSInteger protocol = [self.protocolControl selectedSegmentIndex];
    NSInteger method = [self.methodControl selectedSegmentIndex];
    NSString *urlStr = @"";
    if (protocol == 0) {
        urlStr = [urlStr stringByAppendingString:@"http://"];
    }else{
        urlStr = [urlStr stringByAppendingString:@"https://"];
    }
    urlStr = [urlStr stringByAppendingString:server];
//    [self.outputTextView setText:@""];
    NSInteger repeatTimes = [[self.repeatInputField text] intValue];
    for (int i=0; i<repeatTimes; i++) {
        if (method == 0) {
            NSString *getUrlStr = [urlStr stringByAppendingString:getUri];
            [self get:getUrlStr];
        }else{
            NSString *postUrlStr = [urlStr stringByAppendingString:postUri];
            [self post:postUrlStr dataDict:postData];
        }
    }
}

-(void)viewTapped:(UITapGestureRecognizer*)tap1
{
    [self.view endEditing:YES];
}

- (void)get:(NSString *)strUrl{
    NSLog(@"get url: %@",strUrl);
    [self.outputTextView insertText:[NSString stringWithFormat:@"GET URL %@\n", strUrl]];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.outputTextView insertText:[NSString stringWithFormat:@"GET RES %@\n", dict]];
        });
    }];
    [dataTask resume];
}

- (void)post:(NSString *)urlStr dataDict:(NSDictionary *)dataDict{
    NSLog(@"post url: %@",urlStr);
    [self.outputTextView insertText:[NSString stringWithFormat:@"POST URL %@\n", urlStr]];
    [self.outputTextView insertText:[NSString stringWithFormat:@"POST DATA %@\n", dataDict]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type":@"application/json; charset=utf-8"};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         NSLog(@"%@",dict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.outputTextView insertText:[NSString stringWithFormat:@"POST RES %@\n", dict]];
        });
    }];
    [dataTask resume];
}

@end
