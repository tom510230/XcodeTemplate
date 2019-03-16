//
//  MxImage.c
//  giftest
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//

#include "MxImage.h"

#define  CV_DESCALE(x,n)     (((x) + (1 << ((n)-1))) >> (n))

#define fix(x,n)      (int)((x)*(1 << (n)) + 0.5)
#define descale       CV_DESCALE

#define cscGr_32f  0.299f
#define cscGg_32f  0.587f
#define cscGb_32f  0.114f

/* BGR/RGB -> Gray */
#define csc_shift  14
#define cscGr  fix(cscGr_32f,csc_shift) 
#define cscGg  fix(cscGg_32f,csc_shift)
#define cscGb  /*fix(cscGb_32f,csc_shift)*/ ((1 << csc_shift) - cscGr - cscGg)

MxPoint mxPoint(int x,int y)
{
    MxPoint p;
    p.x = x;
    p.y = y;
    return p;
}

// initalize MxImage header, allocated by the user
MxImage* mxCreateImageEx(int width,int height, int depth,
                  int channels, int origin, int align )
{
    MxImage * image = (MxImage*)malloc(sizeof(MxImage));
    
    if(image==NULL)
    {
        return NULL;
    }
    
    memset( image, 0, sizeof( *image ));
    image->nSize = sizeof( *image );
    
    if( width < 0 || height < 0 )
    {
		free(image);
        return NULL;
    }    
    if(depth != (int)IPL_DEPTH_8U || channels < 1 )
    {
		free(image);
        return NULL;
    }
    if( origin != IPL_ORIGIN_TL && origin != IPL_ORIGIN_BL )
    {
		free(image);
        return NULL;
    }    
    if( align != 4 && align != 8 )
    {
		free(image);
        return NULL;
    }
    
    image->width = width;
    image->height = height;
    
    image->nChannels = channels;
    image->depth = depth;
    image->align = align;
    image->widthStep = (((image->width * image->nChannels *
                          (image->depth & ~IPL_DEPTH_SIGN) + 7)/8)+ align - 1) & (~(align - 1));
    image->origin = origin;
    image->imageSize = image->widthStep * image->height;
    
    image->imageDataOrigin = (uchar*)malloc(image->imageSize);
    if(image->imageDataOrigin==NULL)
    {
        free(image);
        return NULL;
    }
    image->releaseData = 1;
    image->imageData = image->imageDataOrigin;
    
    return image;
}

MxImage* mxCreateImage(int width,int height,int channels)
{
    return mxCreateImageEx(width,height, IPL_DEPTH_8U, channels, IPL_ORIGIN_TL, 4);
}


void mxReleaseImage(MxImage* image)
{
    if(image==NULL)return;
    if(image->releaseData)
    {
        free(image->imageDataOrigin);
    }
    image->imageDataOrigin = NULL;
    image->imageData = NULL;
    free(image);
}

void mxBGRx2Gray_8u_CnC1R( const uchar* src, int srcstep,
                          uchar* dst, int dststep, int width,int height,
                          int src_cn, int blue_idx )
{
    int i;
    srcstep -= width*src_cn;
    
    if( width*height >= 1024 )
    {
        int* tab = (int*)malloc( 256*3*sizeof(tab[0]) );
        int r = 0, g = 0, b = (1 << (csc_shift-1));
        
        for( i = 0; i < 256; i++ )
        {
            tab[i] = b;
            tab[i+256] = g;
            tab[i+512] = r;
            g += cscGg;
            if( !blue_idx )
                b += cscGb, r += cscGr;
            else
                b += cscGr, r += cscGb;
        }
        
        for( ; height--; src += srcstep, dst += dststep )
        {
            for( i = 0; i < width; i++, src += src_cn )
            {
                int t0 = tab[src[0]] + tab[src[1] + 256] + tab[src[2] + 512];
                dst[i] = (uchar)(t0 >> csc_shift);
            }
        }
        free(tab);
    }
    else
    {
        for( ; height--; src += srcstep, dst += dststep )
        {
            for( i = 0; i < width; i++, src += src_cn )
            {
                int t0 = src[blue_idx]*cscGb + src[1]*cscGg + src[blue_idx^2]*cscGr;
                dst[i] = (uchar)CV_DESCALE(t0, csc_shift);
            }
        }
    }
}

void mxConvertRGBA2Gray(MxImage* src,MxImage* dst)
{
    mxBGRx2Gray_8u_CnC1R(src->imageData, src->widthStep, dst->imageData, dst->widthStep, 
                         src->width, src->height, 4, 0);
}

void mxZero(MxImage* dst)
{
    memset(dst->imageData, 0, dst->imageSize);
}

