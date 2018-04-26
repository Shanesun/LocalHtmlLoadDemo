//
//  ContainViewController.m
//  webViewDemo
//
//  Created by Shane on 2018/4/25.
//  Copyright © 2018年 xukun. All rights reserved.
//

#import "ContainViewController.h"
#import "MyWebViewController.h"

@interface ContainViewController ()

@end

@implementation ContainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyWebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webvc"];
    webVC.isLoadLocalHtml = self.isLoadLocalHtml;
    
    [self addChildViewController:webVC];
    
    webVC.view.frame = self.view.bounds;
    [self.view addSubview:webVC.view];
}

- (void)createLocalHtmlView {
    ;
    MyWebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"webvc"];
    webVC.isLoadLocalHtml = self.isLoadLocalHtml;
    
    [self addChildViewController:webVC];
    
    webVC.view.frame = self.view.bounds;
    [self.view addSubview:webVC.view];
    
}

- (void)createRemoveHtmlView {
    MyWebViewController *webVC = [MyWebViewController new];
                    [self addChildViewController:webVC];
    
    webVC.view.frame = self.view.bounds;
    [self.view addSubview:webVC.view];
}

@end
