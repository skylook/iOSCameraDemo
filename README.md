# iOSCameraDemo
This is a simple demo of ios camera, it can be used as a basic project for CV, AR etc.
# Usage
Video frame is feed back in frameReady function, you can add your processing code in it:
```objective-c
-(void)frameReady:(BGRAVideoFrame)frame
{
    //TODO: Your code is here ...
    
    
    // Set frame here. You can also use aVCaptureVideoPreviewLayer as viewDidLoad instead
    UIImage *frameImage = [UIImage imageFromRawBGRAData:frame.data WIDTH:frame.width HEIGHT:frame.height];
    _showImage = [frameImage rotate:UIImageOrientationRight];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_videoView setImage:_showImage];
        
    });
    
}
```

The BGRAVideoFrame is defined as follows:
```objective-c
struct BGRAVideoFrame
{
    size_t width;
    size_t height;
    size_t stride;
    
    unsigned char * data;
};
```
