//
//  BGRAFrame.h
//  AROpenSDK
//
//  Created by valiantliu on 9/8/16.
//  Copyright © 2016 jamyding. All rights reserved.
//

#ifndef BGRAFrame_h
#define BGRAFrame_h

struct BGRAVideoFrame
{
    size_t width;
    size_t height;
    size_t stride;
    
    unsigned char * data;
};

struct GrayVideoFrame
{
    size_t width;
    size_t height;
//    size_t stride;
    
    unsigned char * data;
};

#endif /* BGRAFrame_h */
