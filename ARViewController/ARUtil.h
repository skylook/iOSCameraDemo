//
//  UIImageExtend.h
//  MicroMessenger
//
//  Created by  kenbin on 11-12-30.
//  Copyright 2011 Tencent. All rights reserved.
//

#ifndef ARUTIL_H
#define ARUTIL_H

#import <UIKit/UIKit.h>

@interface UIImage (Convert)
+ (UIImage*) imageFromRawGrayData:(uint8_t*)grayData WIDTH:(NSUInteger)nWidth HEIGHT:(NSUInteger)nHeight;
+ (UIImage*) imageFromRawBGRAData:(uint8_t*)buffer WIDTH:(NSUInteger)width HEIGHT:(NSUInteger)height;
- (uint8_t*) createRawGrayDataFromUIImage:(int&)nWidth HEIGHT:(int&)nHeight;
+ (UIImage*)addRenderImage:(UIImage*)image toBG:(UIImage*)bg;
@end

@interface UIImage (Rotate)
- (UIImage*)rotate:(UIImageOrientation)orient;
@end

@interface UIImage (Resize)
- (UIImage*)imageWithImage:(UIImage*)image scaledToScale:(CGFloat)scale;
@end

#endif
