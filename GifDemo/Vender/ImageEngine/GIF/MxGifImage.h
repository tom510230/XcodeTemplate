//
//  MxGifImage.h
//  giftest
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//
#ifndef  DEF_JAKERONG_MXGIFIMAGE_H
#define DEF_JAKERONG_MXGIFIMAGE_H

#include "GifCore.h"
#include "MxImage.h"

class MxGifImage {
    GifDecoder* m_gif;
    int m_flag;
    MxImage* m_img;
    MxImage* m_bak;
    int m_lastDisposal;
	GifExtInfo m_extinfo;
    int m_id;
    GifFrameRect m_lastRect;
    unsigned long m_lastTimeTick;
private:
    int getFrame();
    void fillImage(MxImage* bmp, const GifFrame & frame, int transcolor);
    void releaseDecode();
public:
    ~MxGifImage();
    MxGifImage();
    
    ///////////////// 

    bool loadFromBufferNoCopy(uchar* buffer,int len);
    bool isSingleFrameImage();
    void flashFrameIgnoreTick();
    void seedToEnd();
    void flashFrameWithInnerTick();
    void flashFrame(unsigned long timetick);
    int duration();
    MxImage* image();
    int frameID();
    int width();
    int height();
};

#ifdef MX_IOS_SYSTEM
MxGifImage* createMxGifImageWithNSData(NSData* data);
#endif

#endif
