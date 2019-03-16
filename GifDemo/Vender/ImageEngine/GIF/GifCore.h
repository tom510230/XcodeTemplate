//
//  GifCore.h
//  MicroMessenger
//
//  Created by jakerong on 11-11-1.
//  Copyright 2011年 tencent. All rights reserved.
//
#ifndef  DEF_JAKERONG_GIFCORE_H
#define DEF_JAKERONG_GIFCORE_H

#include <time.h>
#include <new>
#include <stdio.h>
#include <math.h>
#include <sys/time.h>
#include <string.h>
#include <stdlib.h>

#ifndef NULL
#define NULL (0)
#endif

#ifndef MX_SAFE_DELETE
#define MX_SAFE_DELETE(x) if(x){delete x;x=NULL;};
#endif

#ifndef SAFE_DELETE_ARRAY
#define SAFE_DELETE_ARRAY(x) if(x){delete[] x;x=NULL;};
#endif



struct GifFrameRect 
{
	int x;
	int y;
	int width;
	int height;
	GifFrameRect()
		:x(0)
		,y(0)
		,width(0)
		,height(0)
	{}
};

struct GifImageInfo
{
	int m_width;
	int m_height;
	int m_colordepth;
	unsigned char* m_globalcolormap;
	int m_bkcolor; // index of bk color
	int m_loopcount;
	GifImageInfo()
		:m_width(-1)
		,m_height(-1)
		,m_colordepth(-1)
		,m_globalcolormap(NULL)
		,m_bkcolor(-1)
		,m_loopcount(-1)
	{}
	virtual ~GifImageInfo(){};
};

struct GifExtInfo
{
	int transcolor;
	int disposal;
	int duration;
	GifExtInfo()
		:transcolor(-1)
		,disposal(-1)
		,duration(-1)
	{}
};

struct GifFrame
{
	GifFrameRect rect;
	int colordepth;
	unsigned char* colormap;
	unsigned char* pixels; // need free!!
	int pixelsize;
	GifFrame()
		:colordepth(-1)
		,colormap(NULL)
		,pixels(NULL)
		,pixelsize(-1)
	{}
	~GifFrame()
	{
		SAFE_DELETE_ARRAY(pixels);
	}
};

class GifDecoder:public GifImageInfo
{
public:
	bool load(unsigned char* buffer,unsigned long len);
    // 0=EOF解失败 1=成功 2=成功并且到文件结束
	int nextframe(GifFrame& frame,GifExtInfo& ext,bool lzwDecompress = true); 
	void rewind();
	GifDecoder(void);
	virtual ~GifDecoder(void);
protected:
	int lzwDecompress(GifFrame& frame,bool isInterlaced,unsigned char padbyte = 0);
protected:
	unsigned char* m_pos;
	unsigned char* m_maxpos;
	unsigned char* m_minpos;
};





#endif


