//
//  MyWebViewController.m
//  webViewDemo
//
//  Created by Shane on 18/4/2.
//  Copyright (c) 2018年 Shane. All rights reserved.
//

#import "MyWebViewController.h"
#import "YYModel.h"

@interface MyWebViewController () <UIWebViewDelegate>

@property (nonatomic, copy)NSString *detailID;
@property (nonatomic, copy)NSMutableString *requestUrlString;
@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)WebViewJavascriptBridge *bridge;

@property (weak, nonatomic) IBOutlet UILabel *loadTimeLabel;
@property (nonatomic, assign) NSTimeInterval startTime;

@end

@implementation MyWebViewController

- (void)dealloc {
    //1、加载空页面
    [[SDWebImageManager sharedManager] cancelAll];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    self.webView.delegate = nil;
    self.webView = nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"detail";
    self.loadTimeLabel.text = @"开始加载";
    
    [self initWebView];
    if (self.isLoadLocalHtml) {
        [self initJSbirdge];
        [self setupLocalRequest];
    } else {
        [self setupRemoteRequest];
    }
}

- (void)initWebView {
  self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
  _webView.opaque = NO;
  _webView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.95];
  [self.view addSubview:_webView];
    
    [self.view bringSubviewToFront:self.loadTimeLabel];
}

- (void)initJSbirdge {
  
  [WebViewJavascriptBridge enableLogging];
  
  _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"ObjC received message from JS: %@", data);
    responseCallback(@"Response for message from ObjC");
  }];
  
  [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
    NSLog(@"testObjcCallback called: %@", data);
    responseCallback(@"Response from testObjcCallback");
  }];
}

- (void)setupLocalRequest {
  self.detailID = @"AQ72N9QG00051CA1";//一张图片
  self.detailID = @"AQ4RPLHG00964LQ9";//多张图片
//    self.detailID = @"DG7REO410001875P";//最新
  NSMutableString *urlStr = [NSMutableString stringWithString:@"http://c.m.163.com/nc/article/xukunhenwuliao/full.html"];
  [urlStr replaceOccurrencesOfString:@"xukunhenwuliao" withString:_detailID options:NSCaseInsensitiveSearch range:[urlStr rangeOfString:@"xukunhenwuliao"]];
    
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"html.json" ofType:nil]];
   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
     [self setupWebViewByData:dictionary];
    
//  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//  [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//    [self setupWebViewByData:responseObject];
//    
//  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//    NSLog(@"error == %@",error);
//    
//  }];
}

