//
//  MyWebViewController.h
//  webViewDemo
//
//  Created by Shane on 18/4/2.
//  Copyright (c) 2018年 Shane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "WebViewJavascriptBridge.h"
#import "SDWebImageManager.h"
#import "imageInfo.h"
#import "videoInfo.h"
#import "SDImageCache.h"

@interface MyWebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign) BOOL isLoadLocalHtml;

@end
