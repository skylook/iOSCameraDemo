/*****************************************************************************
 *   VideoSource.mm
 *   Example_MarkerBasedAR
 ******************************************************************************
 *   by Khvedchenia Ievgen, 5th Dec 2012
 *   http://computer-vision-talks.com
 ******************************************************************************
 *   Ch2 of the book "Mastering OpenCV with Practical Computer Vision Projects"
 *   Copyright Packt Publishing 2012.
 *   http://www.packtpub.com/cool-projects-with-opencv/book
 *****************************************************************************/

#import <ImageIO/ImageIO.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////
// File includes:
#import "VideoSource.h"

@implementation VideoSource

@synthesize captureSession;
@synthesize delegate;
@synthesize deviceInput;
@synthesize videoOutput;
@synthesize videoDevice;
@synthesize aVCaptureVideoPreviewLayer;

#pragma mark - Memory management

- (id)init
{
    if ((self = [super init]))
    {
        self.videoOutput = nil;
        self.deviceInput = nil;
        
        [self initSession];
        
    }
    return self;
}

- (void) initSession
{
    AVCaptureSession * capSession = [[AVCaptureSession alloc] init];
    
    
#ifdef FRAME_1280_720
    if ([capSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        [capSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
#endif
    
#ifdef FRAME_640_480
    if ([capSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        [capSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
#endif
    
    else if ([capSession canSetSessionPreset:AVCaptureSessionPresetLow])
    {
        [capSession setSessionPreset:AVCaptureSessionPresetLow];
    }
    
    self.captureSession = capSession;
    
    self.aVCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
}
-(AVCaptureVideoPreviewLayer*)getAVCaptureVideoPreviewLayer
{
    return self.aVCaptureVideoPreviewLayer;
}

- (void) releaseSession
{
    if (self.captureSession != nil)
    {
        [self.captureSession stopRunning];
        self.captureSession = nil;
    }
}

- (void) startCamera
{
    if (self.captureSession && [self.captureSession isRunning])
        return;
    
//    [self initSession];
    
    // Start streaming color images.
    [self.captureSession startRunning];
    
}

- (void) stopCamera
{
    if ([self.captureSession isRunning])
    {
        [self.captureSession stopRunning];
//        [self releaseSession];
    }
    else
    {
        return;
    }
}

//- (CameraCalibration) getCalibration
//{
//    // Returns calibratoin data for iPad 2
//    // Todo: Add parameters for the rest
//    return CameraCalibration(609.91552734375, 611.0323486328125, 313.80715942382813, 236.35139465332031);
//}

- (CGSize) getFrameSize
{
    /*
    if (![captureSession isRunning])
        NSLog(@"Capture session is not running, getFrameSize will return invalid valies");
    
    NSArray *ports = [deviceInput ports];
    AVCaptureInputPort *usePort = nil;
    for ( AVCaptureInputPort *port in ports )
    {
        if ( usePort == nil || [port.mediaType isEqualToString:AVMediaTypeVideo] )
        {
            usePort = port;
        }
    }
    
    if ( usePort == nil ) return CGSizeZero;
    
    CMFormatDescriptionRef format = [usePort formatDescription];
    CMVideoDimensions dim = CMVideoFormatDescriptionGetDimensions(format);
    
    CGSize cameraSize = CGSizeMake(dim.width, dim.height);
    
    return cameraSize;
    */
    
    return CGSizeMake(FRAME_WIDTH, FRAME_HEIGHT);
}

- (void)dealloc
{
    [self stopCamera];
    
    [self releaseDevice];
    
    [self releaseSession];
    
}

#pragma mark Capture Session Configuration

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            return device;
        }
    }
    return nil;
}

- (bool)setFrameRate:(AVCaptureVideoDataOutput *)captureOutput Max:(int)max Min:(int)min
{
    if (!self.videoDevice)
        return false;
    
    [self.videoDevice lockForConfiguration:nil];
    self.videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, min);
    self.videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, max);
    [self.videoDevice unlockForConfiguration];
    
    return true;
}

- (void) addRawViewOutput
{
    /*We setupt the output*/
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    /*While a frame is processes in -captureOutput:didOutputSampleBuffer:fromConnection: delegate methods no other frames are added in the queue.
     If you don't want this behaviour set the property to NO */
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    
    // Set frame rate : valiantliu
    [self setFrameRate:captureOutput Max:30 Min:20];
    
    /*We specify a minimum duration for each frame (play with this settings to avoid having too many frames waiting
     in the queue because it can cause memory issues). It is similar to the inverse of the maximum framerate.
     In this example we set a min frame duration of 1/10 seconds so a maximum framerate of 10fps. We say that
     we are not able to process more than 10 frames per second.*/
    //captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    /*We create a serial queue to handle the processing of our frames*/
    dispatch_queue_t queue = dispatch_queue_create("com.tencent.arCameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
//    dispatch_release(queue);
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    
    // Register an output
    if ([[self captureSession] canAddOutput:captureOutput])
    {
        [self.captureSession addOutput:captureOutput];
        self.videoOutput = captureOutput;
    }
    
}

- (void)removeRawViewOutput
{
//    for(AVCaptureOutput *output1 in self.captureSession.outputs) {
//        [self.captureSession removeOutput:output1];
//    }
    
    if (self.videoOutput != nil) {
        [self.captureSession removeOutput:self.videoOutput];
        self.videoOutput = nil;
    }
}

- (bool) createDeviceWithPosition:(AVCaptureDevicePosition)devicePosition
{
    self.videoDevice = [self cameraWithPosition:devicePosition];
    
    if (!self.videoDevice)
        return FALSE;
    {
        NSError *error;
        
        AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
        
        if (!error)
        {
            if ([[self captureSession] canAddInput:videoIn])
            {
                [[self captureSession] addInput:videoIn];
                self.deviceInput = videoIn;
            }
            else
            {
                NSLog(@"Couldn't add video input");
                return FALSE;
            }
        }
        else
        {
            NSLog(@"Couldn't create video input");
            return FALSE;
        }
        
        [self startFocus];
    }
    
    
    
    [self addRawViewOutput];
    [captureSession startRunning];
    
    return TRUE;
}

- (void)releaseDevice
{
    [self.captureSession stopRunning];
    
    [self removeRawViewOutput];
    
//    for(AVCaptureInput *input1 in self.captureSession.inputs) {
//        [self.captureSession removeInput:input1];
//    }
    
    if (self.deviceInput == nil) {
        [self.captureSession removeInput:self.deviceInput];
        self.deviceInput = nil;
    }

}

- (bool)forceFocus
{
    if (!self.videoDevice)
        return false;
    
    // Lock the camera Focus
    [self.videoDevice lockForConfiguration:nil];
    if([self.videoDevice isFocusPointOfInterestSupported])
    {
        
        CGPoint autofocusPoint = CGPointMake(0.5f, 0.5f);
        //[videoDevice setFocusMode:AVCaptureFocusModeLocked];
        [self.videoDevice setFocusPointOfInterest:autofocusPoint];
    }
    [self.videoDevice unlockForConfiguration];
    
    return true;
}

- (bool)forceFocus:(CGPoint)point
{
    if (!self.videoDevice)
        return false;
    
    // Lock the camera Focus
    [self.videoDevice lockForConfiguration:nil];
    if([self.videoDevice isFocusPointOfInterestSupported])
    {
        //[videoDevice setFocusMode:AVCaptureFocusModeLocked];
        [self.videoDevice setFocusPointOfInterest:point];
    }
    [self.videoDevice unlockForConfiguration];
    
    return true;
}

- (bool)startFocus
{
    if (!self.videoDevice)
        return false;

    // Added auto focus
    if ( [self.videoDevice lockForConfiguration:NULL] == YES && [self.videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        [self.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];

        if ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            self.videoDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        if ([self.videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            self.videoDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;

        
        [self.videoDevice unlockForConfiguration];
    }
    // Added continuous auto focus
    if ( [self.videoDevice lockForConfiguration:NULL] == YES && [videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        [self.videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        
        if(version>=7.0f)
        {
            if ([self.videoDevice isSmoothAutoFocusSupported])
            {
                [self.videoDevice setSmoothAutoFocusEnabled:YES];
            }
        }
        
        [self.videoDevice unlockForConfiguration];
    }
    
    // Added white balance and exposure
    if ( [self.videoDevice lockForConfiguration:NULL] == YES)
    {
        if ([self.videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            self.videoDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        if ([self.videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            self.videoDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        
        [self.videoDevice unlockForConfiguration];
    }
    
    [self forceFocus];
    
    return true;
}

- (bool)lockFocus
{
    if (!self.videoDevice)
        return false;
    
    // Lock the camera Focus
    [self.videoDevice lockForConfiguration:nil];
    if([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        [self.videoDevice setFocusMode:AVCaptureFocusModeLocked];
    [self.videoDevice unlockForConfiguration];
    
    return true;
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    /*Get information about the image*/
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t stride = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    BGRAVideoFrame frame = {width, height, stride, baseAddress};
    [delegate frameReady:frame];
    
    /*We unlock the  image buffer*/
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
} 

@end