void mxNot(MxImage* src,MxImage* dst)
{
    const uchar* sptr = src->imageData;
    uchar* dptr = dst->imageData;
    int width = src->widthStep;
    int height = src->height;
    for( ; height--; sptr += src->widthStep, dptr += dst->widthStep )
    {
        int i = 0;
        if( (((size_t)sptr | (size_t)dptr) & 3) == 0 )
        {
            for( ; i <= width - 16; i += 16 )
            {
                int t0 = ~((const int*)(sptr+i))[0];
                int t1 = ~((const int*)(sptr+i))[1];
                
                ((int*)(dptr+i))[0] = t0;
                ((int*)(dptr+i))[1] = t1;
                
                t0 = ~((const int*)(sptr+i))[2];
                t1 = ~((const int*)(sptr+i))[3];
                
                ((int*)(dptr+i))[2] = t0;
                ((int*)(dptr+i))[3] = t1;
            }
            
            for( ; i <= width - 4; i += 4 )
                *(int*)(dptr+i) = ~*(const int*)(sptr+i);
        }
        
        for( ; i < width; i++ )
        {
            dptr[i] = (uchar)(~sptr[i]);
        }
    }
}

void mxCopy(MxImage* src,MxImage* dst)
{
    memcpy(dst->imageData, src->imageData, dst->imageSize);
}

void mxThreshold( MxImage* _src, MxImage* _dst, uchar thresh, uchar maxval, int type )
{
    int i, j;
    uchar tab[256];
    int width = _src->widthStep;
    int height = _src->height;
    
    switch( type )
    {
        case THRESH_BINARY:
            for( i = 0; i <= thresh; i++ )
                tab[i] = 0;
            for( ; i < 256; i++ )
                tab[i] = maxval;
            break;
        case THRESH_BINARY_INV:
            for( i = 0; i <= thresh; i++ )
                tab[i] = maxval;
            for( ; i < 256; i++ )
                tab[i] = 0;
            break;
        case THRESH_TRUNC:
            for( i = 0; i <= thresh; i++ )
                tab[i] = (uchar)i;
            for( ; i < 256; i++ )
                tab[i] = thresh;
            break;
        case THRESH_TOZERO:
            for( i = 0; i <= thresh; i++ )
                tab[i] = 0;
            for( ; i < 256; i++ )
                tab[i] = (uchar)i;
            break;
        case THRESH_TOZERO_INV:
            for( i = 0; i <= thresh; i++ )
                tab[i] = (uchar)i;
            for( ; i < 256; i++ )
                tab[i] = 0;
            break;
        default:
            break;
    }
    
    for( i = 0; i < height; i++ )
    {
        const uchar* src = (const uchar*)(_src->imageData + _src->widthStep*i);
        uchar* dst = (uchar*)(_dst->imageData + _dst->widthStep*i);
        j = 0;
                
        for( ; j <= width - 4; j += 4 )
        {
            uchar t0 = tab[src[j]];
            uchar t1 = tab[src[j+1]];
            
            dst[j] = t0;
            dst[j+1] = t1;
            
            t0 = tab[src[j+2]];
            t1 = tab[src[j+3]];
            
            dst[j+2] = t0;
            dst[j+3] = t1;
        }
        
        for( ; j < width; j++ )
            dst[j] = tab[src[j]];
    }
}


#ifdef MX_IOS_SYSTEM

#pragma mark - UIImage Convertion

MxImage* MxImageFromUIImage(UIImage* image) 
{
	CGImageRef imageRef = image.CGImage;
	MxImage *out = mxCreateImage(image.size.width, image.size.height, 4);
    if(out){
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef contextRef = CGBitmapContextCreate(out->imageData, out->width, out->height,
													out->depth, out->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
        CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
        CGContextRelease(contextRef);
        CGColorSpaceRelease(colorSpace);
    }
	return out;
}

UIImage* UIImageFromMxImageEx(MxImage *image,CGFloat scale)
{
    CGBitmapInfo flags = kCGBitmapByteOrderDefault;
    CGColorSpaceRef colorSpace = NULL;
    
    switch (image->nChannels) {
        case 1:
            flags = kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceGray();
            break;
        case 3:
            flags = kCGImageAlphaNone|kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        case 4:
            flags = kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        default:
            return nil;
            break;
    }
    
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, flags,
										provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = nil;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        ret = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    }else{
        ret = [UIImage imageWithCGImage:imageRef];
    }
    
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}

UIImage* UIImageFromMxImage(MxImage *image)
{
    CGBitmapInfo flags = kCGBitmapByteOrderDefault;
    CGColorSpaceRef colorSpace = NULL;
    
    switch (image->nChannels) {
        case 1:
            flags = kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceGray();
            break;
        case 3:
            flags = kCGImageAlphaNone|kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        case 4:
            flags = kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault;
            colorSpace = CGColorSpaceCreateDeviceRGB();
            break;
        default:
            return nil;
            break;
    }
    
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, flags,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}

/* hypo 注释2013.7.29 好像没有用到
CGImageRef ImageRefMaskFromMxImage(MxImage* image)
{
	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageMaskCreate(image->width, image->height,
                                            image->depth, image->depth * image->nChannels, image->widthStep,
                                            provider, NULL, false);
	CGDataProviderRelease(provider);
	return imageRef;
}
*/
#endif
