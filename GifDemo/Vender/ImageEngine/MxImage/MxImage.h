//
//  MxImage.h
//  MicroMessenger
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//
#ifndef  DEF_JAKERONG_MXIMAGE_H
#define DEF_JAKERONG_MXIMAGE_H
#import <UIKit/UIKit.h>

#define MX_IOS_SYSTEM


#define IPL_DEPTH_SIGN 0x80000000

#define IPL_DEPTH_1U     1
#define IPL_DEPTH_8U     8
#define IPL_DEPTH_16U   16
#define IPL_DEPTH_32F   32

#define IPL_DEPTH_8S  (IPL_DEPTH_SIGN| 8)
#define IPL_DEPTH_16S (IPL_DEPTH_SIGN|16)
#define IPL_DEPTH_32S (IPL_DEPTH_SIGN|32)

#define IPL_DATA_ORDER_PIXEL  0
#define IPL_DATA_ORDER_PLANE  1

#define IPL_ORIGIN_TL 0
#define IPL_ORIGIN_BL 1

typedef struct _MxPoint
{
    int x;
    int y;
}
MxPoint;

MxPoint mxPoint(int x,int y);

enum { THRESH_BINARY=0, THRESH_BINARY_INV=1, THRESH_TRUNC=2, THRESH_TOZERO=3,
    THRESH_TOZERO_INV=4, THRESH_MASK=7, THRESH_OTSU=8 };

typedef unsigned char uchar;

typedef struct _MxImage
{
    int  nSize;             /* sizeof(MxImage) */
    int  nChannels;         /* support 1,2,3 or 4 channels */

    int  depth;             /* Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S,
                             IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported.  */
    int  origin;            /* 0 - top-left origin,
                             1 - bottom-left origin (Windows bitmaps style).  */
    int  align;             /* Alignment of image rows (4 or 8). */
    int  width;             /* Image width in pixels.                           */
    int  height;            /* Image height in pixels.                          */
    int  imageSize;         /* Image data size in bytes
                             (==image->height*image->widthStep */
    uchar *imageData;        /* Pointer to aligned image data.         */
    int  widthStep;         /* Size of aligned image row in bytes.    */
    
    uchar *imageDataOrigin;  /* Pointer to very origin of image data
                             (not necessarily aligned) -
                             needed for correct deallocation */
    int releaseData;        /* 0 - dont free data 
                               1 - free data when release */
}
MxImage;

// create
MxImage* mxCreateImage(int width,int height,int channels);
void mxReleaseImage(MxImage* image);

// color
void mxConvertRGBA2Gray(MxImage* src,MxImage* dst);

// data
void mxZero(MxImage* dst);
void mxNot(MxImage* src,MxImage* dst);
void mxCopy(MxImage* src,MxImage* dst);
void mxThreshold( MxImage* src, MxImage* dst, uchar thresh, uchar maxval, int type );

#ifdef MX_IOS_SYSTEM
// UIImage convertion
MxImage* MxImageFromUIImage(UIImage* image); // 需要使用SAFE_RELEASE_MXIMAGE释放
UIImage* UIImageFromMxImage(MxImage *image);
UIImage* UIImageFromMxImageEx(MxImage *image,CGFloat scale);
CGImageRef ImageRefMaskFromMxImage(MxImage* image);
#endif

#define SAFE_RELEASE_MXIMAGE(x) if(x){mxReleaseImage(x);x = NULL;}

#endif
