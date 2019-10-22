//
//  Vimeo.m
//  Theatre
//
//  Created by Daniel Ran Lehmann on 1/10/17.
//  Copyright © 2017 Daniel Ran Lehmann. All rights reserved.
//

#import "Vimeo.h"
#import "AFNetworking.h"
#import "UIImage+AFNetworking.h"

@implementation Vimeo

+ (void)loadVideoWithURL:(NSURL *)videoURL completionHandler:(void (^)(NSURL *thumbnailURL, NSURL *parsedVideoURL, NSError *error))handler; {
    
    NSRange forwardSlashRange = [[videoURL absoluteString] rangeOfString:@"/" options:NSBackwardsSearch];
    if (forwardSlashRange.location != NSNotFound) {
        NSString *videoId = [[videoURL absoluteString] substringWithRange:NSMakeRange(forwardSlashRange.location + 1, [videoURL absoluteString].length - (forwardSlashRange.location + 1))];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:[NSString stringWithFormat:@"https://player.vimeo.com/video/%@/config", videoId] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
            if (responseObject) {
                
                NSURL *thumbnailUrl;
                NSURL *videoUrl;
                
                NSError *jsonError = nil;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:kNilOptions error:&jsonError];
                
                if (!jsonError) {
                    //handler(nil, nil, jsonError);
                }
                
                if ([[json allKeys] containsObject:@"request"]) {
                    NSArray *progressive = json[@"request"][@"files"][@"progressive"];
                    videoUrl = [NSURL URLWithString:[progressive lastObject][@"url"]];
                }
                
                if ([[json allKeys] containsObject:@"video"]) {
                    NSError *error;
                    
                    NSDictionary *thumbs = json[@"video"][@"thumbs"];
                    thumbnailUrl = [NSURL URLWithString:thumbs[@"960"]]; // not safe to call?
                    
                    if (error) {
                        //handler(nil, videoUrl, error);
                    }
                }
                
                handler(nil, videoUrl, nil);
                return;
            }
            
            //handler(nil, nil, nil);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            handler(nil, nil, error);
            return;
        }];
    }
    
    return handler(nil, nil, nil); // custom error like: id was not found?
    
}

@end
