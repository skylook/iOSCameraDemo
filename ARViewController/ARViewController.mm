//
//  ARViewController.m
//  QARDemo
//
//  Created by valiantliu on 25/04/2017.
//  Copyright © 2017 Tencent Inc. All rights reserved.
//

#import "ARViewController.h"
#import "VideoSource.h"

@interface ARViewController () <VideoSourceDelegate>
{
    
}

@property (strong, nonatomic) VideoSource *videoSource;
@property (strong, nonatomic) UIImageView *videoView;
@property (strong, nonatomic) UIImage *showImage;
@end

@implementation ARViewController

@synthesize videoSource = _videoSource;
@synthesize videoView = _videoView;
@synthesize showImage = _showImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.navigationController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    }
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start camera
    _videoSource = [[VideoSource alloc] init];
    _videoSource.delegate = self;
    
    [_videoSource createDeviceWithPosition:AVCaptureDevicePositionBack];
    
    [_videoSource startCamera];
    
    CGRect bound = self.view.frame;
    
    CGSize frameSize = [_videoSource getFrameSize];
    CGRect viewBounds = [self getVideoViewBounds:frameSize bound:bound];
    
    // Initialize the view for the video frame display.
    _videoView = [[UIImageView alloc] initWithFrame:viewBounds];
    [self.view addSubview:_videoView];
    
    [self focus];
    
 }

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Close Camera
    [_videoSource stopCamera];
    [_videoSource releaseDevice];
    
    _videoSource = nil;
}

#pragma mark - VideoSourceDelegate
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    // Close camera
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGRect)getVideoViewBounds:(CGSize)frameSize bound:(CGRect)bound
{
    // Get the current device's view size and initialize the video view to a right size.
    float viewWidth = bound.size.width;
    float viewHeight = bound.size.height;
    
    float sx = frameSize.height/viewWidth;
    float sy = frameSize.width/viewHeight;
    
    float s = sx < sy ? sx : sy;
    
    float displayScale  = s;
    
    float displayWidth = frameSize.height / s;
    float displayHeight = frameSize.width / s;
    
    float offsetX = (viewWidth - displayWidth) / 2.0;
    float offsetY = (viewHeight - displayHeight) / 2.0;
    
    //    float offsetX = 0.0;
    //    float offsetY = 0.0;
    
    CGRect viewBounds;
    viewBounds.origin.x = bound.origin.x + offsetX;
    viewBounds.origin.y = bound.origin.y + offsetY;
    viewBounds.size.width = displayWidth;
    viewBounds.size.height = displayHeight;
    
    return viewBounds;
}

- (void)focus
{
    [self needFocus];
}

- (void)needFocus
{
    [_videoSource startFocus];
}

- (void)lockFocus
{
    [_videoSource lockFocus];
}
@end
