//
//  videoInfo.h
//  webViewDemo
//
//  Created by Shane on 18/4/2.
//  Copyright (c) 2018年 Shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface videoInfo : NSObject

- (id)initWithInfo:(NSDictionary *)dic;

@property (nonatomic,retain)NSString *url_mp4;

@property(nonatomic,retain)NSString *ref;
@end