- (void)setupRemoteRequest {
    NSURL *url = [NSURL URLWithString:@"https://c.m.163.com/news/a/AQ4RPLHG00964LQ9.html?fromhistory=1"];
    self.startTime = CACurrentMediaTime();
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setupWebViewByData:(id)data {
  
  if (data!= nil) {
    
    //解析的字典
    NSDictionary *dic = (NSMutableDictionary *)data;
    NSDictionary *bodyDic = [dic objectForKey:_detailID];
    NSMutableString *bodyStr = [[NSMutableString alloc] initWithString:[bodyDic objectForKey:@"body"]];
    
    //写一段接收主标题的html字符串,直接拼接到字符串
    NSMutableString *titleStr= [bodyDic objectForKey:@"title"];
    NSMutableString *sourceStr = [bodyDic objectForKey:@"source"];
    NSMutableString *ptimeStr = [bodyDic objectForKey:@"ptime"];
    
    NSMutableString *allTitleStr =[NSMutableString stringWithString:@"<style type='text/css'> p.thicker{font-weight: 900}p.light{font-weight: 0}p{font-size: 108%}h2 {font-size: 120%}h3 {font-size: 80%}</style> <h2 class = 'thicker'>xukun</h2><h3>hehe    lala</h3>"];
    
    [allTitleStr replaceOccurrencesOfString:@"xukun" withString:titleStr options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"xukun"]];
    [allTitleStr replaceOccurrencesOfString:@"hehe" withString:sourceStr options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"hehe"]];
    [allTitleStr replaceOccurrencesOfString:@"lala" withString:ptimeStr options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"lala"]];
    
    NSArray *imageArray = [bodyDic objectForKey:@"img"];
    NSArray *videoArray = [bodyDic objectForKey:@"video"];
    if ([videoArray count]) {
      NSLog(@"这个新闻里面有视频或者音频---");
      NSMutableArray *videos = [NSMutableArray arrayWithCapacity:[videoArray count]];
      for (NSDictionary *videoDic in videoArray) {
        videoInfo *videoin = [[videoInfo alloc] initWithInfo:videoDic];
        [videos addObject:videoin];
        NSRange range = [bodyStr rangeOfString:videoin.ref];
        NSString *videoStr = [NSString stringWithFormat:@"<embed height='50' width='280' src='%@' />",videoin.url_mp4];
        [bodyStr replaceOccurrencesOfString:videoin.ref withString:videoStr options:NSCaseInsensitiveSearch range:range];
      }
      
    }
    if ([imageArray count]==0) {
      NSLog(@"新闻没图片");
      NSString * str5 = [allTitleStr stringByAppendingString:bodyStr];
        self.startTime = CACurrentMediaTime();
      [_webView loadHTMLString:str5 baseURL:[[NSURL URLWithString:_requestUrlString] baseURL]];
      
    }else{
      
      NSLog(@"新闻内容里面有图片");
      
      NSMutableArray *images = [NSMutableArray arrayWithCapacity:[imageArray count]];
      
      for (NSDictionary *d in imageArray) {
        
        imageInfo *info = [[imageInfo alloc] initWithInfo:d];//kvc
        [images addObject:info];
        NSRange range = [bodyStr rangeOfString:info.ref];
        NSArray *wh = [info.pixel componentsSeparatedByString:@"*"];
        CGFloat width = [[wh objectAtIndex:0] floatValue];
        
        CGFloat rate = (self.view.bounds.size.width-15)/ width;
        CGFloat height = [[wh objectAtIndex:1] floatValue];
        CGFloat newWidth = width * rate;
        CGFloat newHeight = height *rate;
        
        NSString *imageStr = [NSString stringWithFormat:@"<img src = 'loading' id = '%@' width = '%.0f' height = '%.0f' hspace='0.0' vspace='5'>",[self replaceUrlSpecialString:info.src],newWidth,newHeight];
        [bodyStr replaceOccurrencesOfString:info.ref withString:imageStr options:NSCaseInsensitiveSearch range:range];
      }
      [self getImageFromDownloaderOrDiskByImageUrlArray:imageArray];
      
      [bodyStr replaceOccurrencesOfString:@"<p>　　" withString:@"<p>" options:NSCaseInsensitiveSearch range:[bodyStr rangeOfString:@"<p>　　"]];
      
      NSString * str5 = [allTitleStr stringByAppendingString:bodyStr];
      
      NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"webViewHtml" ofType:@"html"];
      NSMutableString* appHtml = [NSMutableString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
      
      NSRange range = [appHtml rangeOfString:@"<p>mainnews</p>"];
      
      [appHtml replaceOccurrencesOfString:@"<p>mainnews</p>" withString:str5 options:NSCaseInsensitiveSearch range:range];
      NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
        self.startTime = CACurrentMediaTime();
      [_webView loadHTMLString:appHtml baseURL:baseURL];
      
    }
  }
}


- (void)getImageFromDownloaderOrDiskByImageUrlArray:(NSArray *)imageArray {
  
  SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    __weak typeof(self) weakSelf = self;
  [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
    url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
    NSString *str = [weakSelf replaceUrlSpecialString:[url absoluteString]];
    return str;
  }];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"];
  
  for (NSDictionary *d in imageArray) {
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[imageArray count]];
    imageInfo *info = [[imageInfo alloc] initWithInfo:d];//kvc
    [images addObject:info];
    NSURL *imageUrl = [NSURL URLWithString:info.src];
    if ([imageManager diskImageExistsForURL:imageUrl]) {
      NSString *cacheKey = [imageManager cacheKeyForURL:imageUrl];
        
      NSString *imagePaths = [NSString stringWithFormat:@"%@/%@",filePath,[imageManager.imageCache cachedFileNameForKey:cacheKey]];
      NSLog(@"imagePaths === %@",imagePaths);
      
      [_bridge send:[NSString stringWithFormat:@"replaceimage%@,%@",[self replaceUrlSpecialString:info.src],imagePaths]];
      
    }else {
      [imageManager downloadImageWithURL:imageUrl options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
      } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        
        if (image && finished) {//如果下载成功
          
          NSString *cacheKey = [imageManager cacheKeyForURL:imageUrl];
          NSString *imagePaths = [NSString stringWithFormat:@"%@/%@",filePath,[imageManager.imageCache cachedFileNameForKey:cacheKey]];
          NSLog(@"imagePaths === %@",imagePaths);
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_bridge send:[NSString stringWithFormat:@"replaceimage%@,%@",[weakSelf replaceUrlSpecialString:info.src],imagePaths]];
          });
          
        }else {
          
        }
        
      }];
      
    }
    
  }
}

- (NSString *)replaceUrlSpecialString:(NSString *)string {
  
  return [string stringByReplacingOccurrencesOfString:@"/"withString:@"_"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSTimeInterval endTime = CACurrentMediaTime();
    
    self.loadTimeLabel.text = [[NSString alloc] initWithFormat:@"加载时间：%fs",endTime - self.startTime];
}


@end
