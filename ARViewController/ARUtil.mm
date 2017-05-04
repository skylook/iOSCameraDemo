#import "ARUtil.h"

@implementation UIImage (Convert)

+ (UIImage*) imageFromRawGrayData:(uint8_t*)grayData WIDTH:(NSUInteger)nWidth HEIGHT:(NSUInteger)nHeight
{
    //CGImageRef image = self.CGImage;
    NSUInteger width = nWidth;//宽度
    NSUInteger height = nHeight;//长度
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,
                                                              grayData,
                                                              width*height,
                                                              NULL);
    //
    int bitsPerComponent = 8;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGBitmapInfo bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        8,
                                        width,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        NO,
                                        renderingIntent);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    return newImage;
}

- (uint8_t*) createRawGrayDataFromUIImage:(int&)nWidth HEIGHT:(int&)nHeight
{
    CGImageRef image = [self CGImage];
    
    CGSize rawImageSize;
    
    rawImageSize.width = CGImageGetWidth(image);
    rawImageSize.height = CGImageGetHeight(image);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    uint8_t *rawData = new uint8_t[((int)rawImageSize.width * (int)rawImageSize.height)];
    CGContextRef context = CGBitmapContextCreate(rawData, rawImageSize.width, rawImageSize.height, 8, rawImageSize.width, colorSpace, kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, rawImageSize.width, rawImageSize.height), image);
    CGContextRelease(context);
    
    nWidth = rawImageSize.width;
    nHeight = rawImageSize.height;
    
    return rawData;
    
}

+ (UIImage*) imageFromRawBGRAData:(uint8_t*)buffer WIDTH:(NSUInteger)width HEIGHT:(NSUInteger)height
{
    size_t bufferLength = width * height * 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = 4 * width;
    
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
    //BGRA -> RGBA
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little|kCGImageAlphaFirst;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
	CGImageRef iref = CGImageCreate(width,
                                    height,
                                    bitsPerComponent,
                                    bitsPerPixel,
                                    bytesPerRow,
                                    colorSpaceRef,
                                    bitmapInfo,
                                    provider,	// data provider
                                    NULL,		// decode
                                    YES,			// should interpolate
                                    renderingIntent);
    
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);
		return nil;
	}
    
	CGContextRef context = CGBitmapContextCreate(pixels,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpaceRef,
                                                 kCGImageAlphaPremultipliedLast);
    
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
    
	UIImage *image = nil;
	if(context) {
        
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        image = [UIImage imageWithCGImage:imageRef];
        
		CGImageRelease(imageRef);
		CGContextRelease(context);
	}
    
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
    
	if(pixels) {
		free(pixels);
	}
	return image;
}

+ (UIImage*)addRenderImage:(UIImage*)image toBG:(UIImage*)bg
{
    UIGraphicsBeginImageContext(image.size);
    
    [bg drawInRect:CGRectMake(0, 0, bg.size.width, bg.size.height)];
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resImage;
}

@end

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

@implementation UIImage (Rotate)

- (UIImage *)rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            // would get you an exact copy of the original
            return nil;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            // orientation value supplied is invalid
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(ctxt, rect, imag);
    copy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return copy;
}
@end

@implementation UIImage (Resize)
- (UIImage*)imageWithImage:(UIImage*)image scaledToScale:(CGFloat)scale
{
    UIGraphicsBeginImageContextWithOptions(self.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
