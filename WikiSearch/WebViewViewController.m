//
//  WebViewViewController.m
//  WikiSearch
//
//  Created by Sandhya on 18/08/18.
//  Copyright © 2018 Sandhya. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController () <UIWebViewDelegate>
{
    UIActivityIndicatorView * activityindicator;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [_webView setDelegate:self];
    
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [webView setDelegate:self];

    NSString *urlAddress = _URL;
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    
    [self.view addSubview:webView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [activityindicator stopAnimating];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    activityindicator = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityindicator.center=self.view.center;
    [activityindicator startAnimating];
    [self.view addSubview:activityindicator];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
