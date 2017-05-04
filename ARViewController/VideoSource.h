/*****************************************************************************
 *   VideoSource.h
 *   Example_MarkerBasedAR
 ******************************************************************************
 *   by Khvedchenia Ievgen, 5th Dec 2012
 *   http://computer-vision-talks.com
 ******************************************************************************
 *   Ch2 of the book "Mastering OpenCV with Practical Computer Vision Projects"
 *   Copyright Packt Publishing 2012.
 *   http://www.packtpub.com/cool-projects-with-opencv/book
 *****************************************************************************/

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

////////////////////////////////////////////////////////////////////
// File includes:

#include "ARUtil.h"
//#include "QAR2PTAM/GeometryTypes.hpp"
//#include "QAR2PTAM/CameraCalibration.hpp"
#include "BGRAFrame.h"

#include <cstddef>

#define FRAME_640_480 1
//#define FRAME_1280_720 1

#ifdef FRAME_640_480
#define FRAME_WIDTH 640
#define FRAME_HEIGHT 480
#endif

#ifdef FRAME_1280_720
#define FRAME_WIDTH 1280
#define FRAME_HEIGHT 720
#endif
@protocol VideoSourceDelegate<NSObject>

-(void)frameReady:(BGRAVideoFrame) frame;

@end

@interface VideoSource : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
}

@property (nonatomic, strong) AVCaptureSession        * captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput    * deviceInput;
@property (nonatomic, strong) AVCaptureOutput         * videoOutput;
@property (nonatomic, strong) AVCaptureDevice         *videoDevice;
@property (nonatomic, weak) id<VideoSourceDelegate>   delegate;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* aVCaptureVideoPreviewLayer;

- (bool) createDeviceWithPosition:(AVCaptureDevicePosition)devicePosition;
- (void) releaseDevice;

-(AVCaptureVideoPreviewLayer*)getAVCaptureVideoPreviewLayer;
//- (CameraCalibration) getCalibration;
- (CGSize) getFrameSize;
/** Start the RGB camera */
- (void) startCamera;

/** Stop the RGB camera */
- (void) stopCamera;

- (bool)startFocus;
- (bool)lockFocus;
- (bool)setFrameRate:(AVCaptureVideoDataOutput *)captureOutput Max:(int)max Min:(int)min;

@end
