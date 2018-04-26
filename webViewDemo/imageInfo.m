//
//  imageInfo.m
//  webViewDemo
//
//  Created by Shane on 18/4/2.
//  Copyright (c) 2018年 Shane. All rights reserved.
//

#import "ImageInfo.h"

@implementation imageInfo

- (id)initWithInfo:(NSDictionary *)dic
{
    if (self) {
        [self setValuesForKeysWithDictionary:dic];//kvc
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
